import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/admin/domain/models/daily_financial_closing.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/daily_closing_dialog.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';

class _MissingOtpClosingRepository extends WashRepositoryImpl {
  @override
  Future<List<DailyFinancialClosing>> getDailyFinancialClosings() async {
    final now = DateTime.now();
    return [
      DailyFinancialClosing(
        id: 'closing-${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-night',
        closingDate: now,
        closedAt: now,
        cashierName: 'Dawit Manager',
        grossRevenue: 1000,
        cashRevenue: 1000,
        digitalRevenue: 0,
        providerBreakdown: const {'Cash': 1000},
        carsWashedCount: 2,
        commissionPool: 150,
        netStationProfit: 850,
        cashDeposited: 0,
        pettyCashExpenses: 0,
        cashRemaining: 1000,
        washerDividends: const {'Abebe': 150},
        shiftType: 'night',
        closedByRole: 'manager',
        handoverTo: 'Admin / Owner',
        handoverCashAmount: 1000,
        isHandoverAccepted: false,
        handoverMethod: 'admin_otp',
        handoverOtp: null, // Simulates missing/empty OTP from stale DB row
      ),
    ];
  }
}

void main() {
  group('Requirement 1: Strict Daily Commission Prerequisite Before Closing', () {
    late AppStateNotifier state;

    setUp(() async {
      state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
    });

    test('Tracks undisbursed commission pool across Day & Night washes and resets cleanly', () async {
      final b1 = await state.registerWalkIn(
        customerName: 'Day Driver',
        licensePlate: 'OR-10101',
        customerPhone: '0911111111',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 1000,
      );
      await state.updateWashStatus(b1.id, WashStatus.completed);
      await state.processPayment(bookingId: b1.id, method: PaymentMethod.cash, amount: 1000);

      expect(state.teamCommissionPoolTodayETB, 150.0);
      expect(state.requiresDailyCommissionDisbursementBeforeClosing, isTrue);

      state.markDailyCommissionDisbursed();
      expect(state.isDailyCommissionDisbursedToday, isTrue);
      expect(state.requiresDailyCommissionDisbursementBeforeClosing, isFalse);

      // Extra night-shift wash accrues additional commission -> re-requires disbursement
      final b2 = await state.registerWalkIn(
        customerName: 'Night Driver',
        licensePlate: 'OR-20202',
        customerPhone: '0922222222',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 500,
      );
      await state.updateWashStatus(b2.id, WashStatus.completed);
      await state.processPayment(bookingId: b2.id, method: PaymentMethod.cash, amount: 500);

      expect(state.teamCommissionPoolTodayETB, 225.0);
      expect(state.undisbursedCommissionPoolTodayETB, 75.0);
      expect(state.requiresDailyCommissionDisbursementBeforeClosing, isTrue);

      state.markDailyCommissionDisbursed();
      expect(state.requiresDailyCommissionDisbursementBeforeClosing, isFalse);

      await state.clearAllBookings();
      expect(state.isDailyCommissionDisbursedToday, isFalse);
      expect(state.requiresDailyCommissionDisbursementBeforeClosing, isFalse);
    });

    testWidgets('Cashier closing action shows strict prerequisite modal until commissions disbursed', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      state.switchRole(UserRole.cashier);
      final car = await state.registerWalkIn(
        customerName: 'Test Car',
        licensePlate: 'AA-77889',
        customerPhone: '0911001100',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 400,
      );
      await state.updateWashStatus(car.id, WashStatus.completed);
      await state.processPayment(bookingId: car.id, method: PaymentMethod.cash, amount: 400);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Open Money tab -> tap Closing button -> strict prerequisite prompt appears
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(state.tr('confirmDailyClosingOtp')));
      await tester.tap(find.text(state.tr('confirmDailyClosingOtp')));
      await tester.pumpAndSettle();

      expect(find.text(state.tr('commissionDisburseRequiredTitle')), findsWidgets);
      expect(find.text(state.tr('commissionDisburseRequiredDesc')), findsOneWidget);
      expect(find.byType(DailyClosingDialog), findsNothing);
      expect(state.isTodayDayShiftClosed, isFalse);

      // Tap "Disburse Pool Now & Unlock Closing" -> disburses and opens Closing Dialog
      await tester.tap(find.text(state.tr('disburseNowAndUnlockClosing')));
      await tester.pumpAndSettle();

      expect(state.isDailyCommissionDisbursedToday, isTrue);
      expect(find.byType(DailyClosingDialog), findsOneWidget);
    });

    testWidgets('Night Shift DailyClosingDialog strictly locks confirm button until disbursed', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      state.switchRole(UserRole.manager);
      final car = await state.registerWalkIn(
        customerName: 'Evening SUV',
        licensePlate: 'AA-55667',
        customerPhone: '0911223344',
        carType: CarType.minibus,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 600,
      );
      await state.updateWashStatus(car.id, WashStatus.completed);
      await state.processPayment(bookingId: car.id, method: PaymentMethod.cash, amount: 600);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: DailyClosingDialog(isManagerClosing: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Strictly locked before disbursement
      expect(find.text(state.tr('commissionDisburseRequiredTitle')), findsNWidgets(2));
      expect(state.isTodayNightShiftClosed, isFalse);

      // Disburse in-dialog -> unlocks closing button -> confirm night closing
      await tester.ensureVisible(find.text(state.tr('disburseNowAndUnlockClosing')));
      await tester.tap(find.text(state.tr('disburseNowAndUnlockClosing')));
      await tester.pumpAndSettle();

      expect(state.isDailyCommissionDisbursedToday, isTrue);
      await tester.ensureVisible(find.text(state.tr('confirmDailyClosing')));
      expect(find.text(state.tr('confirmDailyClosing')), findsOneWidget);
    });
  });

  group('Requirement 2: Strict Fail-Closed OTP Verification & Cloud Meta Persistence', () {
    test('Rejects any OTP when stored handoverOtp is null/empty (no auto-approval)', () async {
      final state = AppStateNotifier(repository: _MissingOtpClosingRepository());
      await state.loadData();

      expect(state.pendingAdminNightHandover, isNotNull);
      expect(state.pendingAdminNightHandover!.handoverOtp, isNull);

      final wrongAttempt = await state.acceptAdminHandover(
        adminName: 'Admin Owner',
        enteredOtp: '0000',
        shiftType: 'night',
      );
      expect(wrongAttempt, isFalse);
      expect(state.pendingAdminNightHandover, isNotNull);

      final blankAttempt = await state.acceptAdminHandover(
        adminName: 'Admin Owner',
        enteredOtp: '',
        shiftType: 'night',
      );
      expect(blankAttempt, isFalse);
      expect(state.pendingAdminNightHandover, isNotNull);
    });

    test('Supabase closing [HANDOVER_META] notes encoding preserves OTP & custody metadata round-trip', () {
      final now = DateTime.now();
      final original = DailyFinancialClosing(
        id: 'closing-2026-11-10-night',
        closingDate: now,
        closedAt: now,
        cashierName: 'Dawit Manager',
        grossRevenue: 1500,
        cashRevenue: 900,
        digitalRevenue: 600,
        providerBreakdown: const {'Cash': 900, 'Telebirr': 600},
        carsWashedCount: 3,
        carpetsCleanedCount: 1,
        carpetRevenue: 400,
        showerUsersCount: 2,
        showerRevenue: 200,
        totalTipsAmount: 50,
        commissionPool: 225,
        netStationProfit: 1275,
        cashDeposited: 100,
        pettyCashExpenses: 50,
        cashRemaining: 750,
        washerDividends: const {'Abebe': 225},
        notes: 'Shift balanced cleanly',
        shiftType: 'night',
        closedByRole: 'manager',
        handoverTo: 'Admin / Owner',
        handoverCashAmount: 750,
        carriedCashAmount: 300,
        isHandoverAccepted: false,
        handoverMethod: 'admin_otp',
        handoverOtp: '7492',
      );

      final encoded = SupabaseWashRepositoryImpl.encodeClosingNotesWithMeta(original);
      expect(SupabaseWashRepositoryImpl.extractCleanNotes(encoded), 'Shift balanced cleanly');

      final baseFromDbRow = DailyFinancialClosing(
        id: original.id,
        closingDate: now,
        closedAt: now,
        cashierName: original.cashierName,
        grossRevenue: original.grossRevenue,
        cashRevenue: original.cashRevenue,
        digitalRevenue: original.digitalRevenue,
        providerBreakdown: original.providerBreakdown,
        carsWashedCount: original.carsWashedCount,
        commissionPool: original.commissionPool,
        netStationProfit: original.netStationProfit,
        cashDeposited: original.cashDeposited,
        pettyCashExpenses: original.pettyCashExpenses,
        cashRemaining: original.cashRemaining,
        washerDividends: original.washerDividends,
        notes: SupabaseWashRepositoryImpl.extractCleanNotes(encoded),
        shiftType: 'night',
      );

      final hydrated = SupabaseWashRepositoryImpl.applyHandoverMetaToClosing(baseFromDbRow, encoded);
      expect(hydrated.handoverOtp, '7492');
      expect(hydrated.handoverCashAmount, 750);
      expect(hydrated.carriedCashAmount, 300);
      expect(hydrated.handoverMethod, 'admin_otp');
      expect(hydrated.isHandoverAccepted, isFalse);
      expect(hydrated.notes, 'Shift balanced cleanly');
      expect(hydrated.carpetRevenue, 400);
      expect(hydrated.showerRevenue, 200);
    });

    testWidgets('Admin UI rejects wrong Night OTP and accepts only exact 4-digit OTP', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
      state.switchRole(UserRole.admin);

      final closing = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'night',
        closedByRole: 'manager',
        handoverTo: 'Admin / Owner',
      );
      expect(closing.handoverOtp, isNotNull);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Wrong OTP '0000' -> strictly rejected
      final otpField = find.byType(TextField).first;
      await tester.enterText(otpField, '0000');
      await tester.tap(find.text(state.tr('confirmManagerNightCash')));
      await tester.pumpAndSettle();

      expect(state.pendingAdminNightHandover, isNotNull);
      expect(find.text(state.tr('invalidOtpCode')), findsOneWidget);

      // Exact OTP -> accepted!
      await tester.enterText(otpField, closing.handoverOtp!);
      await tester.tap(find.text(state.tr('confirmManagerNightCash')));
      await tester.pumpAndSettle();

      expect(state.pendingAdminNightHandover, isNull);
      expect(state.latestNightClosing?.isHandoverAccepted, isTrue);
    });
  });

  group('Requirement 3 & 4: Operational Manager Mirror & Streamlined Admin 3-Tab Desk', () {
    testWidgets('Operational Manager mirrors Cashier Money Tab fields without Station Shower', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
      state.switchRole(UserRole.manager);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Tab 1 (Money & Handover)
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();

      expect(find.text(state.tr('physicalCashInDrawer')), findsOneWidget);
      expect(find.text(state.tr('depositCashToBank')), findsOneWidget);
      expect(find.text(state.tr('logPettyCash')), findsOneWidget);
      expect(find.text(state.tr('digitalMoneyTransfer')), findsOneWidget);
      expect(find.text(state.tr('dailyFinancialReportsTab')), findsOneWidget);
      expect(find.text(state.tr('dayShiftHandoverCashLabel')), findsOneWidget);
      expect(find.text(state.tr('stationShowerService')), findsNothing);

      // Switch to Tab 2 (Team) -> Washer hub visible, Station Shower absent
      await tester.tap(find.byType(Tab).at(2));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('markAllPresent')), findsOneWidget);
      expect(find.text(state.tr('stationShowerService')), findsNothing);
    });

    testWidgets('Streamlined 3-Tab Admin renders cleanly on mobile without Secondary Admin badge leaks', (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
      state.switchRole(UserRole.admin); // Non-Super Admin

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly 3 streamlined tabs
      expect(find.byType(Tab), findsNWidgets(3));
      expect(find.text(state.tr('adminTabOverviewCash')), findsOneWidget);
      expect(find.text(state.tr('secondaryAdminRoleBadge')), findsOneWidget);
      expect(find.text(state.tr('superAdminRoleBadge')), findsNothing);
      expect(find.text(state.tr('pnlStatementTitle')), findsOneWidget);

      // Tab 1: Pricing & Team
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('masterPricingAndInventory')), findsOneWidget);
      expect(find.text(state.tr('clearAllBookings')), findsNothing); // Hidden for Secondary Admin
      expect(find.text(state.tr('weeklyCommissionReport')), findsOneWidget);

      // Tab 2: Customers & Ads
      await tester.tap(find.byType(Tab).at(2));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('digitalReceiptsTitle')), findsOneWidget);
      expect(find.text(state.tr('smsAndHotlineTitle')), findsOneWidget);
      expect(find.text(state.tr('tiktokReelsCardTitle')), findsOneWidget);
    });

    test('All new trilingual localization keys exist and are distinct in EN, OM, AM', () {
      const newKeys = [
        'commissionDisburseRequiredTitle',
        'commissionDisburseRequiredDesc',
        'goToTeamAndDisburse',
        'disburseNowAndUnlockClosing',
        'remainingCommissionPool',
        'enterFourDigitManagerOtpError',
        'otpMissingOrCorruptError',
        'adminTabOverviewCash',
        'adminTabPricingTeam',
        'adminTabCustomersAds',
        'superAdminRoleBadge',
        'secondaryAdminRoleBadge',
        'filterByDate',
        'executiveMetricsTitle',
        'netMarginLabel',
        'digitalVsCashLabel',
        'washerCrewAttendanceLabel',
        'onDutyCountLabel',
        'totalWashersLabel',
        'teamPoolLabel',
        'pnlStatementTitle',
        'pnlStatementSub',
        'profitableBadge',
        'deficitBadge',
        'grossRevenueRow',
        'cogsRow',
        'washerCommissionSub',
        'consumablesSub',
        'grossOperatingProfitRow',
        'opexRow',
        'pettyCashOpexSub',
        'netOperatingProfitRow',
        'salaryReserveRow',
        'netRetainedProfitRow',
        'washHistoryAuditDesc',
        'financialReportsAuditDesc',
        'editTariffsInventorySub',
        'dailyTodayFilter',
        'weeklyReportFilter',
        'periodReportFilter',
        'pendingDayOtpBadge',
        'reconciledBadge',
        'dayShiftActiveBadge',
        'pendingVaultSealBadge',
        'sealedInVaultBadge',
        'nightShiftActiveBadge',
        'secondaryApprovalsAwaiting',
        'submittedForSuperApproval',
        'approveAction',
        'rejectAction',
        'pendingReviewBadge',
        'smsAndHotlineTitle',
        'hotlineBookingLabel',
        'cashierSmsPhoneLabel',
        'updateAction',
        'tiktokReelsCardTitle',
        'manageReelsBtn',
        'reelsActiveSuffix',
      ];

      for (final key in newKeys) {
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
