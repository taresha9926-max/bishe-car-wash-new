import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/payment_process_dialog.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Option 1 Simplified Customer Hub & 3-Step Booking Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
    });

    testWidgets('CustomerHomeScreen strictly separates Car Wash and Carpet Cleaning divisions without cross-leakage', (tester) async {
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

      // Car Wash active: only ultra-clean Option 1 Car Wash hub (3 delivery tiles live cleanly inside Step 2)
      expect(find.text('What would you like to wash today?'), findsOneWidget);
      expect(find.text('Wash My Car'), findsOneWidget);
      expect(find.text('Prices are negotiable'), findsOneWidget);
      expect(find.text(state.tr('chooseDeliveryQuick')), findsNothing);
      expect(find.text('Wash My Carpet'), findsNothing);
      expect(find.text(state.tr('carpetDeliveryOptionsTitle')), findsNothing);

      // Switch to Carpet Washing Service tab: only clean Carpet hub, zero Car Wash or home delivery clutter
      await tester.tap(find.text(state.tr('carpetWashingService')));
      await tester.pumpAndSettle();
      expect(find.text('Wash My Carpet'), findsOneWidget);
      expect(find.text('Prices are negotiable'), findsOneWidget);
      expect(find.text(state.tr('carpetDeliveryOptionsTitle')), findsNothing);
      expect(find.text('Wash My Car'), findsNothing);
      expect(find.text(state.tr('stationBaysTitle')), findsNothing);
      expect(find.text(state.tr('trackMyCar')), findsNothing);
      tester.view.reset();
    });

    testWidgets('NewBookingScreen navigates Step 1 -> Step 2 -> Step 3 cleanly with negotiable badge', (tester) async {
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

      expect(find.text('Step 1 of 3: Pick vehicle size & wash service'), findsOneWidget);
      expect(find.text('Prices are negotiable'), findsOneWidget);

      await tester.ensureVisible(find.text('Next Step'));
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 3: How should we serve you?'), findsOneWidget);

      await tester.ensureVisible(find.text('Next Step'));
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 3: Your name & phone to confirm'), findsOneWidget);
      expect(find.text('Prices are negotiable'), findsOneWidget);
      tester.view.reset();
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

    test('Trilingual labels for Option 1 and Prices are negotiable are complete', () {
      for (final lang in ['EN', 'OM', 'AM']) {
        state.setLanguage(lang);
        expect(state.tr('pricesAreNegotiable'), isNotEmpty);
        expect(state.tr('whatToWashToday'), isNotEmpty);
        expect(state.tr('washMyCarTitle'), isNotEmpty);
        expect(state.tr('washMyCarpetTitle'), isNotEmpty);
        expect(state.tr('step1CarInstruction'), isNotEmpty);
        expect(state.tr('step2ModeInstruction'), isNotEmpty);
        expect(state.tr('step3DetailsInstruction'), isNotEmpty);
        expect(state.tr('finalNegotiatedPriceEtb'), isNotEmpty);
      }
    });
  });
}
