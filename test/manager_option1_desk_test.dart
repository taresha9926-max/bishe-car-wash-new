import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/daily_closing_dialog.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';

void main() {
  late AppStateNotifier state;

  setUp(() async {
    state = AppStateNotifier(repository: WashRepositoryImpl());
    await state.loadData();
    state.switchRole(UserRole.manager);
  });

  group('Operational Manager Option 1 Action Desk Tests', () {
    testWidgets('Opens directly onto Queue on mobile 360x780, hides bulk delete & renders Night Closing cleanly', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await state.registerWalkIn(
        customerName: 'Kebede Walk-In',
        licensePlate: 'AA-44110',
        customerPhone: '0911223344',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
      );

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OperationalManagerDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Immediate active Queue & zero false Confirmed banner on empty shift
      expect(find.text('AA-44110'), findsOneWidget);
      expect(find.text('Start Wash'), findsOneWidget);
      expect(find.text(state.tr('handoverConfirmed')), findsNothing);

      // Switch to Handover & Close tab
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      // Safe History hides Clear All Bookings
      expect(find.text(state.tr('clearAllBookings')), findsNothing);
      expect(find.text(state.tr('safeCashierModeNotice')), findsOneWidget);

      // Open Night Closing dialog cleanly on mobile (zero header/dividend overflow)
      await tester.ensureVisible(find.text(state.tr('initiateNightShiftClosing')));
      await tester.tap(find.text(state.tr('initiateNightShiftClosing')));
      await tester.pumpAndSettle();
      expect(find.byType(DailyClosingDialog), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Switch to Team tab (expanded immediately on mobile)
      await tester.ensureVisible(find.byType(Tab).at(2));
      await tester.tap(find.byType(Tab).at(2));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('markAllPresent')), findsOneWidget);
    });

    testWidgets('Inline Cashier OTP verification & Night Shift zero double-counting', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Day shift collects ETB 500 cash
      final dayCar = await state.registerWalkIn(
        customerName: 'Morning Client',
        licensePlate: 'OR-10001',
        customerPhone: '0911111111',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
      );
      await state.updateWashStatus(dayCar.id, WashStatus.completed);
      await state.processPayment(
        bookingId: dayCar.id,
        method: PaymentMethod.cash,
        amount: 500,
      );

      final dayClosing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const OperationalManagerDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Pending Cashier OTP banner must appear
      expect(find.text(state.tr('acceptCashierHandover')), findsOneWidget);

      // Wrong OTP rejected
      final otpField = find.byType(TextField).first;
      await tester.enterText(otpField, '0000');
      await tester.tap(find.text(state.tr('verifyAndTakeCustody')));
      await tester.pumpAndSettle();
      expect(state.pendingCashierHandover, isNotNull);
      expect(state.managerCarriedCashETB, 0.0);

      // Exact OTP accepted
      await tester.enterText(otpField, dayClosing.handoverOtp!);
      await tester.tap(find.text(state.tr('verifyAndTakeCustody')));
      await tester.pumpAndSettle();
      expect(state.pendingCashierHandover, isNull);
      expect(state.managerCarriedCashETB, 500.0);

      // Night shift collects extra ETB 300 cash -> total physical cash must be 800, NOT 1300!
      final nightCar = await state.registerWalkIn(
        customerName: 'Evening Client',
        licensePlate: 'OR-20002',
        customerPhone: '0922222222',
        carType: CarType.minibus,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 300,
      );
      await state.updateWashStatus(nightCar.id, WashStatus.completed);
      await state.processPayment(
        bookingId: nightCar.id,
        method: PaymentMethod.cash,
        amount: 300,
      );

      expect(state.nightShiftAdditionalCashETB, 300.0);

      final nightClosing = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'night',
        closedByRole: 'manager',
        handoverTo: 'Admin / Owner',
      );
      expect(nightClosing.carriedCashAmount, 500.0);
      expect(nightClosing.handoverCashAmount, 800.0);

      await tester.pumpAndSettle();
      // Pending Admin Night OTP banner displays without overflow
      expect(find.text(state.tr('adminNightHandoverCode')), findsOneWidget);
      expect(find.text('[ ${nightClosing.handoverOtp} ]'), findsOneWidget);
    });

    test('All new Manager Option 1 keys have distinct EN / OM / AM translations', () {
      const keys = [
        'managerTabHandoverClose',
        'managerTabTeam',
        'cashierOtpSubmitPrompt',
        'enterFourDigitOtpError',
        'dayShiftHandoverCashLabel',
        'nightShiftNetCashLabel',
        'totalCashToAdminLabel',
        'initiateNightShiftClosing',
        'nightClosingConfirmed',
        'nightClosingSubDesc',
        'cashToAdminSuffix',
        'awaitingHandoverLabel',
        'awaitingHandoverDesc',
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
