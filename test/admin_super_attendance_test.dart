import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
import 'package:bishe_car_wash/features/admin/domain/models/pending_approval_request.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/welcome/domain/models/tiktok_ad_video.dart';

void main() {
  group('Super Admin vs Secondary Admin & Commission Attendance Tests', () {
    late AppStateNotifier state;
    late WashRepositoryImpl repo;

    setUp(() async {
      repo = WashRepositoryImpl();
      state = AppStateNotifier(repository: repo);
      await state.loadData();
    });

    test('Default mode is secondary admin; sensitive changes create pending approvals', () async {
      expect(state.isSuperAdmin, isFalse);

      // Secondary admin attempts to update PIN
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '9999',
        fullName: 'Test Cashier',
      );

      // Credential in state is NOT updated directly
      final cred = state.credentials.firstWhere((c) => c.id == 'cred-cashier');
      expect(cred.pin, isNot('9999'));

      // Instead, pending approval was created
      expect(state.pendingApprovals.length, 1);
      final req = state.pendingApprovals.first;
      expect(req.actionType, ApprovalActionType.changePin);
      expect(req.payload['pin'], '9999');
    });

    test('Super Admin can approve pending requests and apply changes', () async {
      // 1. Submit pending request as secondary admin
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '8888',
        fullName: 'New Cashier Name',
      );
      expect(state.pendingApprovals.length, 1);

      // 2. Super Admin logs in
      state.setSuperAdminStatus(true);
      expect(state.isSuperAdmin, isTrue);

      // 3. Super Admin approves request
      final req = state.pendingApprovals.first;
      await state.approveRequest(req.id);

      expect(state.pendingApprovals.isEmpty, isTrue);
      final updatedCred = state.credentials.firstWhere((c) => c.id == 'cred-cashier');
      expect(updatedCred.pin, '8888');
      expect(updatedCred.fullName, 'New Cashier Name');
    });

    test('Super Admin can directly make changes without approval queue', () async {
      state.setSuperAdminStatus(true);
      expect(state.isSuperAdmin, isTrue);

      // Super Admin updates PIN directly
      await state.updateStaffCredential(
        id: 'cred-cashier',
        pin: '7777',
        fullName: 'Direct Super Admin Update',
      );

      expect(state.pendingApprovals.isEmpty, isTrue);
      final cred = state.credentials.firstWhere((c) => c.id == 'cred-cashier');
      expect(cred.pin, '7777');
      expect(cred.fullName, 'Direct Super Admin Update');
    });

    test('Daily Attendance & 100% Commission Pool Distribution', () {
      final washers = state.availableWashers;
      expect(washers.length, greaterThan(0));

      const double testPool = 1000.0; // 1000 ETB pool

      // All present initially
      var dividends = state.calculateWasherDividends(testPool);
      double totalPercentage = 0.0;
      double totalETB = 0.0;

      for (final div in dividends.values) {
        expect(div.isPresent, isTrue);
        expect(div.percentageShare, greaterThan(0.0));
        totalPercentage += div.percentageShare;
        totalETB += div.earnedETB;
      }

      // Sum of percentages must equal 100%
      expect((totalPercentage - 100.0).abs(), lessThan(0.01));
      expect((totalETB - testPool).abs(), lessThan(0.01));

      // Mark the first washer as ABSENT
      final absentWasher = washers.first;
      state.setWasherAttendance(absentWasher.id, false);

      expect(state.isWasherPresentToday(absentWasher.id), isFalse);
      expect(state.presentWashersCount, washers.length - 1);

      // Recalculate dividends
      dividends = state.calculateWasherDividends(testPool);

      // Absent washer gets 0% and 0 ETB
      final absentDividend = dividends[absentWasher.id]!;
      expect(absentDividend.isPresent, isFalse);
      expect(absentDividend.percentageShare, 0.0);
      expect(absentDividend.earnedETB, 0.0);

      // Present washers divide 100% of the pool
      double presentTotalPercentage = 0.0;
      double presentTotalETB = 0.0;

      for (final w in washers) {
        final div = dividends[w.id]!;
        if (div.isPresent) {
          presentTotalPercentage += div.percentageShare;
          presentTotalETB += div.earnedETB;
        }
      }

      expect((presentTotalPercentage - 100.0).abs(), lessThan(0.01));
      expect((presentTotalETB - testPool).abs(), lessThan(0.01));
    });

    test('Strict PIN authentication: edited PIN is the ONLY valid entry PIN', () async {
      // Super Admin edits their PIN from 1234 to 4450
      state.setSuperAdminStatus(true);
      await state.updateStaffCredential(
        id: 'cred-admin',
        pin: '4450',
        fullName: 'Super Admin',
      );

      // Verify old hardcoded PIN 1234 fails
      final oldAuth = await state.authenticateRoleAsync(UserRole.admin, '1234');
      expect(oldAuth, isFalse);

      // Verify newly edited PIN 4450 succeeds and sets Super Admin status
      final newAuth = await state.authenticateRoleAsync(UserRole.admin, '4450');
      expect(newAuth, isTrue);
      expect(state.isSuperAdmin, isTrue);
    });

    test('Paid vehicle lifecycle: vanishes from active queue and is in history', () async {
      await state.registerWalkIn(
        licensePlate: 'AA-2-B44810',
        customerName: 'Abebe Test',
        customerPhone: '0911223344',
        package: state.packages.first,
        carType: CarType.automobile,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );

      final initialQueue = state.bookings.where((b) => !b.payment.isPaid).toList();
      expect(initialQueue.length, greaterThan(0));

      final targetBooking = initialQueue.first;
      // Mark as paid
      await state.processPayment(
        bookingId: targetBooking.id,
        method: PaymentMethod.cash,
        amount: targetBooking.totalPrice,
      );

      final updatedQueue = state.bookings.where((b) => !b.payment.isPaid).toList();
      expect(updatedQueue.any((b) => b.id == targetBooking.id), isFalse);

      final paidHistory = state.bookings.where((b) => b.payment.isPaid).toList();
      expect(paidHistory.any((b) => b.id == targetBooking.id), isTrue);
    });

    test('Multi-channel payment breakdown and bank deposits (Account A & B)', () async {
      // Process a payment with Bank of Abyssinia and one with Awash Bank
      final unpaid = state.bookings.where((b) => !b.payment.isPaid).take(2).toList();
      if (unpaid.length >= 2) {
        await state.processPayment(
          bookingId: unpaid[0].id,
          method: PaymentMethod.bankOfAbyssinia,
          amount: unpaid[0].totalPrice,
          transactionRef: 'BOA-TX-10029',
        );
        await state.processPayment(
          bookingId: unpaid[1].id,
          method: PaymentMethod.awashBank,
          amount: unpaid[1].totalPrice,
          transactionRef: 'AW-TX-88201',
        );
      }

      final revenueByMethod = state.getRevenueByPaymentMethod();
      expect(revenueByMethod.containsKey(PaymentMethod.bankOfAbyssinia), isTrue);
      expect(revenueByMethod.containsKey(PaymentMethod.awashBank), isTrue);

      // Record bank deposit to Account A (CBE)
      final initialDepositsCount = state.bankDeposits.length;
      await state.recordBankDeposit(
        amount: 2500.0,
        accountKey: 'account_a',
        referenceSlipNumber: 'CBE-SLIP-TEST-001',
        cashierName: 'Test Cashier',
      );

      expect(state.bankDeposits.length, equals(initialDepositsCount + 1));
      final latestDeposit = state.bankDeposits.first;
      expect(latestDeposit.accountKey, equals('account_a'));
      expect(latestDeposit.amount, equals(2500.0));
      expect(latestDeposit.bankName, contains('Commercial Bank of Ethiopia'));

      // Record bank deposit to Account B (Awash Bank)
      await state.recordBankDeposit(
        amount: 1800.0,
        accountKey: 'account_b',
        referenceSlipNumber: 'AW-SLIP-TEST-002',
        cashierName: 'Test Cashier',
      );
      final latestDepositB = state.bankDeposits.first;
      expect(latestDepositB.accountKey, equals('account_b'));
      expect(latestDepositB.bankName, contains('Awash Bank'));
    });

    test('Daily financial closing confirmation and washer payroll cycles', () async {
      final initialClosingCount = state.dailyFinancialClosings.length;

      // Confirm daily closing by Cashier
      final closing = await state.confirmDailyClosing(
        cashierName: 'Abebech Cashier',
        notes: 'End of shift closing test',
      );

      expect(state.dailyFinancialClosings.length, equals(initialClosingCount + 1));
      expect(closing.isConfirmed, isTrue);
      expect(closing.cashierName, equals('Abebech Cashier'));
      expect(state.isTodayClosed, isTrue);
      expect(state.hasNewCashierClosingAlert, isTrue);
      expect(state.latestClosingAlert?.cashierName, equals('Abebech Cashier'));
      state.dismissCashierClosingAlert();
      expect(state.hasNewCashierClosingAlert, isFalse);

      // Verify Weekly commission accumulation and monthly salary
      final weeklyPool = state.weeklyTotalCommissionPool;
      expect(weeklyPool, greaterThanOrEqualTo(0));

      final monthlyBase = state.monthlyTotalBaseSalary;
      expect(monthlyBase, greaterThan(0));

      final weeklyCommissions = state.weeklyWasherCommissions;
      expect(weeklyCommissions, isNotEmpty);
    });

    test('Cashier submits weekly commission report to admin and persists it', () async {
      final initialCount = state.weeklyCommissionReports.length;

      final report = await state.submitWeeklyCommissionReportToAdmin(
        cashierName: 'Abebech Cashier',
        notes: 'Official week 43 payout report for admin',
      );

      expect(state.weeklyCommissionReports.length, equals(initialCount + 1));
      expect(state.latestWeeklyCommissionReport, isNotNull);
      expect(state.latestWeeklyCommissionReport!.cashierName, equals('Abebech Cashier'));
      expect(state.latestWeeklyCommissionReport!.totalWeeklyPool, equals(report.totalWeeklyPool));
      expect(state.latestWeeklyCommissionReport!.washerCommissions, isNotEmpty);
      expect(state.latestWeeklyCommissionReport!.notes, equals('Official week 43 payout report for admin'));
    });

    test('Walk-in booking lifecycle starts as pending and dispatches SMS on completion', () async {
      // 1. Verify default cashier SMS phone is 0962274450 and can be configured
      expect(state.cashierSmsPhone, equals('0962274450'));
      state.setCashierSmsPhone('0911223344');
      expect(state.cashierSmsPhone, equals('0911223344'));
      state.setCashierSmsPhone('0962274450');

      // 2. Register new walk-in vehicle
      final pkg = state.packages.first;
      final booking = await state.registerWalkIn(
        licensePlate: 'TEST-9988',
        customerPhone: '0912345678',
        customerName: 'Dawit Abebe',
        carType: CarType.automobile,
        package: pkg,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );

      // 3. New walk-in starts in pending status (not auto-washing)
      expect(booking.status, equals(WashStatus.pending));

      // 4. Step-by-step lifecycle: Start Wash -> Move to Drying -> Mark Completed
      await state.updateWashStatus(booking.id, WashStatus.washing);
      var updated = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.status, equals(WashStatus.washing));

      await state.updateWashStatus(booking.id, WashStatus.drying);
      updated = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.status, equals(WashStatus.drying));

      // 5. Completion triggers SMS dispatch
      final smsSuccess = await state.sendCustomerCompletionSms(updated);
      expect(smsSuccess, isTrue);

      await state.updateWashStatus(booking.id, WashStatus.completed);
      updated = state.bookings.firstWhere((b) => b.id == booking.id);
      expect(updated.status, equals(WashStatus.completed));
    });

    test('Super Admin configures TikTok commercial reels and persists across devices', () async {
      expect(state.tiktokReels.length, equals(7));
      expect(state.tiktokReels.first.tiktokUrl, equals('https://www.tiktok.com/@bishecarwash/video/7703232736168791303'));

      // Verify URL Sanitization & Batch Extraction
      const rawUrlWithTracking = 'https://www.tiktok.com/@bishecarwash/video/7703232736168791303?is_from_webapp=1&sender_device=pc&web_id=7703571366952338977';
      expect(UrlLauncherHelper.sanitizeTikTokUrl(rawUrlWithTracking), equals('https://www.tiktok.com/@bishecarwash/video/7703232736168791303'));

      const rawBatch = '''
https://www.tiktok.com/@bishecarwash/video/7703232736168791303?is_from_webapp=1
https://www.tiktok.com/@bishecarwash/video/7703201662713728274?sender_device=pc
''';
      final extracted = UrlLauncherHelper.extractUrls(rawBatch);
      expect(extracted.length, equals(2));
      expect(extracted[0], equals('https://www.tiktok.com/@bishecarwash/video/7703232736168791303'));
      expect(extracted[1], equals('https://www.tiktok.com/@bishecarwash/video/7703201662713728274'));

      // Verify curated 16-reel photography and ad pool (8 artworks + 8 ad banners)
      expect(AutoCareAssets.curatedReelsPool.length, equals(16));
      expect(AutoCareAssets.curatedReelsPool.every((r) => r['url']!.isNotEmpty), isTrue);

      // Verify reels 5 to 8 localization
      const reel5 = TikTokAdVideo(id: 'reel-5', title: 'Tire Gloss', subtitle: 'Tire care', tiktokUrl: '', thumbnailUrl: '');
      expect(reel5.localizedTitle('OM'), contains('Gommaa'));
      expect(reel5.localizedTitle('AM'), contains('የጎማ'));

      // Verify new ad banners localization
      const adReel1 = TikTokAdVideo(id: 'reel-ad-1', title: 'Snow Foam', subtitle: 'Wash', tiktokUrl: '', thumbnailUrl: '');
      expect(adReel1.localizedTitle('AM'), contains('ስኖው ፎም'));
      expect(adReel1.localizedTitle('OM'), contains('Saamunaatiin'));
      expect(reel5.localizedTitle('AM'), contains('የጎማ'));

      const reel8 = TikTokAdVideo(id: 'reel-8', title: 'Mobile Van', subtitle: 'Van care', tiktokUrl: '', thumbnailUrl: '');
      expect(reel8.localizedTitle('OM'), contains('Makiinaa Socho\'aa'));
      expect(reel8.localizedTitle('AM'), contains('ተንቀሳቃሽ'));

      final modified = [
        ...state.tiktokReels,
      ];
      modified[0] = modified[0].copyWith(
        title: 'Updated Detailing Highlight',
        tiktokUrl: 'https://www.tiktok.com/@bishecarwash/video/7703232736168791303',
      );

      await state.setTikTokReels(modified);
      expect(state.tiktokReels.first.title, equals('Updated Detailing Highlight'));

      // Simulate a customer phone launching app: fresh state loads from repository
      final customerState = AppStateNotifier(repository: repo);
      await customerState.loadData();
      expect(customerState.tiktokReels.first.title, equals('Updated Detailing Highlight'));
      expect(customerState.tiktokReels.first.tiktokUrl, equals('https://www.tiktok.com/@bishecarwash/video/7703232736168791303'));
    });

    test('Customer phone call booking defaults to 0910046553 and is editable by admin anytime', () async {
      // 1. Initial default hotline
      expect(state.customerPhoneBookingNumber, equals('0910046553'));

      // 2. Admin edits the phone booking hotline
      await state.setCustomerPhoneBookingNumber('0911223344');
      expect(state.customerPhoneBookingNumber, equals('0911223344'));

      // 3. New state or customer launch reflects the edited phone booking number
      final freshState = AppStateNotifier(repository: repo);
      await freshState.loadData();
      expect(freshState.customerPhoneBookingNumber, equals('0911223344'));
    });

    test('Cashier day closing with manager OTP handover requires valid OTP for acceptance', () async {
      // 1. Cashier closes day shift with manager_otp
      final closing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );

      expect(closing.handoverMethod, 'manager_otp');
      expect(closing.isHandoverAccepted, isFalse);
      expect(closing.handoverOtp, isNotNull);
      expect(closing.handoverOtp!.length, 4);
      expect(state.pendingCashierHandover, isNotNull);

      // 2. Manager attempts with incorrect OTP -> fails
      final wrongOk = await state.acceptCashierHandover(
        managerName: 'Dawit Manager',
        enteredOtp: '0000',
      );
      expect(wrongOk, isFalse);
      expect(state.pendingCashierHandover, isNotNull);
      expect(state.managerCarriedCashETB, 0.0);

      // 3. Manager enters exact OTP -> succeeds
      final correctOk = await state.acceptCashierHandover(
        managerName: 'Dawit Manager',
        enteredOtp: closing.handoverOtp,
      );
      expect(correctOk, isTrue);
      expect(state.pendingCashierHandover, isNull);
      expect(state.managerCarriedCashETB, closing.cashRemaining);
    });

    test('Cashier day closing with bank deposit contingency directly deposits cash to owner bank', () async {
      final initialDepositsCount = state.bankDeposits.length;

      final closing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverMethod: 'bank_deposit',
        bankAccountKey: 'account_b',
        bankReferenceSlip: 'SLIP-CONTINGENCY-123',
      );

      expect(closing.handoverMethod, 'bank_deposit');
      expect(closing.isHandoverAccepted, isTrue);
      expect(closing.handoverOtp, isNull);
      expect(closing.bankAccountName, contains('Awash'));
      expect(state.pendingCashierHandover, isNull);
    });

    test('Cashier day closing with direct Admin OTP handover (when manager is absent) verifies via admin', () async {
      final closing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Admin / Owner',
        handoverMethod: 'admin_otp',
      );

      expect(closing.handoverMethod, 'admin_otp');
      expect(closing.isHandoverAccepted, isFalse);
      expect(closing.handoverOtp, isNotNull);
      expect(closing.handoverOtp!.length, 4);
      expect(state.pendingCashierHandover, isNull);
      expect(state.pendingCashierAdminHandover, isNotNull);

      // Wrong OTP fails
      final wrongAdmin = await state.acceptAdminHandover(
        adminName: 'Owner Admin',
        enteredOtp: '0000',
        shiftType: 'day',
      );
      expect(wrongAdmin, isFalse);
      expect(state.pendingCashierAdminHandover, isNotNull);

      // Correct OTP succeeds
      final correctAdmin = await state.acceptAdminHandover(
        adminName: 'Owner Admin',
        enteredOtp: closing.handoverOtp,
        shiftType: 'day',
      );
      expect(correctAdmin, isTrue);
      expect(state.pendingCashierAdminHandover, isNull);
    });

    test('Operational manager night closing combines day + night cash and verifies with admin OTP', () async {
      // 1. Manager closes night shift
      final nightClosing = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'night',
        closedByRole: 'manager',
        handoverTo: 'Admin / Owner',
      );

      expect(nightClosing.shiftType, 'night');
      expect(nightClosing.handoverMethod, 'admin_otp');
      expect(nightClosing.isHandoverAccepted, isFalse);
      expect(nightClosing.handoverOtp, isNotNull);
      expect(nightClosing.handoverOtp!.length, 4);
      expect(state.pendingAdminNightHandover, isNotNull);

      // 2. Admin attempts wrong OTP -> fails
      final wrongAdmin = await state.acceptAdminHandover(
        adminName: 'Owner Admin',
        enteredOtp: '9999',
      );
      expect(wrongAdmin, isFalse);
      expect(state.pendingAdminNightHandover, isNotNull);

      // 3. Admin enters exact OTP -> verified!
      final correctAdmin = await state.acceptAdminHandover(
        adminName: 'Owner Admin',
        enteredOtp: nightClosing.handoverOtp,
      );
      expect(correctAdmin, isTrue);
      expect(state.pendingAdminNightHandover, isNull);
    });

    test('Cashier unlocks pending day closing to add and wash more cars, then re-closes', () async {
      // 1. Cashier confirms day closing
      final closing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );
      expect(state.isTodayDayShiftClosed, isTrue);
      expect(state.pendingCashierHandover, isNotNull);

      // 2. A new car arrives; Cashier unlocks the pending closing
      final unlocked = await state.unlockDayShiftClosing();
      expect(unlocked, isTrue);
      expect(state.isTodayDayShiftClosed, isFalse);
      expect(state.pendingCashierHandover, isNull);

      // 3. Cashier can close again with new totals
      final reclosing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );
      expect(state.isTodayDayShiftClosed, isTrue);
      expect(reclosing.handoverOtp, isNotNull);
    });

    test('Cashier unlocks verified day closing, correctly reversing manager carried cash', () async {
      // 1. Cashier closes and manager accepts
      final closing = await state.confirmDailyClosing(
        cashierName: 'Meron Cashier',
        shiftType: 'day',
        closedByRole: 'cashier',
        handoverTo: 'Operational Manager',
        handoverMethod: 'manager_otp',
      );
      final accepted = await state.acceptCashierHandover(
        managerName: 'Dawit Manager',
        enteredOtp: closing.handoverOtp,
      );
      expect(accepted, isTrue);
      expect(state.managerCarriedCashETB, closing.handoverCashAmount);

      // 2. Unlock shift after manager took custody
      final unlocked = await state.unlockDayShiftClosing();
      expect(unlocked, isTrue);
      expect(state.isTodayDayShiftClosed, isFalse);
      // Carried cash reversed
      expect(state.managerCarriedCashETB, 0.0);
    });
  });
}
