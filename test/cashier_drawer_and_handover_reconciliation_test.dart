import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';

void main() {
  group('Cashier Drawer, OTP Handover & Custody Reconciliation Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      final repo = WashRepositoryImpl();
      state = AppStateNotifier(repository: repo);
      await state.loadData();
    });

    test('100% Intact Cash Drawer: Car Wash + Shower Cash minus Urgent Expense equals exact Handover Cash', () async {
      // 1. Initial drawer is 0
      expect(state.cashierDrawerBalanceETB, equals(0.0));
      expect(state.undepositedCashTodayETB, equals(0.0));

      // 2. Add Cash Car Wash (ETB 500)
      await state.registerWalkIn(
        licensePlate: 'ET-TEST-01',
        customerName: 'Abebe Bikila',
        customerPhone: '0911223344',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );
      final carWashBooking = state.bookings.first;
      await state.processPayment(
        bookingId: carWashBooking.id,
        method: PaymentMethod.cash,
        amount: carWashBooking.totalPrice,
      );

      // 3. Add Public Shower (2 people @ 50 = ETB 100 Cash)
      await state.recordShowerEntry(
        userCount: 2,
        paymentMethod: PaymentMethod.cash,
        cashierName: 'Meron Cashier',
      );

      // Total physical cash collected = 500 + 100 = 600 ETB
      expect(state.totalCashRevenueETB, equals(600.0));
      expect(state.cashierDrawerBalanceETB, equals(600.0));

      // 4. Log Urgent Cash Expense (Emergency hose replacement: 50 ETB)
      await state.recordPettyCashExpense(
        amount: 50.0,
        category: 'Maintenance',
        reason: 'Emergency pressure hose clamp',
        cashierName: 'Meron Cashier',
      );

      // Drawer now has 600 - 50 = 550 ETB
      expect(state.cashierDrawerBalanceETB, equals(550.0));
      expect(state.undepositedCashTodayETB, equals(550.0));

      // 5. Verify VAT rules: 15% VAT on Car Wash (500 * 0.15 = 75 ETB), 0% VAT on Shower (100 * 0 = 0 ETB)
      expect(state.vatDeductedTodayETB, equals(500.0 * 0.15));
      expect(state.todayShowerRevenueETB, equals(100.0));

      // Mark daily commission disbursed so closing prerequisite passes
      state.markDailyCommissionDisbursed();

      // 6. Cashier closes Day Shift with Handover to Manager
      final closing = await state.confirmDailyClosing(
        cashierName: 'Chaltu Tadesse',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );

      expect(closing.handoverCashAmount, equals(550.0));
      expect(closing.isHandoverAccepted, isFalse);
      expect(closing.handoverOtp, isNotNull);

      // 7. Microsecond State Transition: Cashier drawer becomes 0.00 ETB!
      expect(state.isTodayDayShiftClosed, isTrue);
      expect(state.cashierDrawerBalanceETB, equals(0.0));

      // Manager has not accepted yet: carried cash is 0
      expect(state.managerCarriedCashETB, equals(0.0));

      // 8. Manager verifies OTP
      final accepted = await state.acceptCashierHandover(
        managerName: 'Gedion Worku',
        enteredOtp: closing.handoverOtp,
      );
      expect(accepted, isTrue);

      // Manager now holds the exact 550.0 ETB carried cash!
      expect(state.managerCarriedCashETB, equals(550.0));
      expect(state.managerCustodyCashETB, equals(550.0));

      // Cashier drawer remains 0.00 ETB
      expect(state.cashierDrawerBalanceETB, equals(0.0));
    });

    testWidgets('Cashier Money Tab disables Deposit to Bank button once Day Shift is handed over via OTP', (tester) async {
      tester.binding.setSurfaceSize(const Size(1280, 800));

      // 1. Register walk-in and pay cash
      await state.registerWalkIn(
        licensePlate: 'ET-TEST-02',
        customerName: 'Derartu Tulu',
        customerPhone: '0911556677',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );
      final booking = state.bookings.first;
      await state.processPayment(
        bookingId: booking.id,
        method: PaymentMethod.cash,
        amount: booking.totalPrice,
      );

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: const MaterialApp(home: CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Money Tab
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      // Before closing, Deposit to Bank is enabled
      final depositFinder = find.widgetWithText(ElevatedButton, state.tr('depositCashToBank'));
      expect(depositFinder, findsOneWidget);
      final initialButton = tester.widget<ElevatedButton>(depositFinder);
      expect(initialButton.onPressed, isNotNull);

      // 2. Perform Day Shift Closing with OTP handover
      state.markDailyCommissionDisbursed();
      await state.confirmDailyClosing(
        cashierName: 'Chaltu Tadesse',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );
      await tester.pumpAndSettle();

      // 3. Deposit to Bank button MUST be immediately disabled (onPressed == null)
      final afterButton = tester.widget<ElevatedButton>(depositFinder);
      expect(afterButton.onPressed, isNull);
      expect(find.text(state.tr('drawerEmptyHandedOver')), findsWidgets);
    });

    testWidgets('Operational Manager receives exact Handover Cash in OTP Banner and Dashboard Tab', (tester) async {
      tester.binding.setSurfaceSize(const Size(1280, 800));

      // 1. Day cash collected: 1,000 ETB
      await state.registerWalkIn(
        licensePlate: 'ET-TEST-03',
        customerName: 'Haile Gebrselassie',
        customerPhone: '0911889900',
        package: state.packages.first, // 500
        carType: CarType.automobile,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );
      await state.processPayment(
        bookingId: state.bookings.first.id,
        method: PaymentMethod.cash,
        amount: state.bookings.first.totalPrice,
      );

      await state.recordShowerEntry(
        userCount: 10,
        paymentMethod: PaymentMethod.cash,
        cashierName: 'Meron Cashier',
      ); // 500 ETB

      expect(state.cashierDrawerBalanceETB, equals(1000.0));

      // Day closing
      state.markDailyCommissionDisbursed();
      final closing = await state.confirmDailyClosing(
        cashierName: 'Chaltu Tadesse',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );

      // Launch Operational Manager Dashboard
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: const MaterialApp(home: OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Manager OTP Card must show exact handover amount
      expect(find.text(state.tr('acceptCashierHandover')), findsOneWidget);
      expect(find.text(CurrencyFormatter.format(closing.handoverCashAmount)), findsWidgets);

      // Verify OTP
      await state.acceptCashierHandover(
        managerName: 'Gedion Worku',
        enteredOtp: closing.handoverOtp,
      );
      await tester.pumpAndSettle();

      // Banner clears
      expect(find.text(state.tr('acceptCashierHandover')), findsNothing);

      // Switch to Money & Handover Tab
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      // Manager custody cash shows 1,000 ETB and deposit button is enabled for Manager!
      final mgrDepositFinder = find.widgetWithText(ElevatedButton, state.tr('depositCashToBank'));
      final mgrButton = tester.widget<ElevatedButton>(mgrDepositFinder);
      expect(mgrButton.onPressed, isNotNull);
    });
  });
}
