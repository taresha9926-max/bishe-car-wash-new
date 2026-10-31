import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/features/admin/domain/models/petty_cash_expense.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';

void main() {
  group('Petty Cash, Mandatory Proof, and 2-Tier Payroll Tests', () {
    late AppStateNotifier state;

    setUp(() async {
      final repo = WashRepositoryImpl();
      state = AppStateNotifier(repository: repo);
      await state.loadData();
    });

    test('Fresh production slate: bookings, commission logs, bank deposits, and closings start at 0', () {
      expect(state.bookings.isEmpty, isTrue);
      expect(state.commissionLogs.isEmpty, isTrue);
      expect(state.bankDeposits.isEmpty, isTrue);
      expect(state.dailyFinancialClosings.isEmpty, isTrue);
      expect(state.weeklyCommissionReports.isEmpty, isTrue);
      expect(state.pettyCashExpenses.isEmpty, isTrue);

      // Verify master data is intact (10 packages, 8 washers, 3 bays, 25 fixed assets, 20 consumables)
      expect(state.packages.length, equals(10));
      expect(state.availableWashers.length, equals(8));
      expect(state.bays.length, equals(3));
      expect(state.fixedAssets.length, equals(25));
      expect(state.consumables.length, equals(22));
    });

    test('Cashier Petty Cash reduces undeposited cash drawer balance in closing equation', () async {
      // 1. Register and pay a vehicle with Cash
      await state.registerWalkIn(
        licensePlate: 'ET-3-A12345',
        customerName: 'Kenenisa Bekele',
        customerPhone: '0911002233',
        package: state.packages.first, // e.g. ETB 500
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

      final cashCollected = state.totalCashRevenueETB;
      expect(cashCollected, equals(booking.totalPrice));
      expect(state.undepositedCashTodayETB, equals(cashCollected));

      // 2. Log Petty Cash expense of ETB 150 for Generator Fuel
      await state.recordPettyCashExpense(
        amount: 150.0,
        category: 'fuel',
        reason: 'Diesel fuel for backup power during blackout',
        cashierName: 'Abebech Tadesse',
        voucherScreenshot: 'data:image/png;base64,mockVoucherData',
      );

      expect(state.pettyCashExpenses.length, equals(1));
      expect(state.todayPettyCashExpensesETB, equals(150.0));

      // Undeposited cash drawer should now be: CashCollected - PettyCash = 500 - 150 = 350
      expect(state.undepositedCashTodayETB, equals(cashCollected - 150.0));

      // 3. Deposit ETB 200 to Bank Account A
      await state.recordBankDeposit(
        amount: 200.0,
        accountKey: 'account_a',
        referenceSlipNumber: 'CBE-SLIP-990011',
        cashierName: 'Abebech Tadesse',
      );

      // Drawer balance: 500 - 150 - 200 = 150
      expect(state.undepositedCashTodayETB, equals(150.0));

      // 4. Daily closing reconciliation equation verification
      final closing = await state.confirmDailyClosing(cashierName: 'Abebech Tadesse');
      expect(closing.grossRevenue, equals(500.0));
      expect(closing.pettyCashExpenses, equals(150.0));
      expect(closing.cashDeposited, equals(200.0));
      expect(closing.cashRemaining, equals(150.0));
    });

    test('Storekeeper receives stock with UoM and auto-calculates total stock value', () async {
      final initialTxCount = state.stockTransactions.length;
      final shampoo = state.consumables.firstWhere((c) => c.name.contains('Snow Foam') || c.name.contains('Shampoo'));
      final initialStock = shampoo.currentStock;

      // Receive 25 Liters of Shampoo at ETB 240 / L
      await state.receiveStock(
        itemId: shampoo.id,
        quantity: 25.0,
        unitCostEtb: 240.0,
        supplier: 'TotalEnergies Bishoftu',
        unit: 'Liters',
        invoiceScreenshot: 'data:image/png;base64,mockInvoice',
      );

      expect(state.stockTransactions.length, equals(initialTxCount + 1));
      final tx = state.stockTransactions.first;
      expect(tx.quantity, equals(25.0));
      expect(tx.unitCostEtb, equals(240.0));
      expect(tx.totalCostEtb, equals(25.0 * 240.0)); // 6,000 ETB
      expect(tx.unit, equals('Liters'));
      expect(tx.supplier, equals('TotalEnergies Bishoftu'));
      expect(tx.invoiceScreenshot, isNotNull);

      // Verify current stock incremented
      final updatedShampoo = state.consumables.firstWhere((c) => c.id == shampoo.id);
      expect(updatedShampoo.currentStock, equals(initialStock + 25.0));
      expect(updatedShampoo.unitCostEtb, equals(240.0));
    });

    test('2-Tier compensation: Weekly commission pool split + Monthly base wage guaranteed', () async {
      // Monthly base salary must be greater than zero for all 8 active washers
      expect(state.monthlyTotalBaseSalary, greaterThan(0));
      for (final w in state.availableWashers) {
        expect(w.baseSalaryMonthlyETB, greaterThan(0));
      }

      // Record attendance for 1 absent washer
      final firstWasher = state.availableWashers.first;
      state.setWasherAttendance(firstWasher.id, false);
      expect(state.isWasherPresentToday(firstWasher.id), isFalse);

      // Present washers share 100% of the commission pool proportionally
      final dividends = state.calculateWasherDividends(1000.0);
      expect(dividends[firstWasher.id]!.isPresent, isFalse);
      expect(dividends[firstWasher.id]!.earnedETB, equals(0.0));

      final presentTotalDividends = dividends.values
          .where((d) => d.isPresent)
          .fold<double>(0.0, (sum, d) => sum + d.earnedETB);
      expect(presentTotalDividends, closeTo(1000.0, 0.01));

      // Accountant disburses weekly commission report
      final report = await state.submitWeeklyCommissionReportToAdmin(
        cashierName: 'Abebech Tadesse',
        notes: 'End of week 43',
      );
      expect(report.isDisbursed, isFalse);

      await state.disburseWeeklyCommission(report.id);
      expect(state.weeklyCommissionReports.first.isDisbursed, isTrue);
      expect(state.weeklyCommissionReports.first.disbursedAt, isNotNull);
    });

    test('clearAllBookings wipes queue, history, and resets bays to vacant', () async {
      await state.registerWalkIn(
        licensePlate: 'CLEAR-1234',
        customerName: 'Test Clear',
        customerPhone: '0911002233',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );
      await state.recordPettyCashExpense(
        amount: 150.0,
        category: 'Emergency Soap Refill',
        reason: 'Immediate foam shortage',
        cashierName: 'Cashier Hawi',
      );
      expect(state.bookings.isNotEmpty, isTrue);
      expect(state.pettyCashExpenses.isNotEmpty, isTrue);

      await state.clearAllBookings();
      expect(state.bookings.isEmpty, isTrue);
      expect(state.commissionLogs.isEmpty, isTrue);
      expect(state.pettyCashExpenses.isEmpty, isTrue);
      expect(state.bankDeposits.isEmpty, isTrue);
      expect(state.dailyFinancialClosings.isEmpty, isTrue);
      expect(state.washerAttendances.isEmpty, isTrue);
      expect(state.weeklyCommissionReports.isEmpty, isTrue);
      expect(state.dailyHandovers.isEmpty, isTrue);
      expect(state.stockTransactions.isEmpty, isTrue);
      expect(state.pendingApprovals.isEmpty, isTrue);
      expect(state.bays.every((b) => b.isVacant), isTrue);
    });
  });
}
