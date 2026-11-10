import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/payment_process_dialog.dart';

void main() {
  late AppStateNotifier state;

  setUp(() async {
    state = AppStateNotifier(repository: WashRepositoryImpl());
    await state.loadData();
    state.switchRole(UserRole.cashier);
  });

  group('Cashier Option 1 Action Desk Tests', () {
    testWidgets('Opens directly onto Queue, hides bulk delete & profit in Money, and increments Shower in Team', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await state.registerWalkIn(
        customerName: 'Dawit Gate',
        licensePlate: 'AA-55441',
        customerPhone: '0911002233',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
      );

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CashierDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Queue opens immediately without blank module puzzle cards
      expect(find.text('AA-55441'), findsOneWidget);
      expect(find.text('Start Wash'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsWidgets);

      // Payment must stay locked until wash completes
      expect(find.textContaining('Collect'), findsNothing);

      // Switch to Money tab -> Safe History hides Clear All Bookings; Shift Logs hide Net Station Profit
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('physicalCashInDrawer')), findsOneWidget);
      expect(find.text(state.tr('clearAllBookings')), findsNothing);
      expect(find.text(state.tr('safeCashierModeNotice')), findsOneWidget);

      await tester.ensureVisible(find.text(state.tr('dailyFinancialReportsTab')));
      await tester.tap(find.text(state.tr('dailyFinancialReportsTab')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('netStationProfit')), findsNothing);

      // Switch to Team & Shower tab -> Shower +2 increments properly (+2 => 3 from initial 1)
      await tester.ensureVisible(find.byType(Tab).at(2));
      await tester.tap(find.byType(Tab).at(2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+2'));
      await tester.pumpAndSettle();
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('Status progression unlocks Collect Payment dialog cleanly and Carpet delivery mode is preserved', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final carOrder = await state.registerWalkIn(
        customerName: 'Bontu Tadesse',
        licensePlate: 'OR-99102',
        customerPhone: '0912345678',
        carType: CarType.minibus,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
      );

      final carpetValetOrder = await state.registerWalkIn(
        customerName: 'Chaltu Carpet',
        licensePlate: 'CPT-771',
        customerPhone: '0922334455',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        isCarpet: true,
        carpetType: 'type_a',
        carpetAreaSqMeters: 6.0,
        carpetDimensions: '2m x 3m',
        customTotalPrice: 900,
        serviceType: ServiceType.valetPickUp,
      );
      expect(carpetValetOrder.serviceType, equals(ServiceType.valetPickUp));

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const CashierDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Advance OR-99102 through Washing -> Drying -> Completed -> Unlock Payment
      final washBtn = find.widgetWithText(ElevatedButton, 'Start Wash').first;
      await tester.ensureVisible(washBtn);
      await tester.tap(washBtn);
      await tester.pumpAndSettle();

      final dryBtn = find.widgetWithText(ElevatedButton, state.tr('moveToDryingAction')).first;
      await tester.ensureVisible(dryBtn);
      await tester.tap(dryBtn);
      await tester.pumpAndSettle();

      final readyBtn = find.widgetWithText(ElevatedButton, state.tr('markCompletedAction')).first;
      await tester.ensureVisible(readyBtn);
      await tester.tap(readyBtn);
      await tester.pumpAndSettle();

      final updated = state.bookings.firstWhere((b) => b.id == carOrder.id);
      expect(updated.payment.isPaid, isFalse);

      final collectFinder = find.textContaining(state.tr('collectPaymentAction'));
      expect(collectFinder, findsAtLeastNWidgets(1));
      await tester.ensureVisible(collectFinder.first);
      await tester.tap(collectFinder.first);
      await tester.pumpAndSettle();

      expect(find.byType(PaymentProcessDialog), findsOneWidget);
    });

    test('All new Cashier Option 1 keys have distinct EN / OM / AM translations', () {
      const keys = [
        'cashierTabQueue',
        'cashierTabMoney',
        'cashierTabTeamShower',
        'cashierFilterAll',
        'cashierFilterWaiting',
        'cashierFilterInProgress',
        'cashierFilterPayReady',
        'searchQueueHint',
        'waitingForAdminOtp',
        'physicalCashInDrawer',
        'expenseAmount',
        'copySms',
        'smsCopiedClipboard',
        'settledPaidBadge',
        'phoneOrderBadge',
        'safeCashierModeNotice',
        'showerRecordedToast',
      ];
      for (final key in keys) {
        final en = AppStrings.get(key, AppLanguage.en);
        final om = AppStrings.get(key, AppLanguage.om);
        final am = AppStrings.get(key, AppLanguage.am);
        expect(en, isNot(equals(key)), reason: 'Missing EN for $key');
        expect(om, isNot(equals(key)), reason: 'Missing OM for $key');
        expect(om, isNot(equals(en)), reason: 'Untranslated OM for $key');
        expect(am, isNot(equals(key)), reason: 'Missing AM for $key');
        expect(am, isNot(equals(en)), reason: 'Untranslated AM for $key');
      }
    });
  });
}
