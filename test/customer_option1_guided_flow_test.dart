import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/auth_roles/presentation/screens/role_shell_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/payment_process_dialog.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/ad_video_showcase_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Refactored Customer Flow, Bottom Tabs & Merged 2-Step Booking Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
    });

    testWidgets('Splash completion lands directly on CustomerHomeScreen bypassing WelcomeScreen', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const RoleShellScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      state.completeEntranceSplash();
      await tester.pumpAndSettle();

      expect(find.byType(CustomerHomeScreen), findsOneWidget);
      expect(find.text(state.tr('whatToWashToday')), findsOneWidget);
    });

    testWidgets('CustomerHomeScreen opens NewBookingScreen directly without intermediate hub and puts Track + TikTok Ad in bottom tab', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CustomerHomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default Wash tab: "What would you like to wash today?" + Car & Carpet tabs, no rolling banner, top AI icon
      expect(find.text(state.tr('whatToWashToday')), findsOneWidget);
      expect(find.text(state.tr('carWashingService')), findsOneWidget);
      expect(find.text(state.tr('carpetWashingService')), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
      expect(find.text(state.tr('trackMyCar')), findsNothing);

      // Tap Car Washing Service -> opens NewBookingScreen directly (bypassing old division hub)
      await tester.tap(find.text(state.tr('carWashingService')));
      await tester.pumpAndSettle();
      expect(find.byType(NewBookingScreen), findsOneWidget);
      expect(find.text(state.tr('washMyCarTitle')), findsOneWidget);
      expect(find.text(state.tr('pricesAreNegotiable')), findsOneWidget);
      expect(find.text(state.tr('howShouldWeServeYou')), findsOneWidget);

      // Navigate back -> tap Carpet Washing Service -> opens NewBookingScreen(isCarpet: true) directly
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text(state.tr('whatToWashToday')), findsOneWidget);

      await tester.tap(find.text(state.tr('carpetWashingService')));
      await tester.pumpAndSettle();
      expect(find.byType(NewBookingScreen), findsOneWidget);
      expect(find.text(state.tr('washMyCarpetTitle')), findsOneWidget);
      expect(find.text(state.tr('pricesAreNegotiable')), findsOneWidget);

      // Navigate back -> tap Track bottom tab -> reveals Track My Vehicle + TikTok Ad card
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text(state.tr('bottomTabTrack')));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(state.tr('trackMyCar')), findsWidgets);
      expect(find.byType(AdVideoShowcaseCard), findsOneWidget);

      // Tap Station bottom tab -> reveals Call & Google Maps
      await tester.tap(find.text(state.tr('bottomTabStation')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('openGoogleMaps')), findsOneWidget);
      expect(find.text(state.tr('phoneCallBooking')), findsOneWidget);

      // Tap Feedback bottom tab -> reveals CustomerFeedbackSheet embedded
      await tester.tap(find.text(state.tr('bottomTabFeedback')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('rateExperienceQuestion')), findsOneWidget);
    });

    testWidgets('NewBookingScreen renders single screen mirroring Cashier intake minus Assign Bay, Final Price edit & Tip', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NewBookingScreen(isCarpet: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Single screen: delivery mode row at top, vehicle size & expandable wash cards below, customer fields inline
      expect(find.text(state.tr('howShouldWeServeYou')), findsOneWidget);
      expect(find.text(state.tr('driveInStation')), findsOneWidget);
      expect(find.text(state.tr('serviceValetPickUp')), findsOneWidget);
      expect(find.text(state.tr('atHomeMobile')), findsOneWidget);
      expect(find.text(state.tr('pickVehicleAndWashTitle')), findsOneWidget);
      expect(find.text(state.tr('customDetailingTab')), findsOneWidget);
      expect(find.text(state.tr('presetPackagesTab')), findsOneWidget);
      expect(find.text(state.tr('fullNameOrCarType')), findsOneWidget);
      expect(find.text('${state.tr('customerPhone')} (${state.tr('optional')})'), findsOneWidget);
      expect(find.text(state.tr('licensePlate')), findsOneWidget);
      expect(find.text(state.tr('pricesAreNegotiable')), findsOneWidget);

      // Excluded Cashier-only & unwanted controls
      expect(find.text(state.tr('nextStep')), findsNothing);
      expect(find.text(state.tr('assignVehicle')), findsNothing);
      expect(find.text(state.tr('assignWasherDuringBooking')), findsNothing);
      expect(find.text(state.tr('negotiatedTotalPriceTitle')), findsNothing);
      expect(find.text(state.tr('washersTip')), findsNothing);
      expect(find.text(state.tr('customTip')), findsNothing);

      // Clicking Custom Detailing expands service checkboxes
      await tester.ensureVisible(find.text(state.tr('customDetailingTab')));
      await tester.tap(find.text(state.tr('customDetailingTab')));
      await tester.pumpAndSettle();
      expect(find.byType(CheckboxListTile), findsWidgets);

      // Clicking Preset Service Packages expands preset package list
      await tester.ensureVisible(find.text(state.tr('presetPackagesTab')));
      await tester.tap(find.text(state.tr('presetPackagesTab')));
      await tester.pumpAndSettle();
      expect(find.byType(Radio<String>), findsWidgets);

      // Same single-screen layout applies to Carpet Washing Service
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            key: const ValueKey('carpet-guided-flow'),
            theme: AppTheme.lightTheme,
            home: const NewBookingScreen(isCarpet: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(state.tr('howShouldWeServeYou')), findsOneWidget);
      expect(find.text(state.tr('carpetStationService')), findsOneWidget);
      expect(find.text(state.tr('carpetValetTitle')), findsOneWidget);
      expect(find.text(state.tr('carpetHomeTitle')), findsOneWidget);
      expect(find.text(state.tr('pickCarpetTypeAndSizeTitle')), findsOneWidget);
      expect(find.text(state.tr('fullNameOrCarType')), findsOneWidget);
      expect(find.text(state.tr('carpetTrackingTag')), findsOneWidget);
      expect(find.text(state.tr('nextStep')), findsNothing);
      expect(find.text(state.tr('washersTip')), findsNothing);

      // Expand carpet dimensions card cleanly
      await tester.ensureVisible(find.text(state.tr('carpetDimensionsTitle')));
      await tester.tap(find.text(state.tr('carpetDimensionsTitle')));
      await tester.pumpAndSettle();

      // Submitting booking directly opens LiveTrackingScreen at end of booking
      await tester.ensureVisible(find.byType(TextFormField).first);
      await tester.enterText(find.byType(TextFormField).first, 'Gemechu T.');
      final bookBtn = find.textContaining(state.tr('bookCarpetCleaning'));
      await tester.ensureVisible(bookBtn);
      await tester.tap(bookBtn);
      await tester.pumpAndSettle();

      expect(find.byType(LiveTrackingScreen), findsOneWidget);
    });

    testWidgets('PaymentProcessDialog allows Cashier to enter negotiated station price', (tester) async {
      final booking = await state.bookNewWash(
        customerName: 'Tola Gemechu',
        customerPhone: '+251 91 222 3344',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: '3-C12345 ET',
        package: state.packages.first,
        customTotalPrice: 500.0,
      );

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(body: PaymentProcessDialog(booking: booking)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final priceField = find.widgetWithText(TextField, 'Final Negotiated Price (ETB)');
      expect(priceField, findsOneWidget);
      await tester.enterText(priceField, '450');
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Confirm & Complete Payment'));
      await tester.tap(find.text('Confirm & Complete Payment'));
      await tester.pumpAndSettle();

      final updated = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.payment.isPaid, isTrue);
      expect(updated.payment.amount, equals(450.0));
      expect(updated.payment.method, equals(PaymentMethod.cash));
    });

    test('Trilingual labels for Customer Home bottom tabs and merged steps are complete', () {
      for (final lang in ['EN', 'OM', 'AM']) {
        state.setLanguage(lang);
        expect(state.tr('pricesAreNegotiable'), isNotEmpty);
        expect(state.tr('whatToWashToday'), isNotEmpty);
        expect(state.tr('washMyCarTitle'), isNotEmpty);
        expect(state.tr('washMyCarpetTitle'), isNotEmpty);
        expect(state.tr('howShouldWeServeYou'), isNotEmpty);
        expect(state.tr('mergedCarInstruction'), isNotEmpty);
        expect(state.tr('mergedCarpetInstruction'), isNotEmpty);
        expect(state.tr('pickVehicleAndWashTitle'), isNotEmpty);
        expect(state.tr('pickCarpetTypeAndSizeTitle'), isNotEmpty);
        expect(state.tr('step2DetailsInstruction'), isNotEmpty);
        expect(state.tr('step2CarpetDetailsInstruction'), isNotEmpty);
        expect(state.tr('bottomTabWash'), isNotEmpty);
        expect(state.tr('bottomTabTrack'), isNotEmpty);
        expect(state.tr('bottomTabStation'), isNotEmpty);
        expect(state.tr('bottomTabFeedback'), isNotEmpty);
        expect(state.tr('finalNegotiatedPriceEtb'), isNotEmpty);
      }
    });
  });
}
