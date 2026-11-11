import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/accountant_dashboard_screen.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';

class _SeededAuditRepository extends WashRepositoryImpl {
  final List<WashBooking> seededBookings;
  _SeededAuditRepository(this.seededBookings);

  @override
  Future<List<WashBooking>> getBookings() async => List.unmodifiable(seededBookings);
}

void main() {
  group('Online Booker Lifecycle, Shift Handover, Auto-Expiry & Postponement Audit', () {
    testWidgets('Customer LiveTrackingScreen shows Booking Approved, then Approved & Arrived progression', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();

      final booking = await state.bookNewWash(
        customerName: 'Abebe Online',
        customerPhone: '+251911223344',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'AA-90909',
        package: state.packages.first,
      );

      expect(booking.isOnlineBooking, isTrue);
      expect(booking.status, WashStatus.pending);
      expect(booking.status.localizedName('EN'), 'Booking Approved');
      expect(WashStatus.confirmed.localizedName('EN'), 'Approved & Arrived at Station');

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: LiveTrackingScreen(bookingId: booking.id)),
        ),
      );
      await tester.pumpAndSettle();

      // Header card + LiveWashStepper both show "Booking Approved" and NOT "Pending Approval"
      expect(find.text('Booking Approved'), findsAtLeastNWidgets(2));
      expect(find.text('Pending Approval'), findsNothing);
      expect(find.text('CURRENT'), findsOneWidget);
    });

    testWidgets('Cashier Queue has Online Bookers tab and follows Arrive -> Wash -> Dry -> Complete -> Pay', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
      state.switchRole(UserRole.cashier);

      final onlineCar = await state.bookNewWash(
        customerName: 'Online Customer',
        customerPhone: '+251911111111',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ON-11111',
        package: state.packages.first,
      );
      final walkInCar = await state.registerWalkIn(
        customerName: 'Gate Walk-In',
        licensePlate: 'WK-22222',
        customerPhone: '+251922222222',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );

      expect(onlineCar.isOnlineBooking, isTrue);
      expect(walkInCar.isOnlineBooking, isFalse);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Online Bookers filter chip isolates unarrived online reservations
      final onlineChipFinder = find.text('${state.tr("cashierFilterOnlineBookers")} (1)');
      expect(onlineChipFinder, findsOneWidget);
      await tester.tap(onlineChipFinder);
      await tester.pumpAndSettle();

      expect(find.text('ON-11111'), findsOneWidget);
      expect(find.text('WK-22222'), findsNothing);
      expect(find.text(state.tr('approveAndArrivedAction')), findsOneWidget);

      // Step 1: Approve & Arrived at Station
      await tester.ensureVisible(find.text(state.tr('approveAndArrivedAction')));
      await tester.tap(find.text(state.tr('approveAndArrivedAction')));
      await tester.pumpAndSettle();
      expect(state.bookings.firstWhere((b) => b.id == onlineCar.id).status, WashStatus.confirmed);

      // Switch to Arrived & Waiting (online booking now in arrived queue with Start Wash button)
      await tester.tap(find.text('${state.tr("cashierFilterWaiting")} (2)'));
      await tester.pumpAndSettle();
      expect(find.text('ON-11111'), findsOneWidget);
      expect(find.text(state.tr('startWashAction')), findsNWidgets(2));

      // Step 2: Start Wash on ON-11111 (second card, after newly inserted WK-22222 gate walk-in) -> Move to Drying -> Mark Completed -> Collect Payment
      await tester.ensureVisible(find.text(state.tr('startWashAction')).last);
      await tester.tap(find.text(state.tr('startWashAction')).last);
      await tester.pumpAndSettle();
      expect(state.bookings.firstWhere((b) => b.id == onlineCar.id).status, WashStatus.washing);

      await tester.tap(find.text('${state.tr("cashierFilterInProgress")} (1)'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(state.tr('moveToDryingAction')));
      await tester.tap(find.text(state.tr('moveToDryingAction')));
      await tester.pumpAndSettle();
      expect(state.bookings.firstWhere((b) => b.id == onlineCar.id).status, WashStatus.drying);

      await tester.ensureVisible(find.text(state.tr('markCompletedAction')));
      await tester.tap(find.text(state.tr('markCompletedAction')));
      await tester.pumpAndSettle();
      expect(state.bookings.firstWhere((b) => b.id == onlineCar.id).status, WashStatus.completed);

      await tester.tap(find.text('${state.tr("cashierFilterPayReady")} (1)'));
      await tester.pumpAndSettle();
      expect(find.textContaining(state.tr('collectPaymentAction')), findsOneWidget);
    });

    test('Day closing hands over open vehicles to Night Shift; Night closing deletes unarrived online no-shows only', () async {
      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();

      final unarrivedNoShow = await state.bookNewWash(
        customerName: 'No-Show Booker',
        customerPhone: '0911000001',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'NS-0001',
        package: state.packages.first,
      );
      final inProgressArrived = await state.bookNewWash(
        customerName: 'Arrived Washing',
        customerPhone: '0911000002',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'AR-0002',
        package: state.packages.first,
      );
      await state.approveOnlineBookingArrival(inProgressArrived.id);
      await state.updateWashStatus(inProgressArrived.id, WashStatus.washing);

      // Day Shift Closing (handover to Manager) auto-tags open vehicle + preserves unarrived online booking
      final dayClosing = await state.confirmDailyClosing(
        cashierName: 'Day Cashier',
        shiftType: 'day',
        handoverMethod: 'manager_otp',
      );
      expect(dayClosing.notes, contains('Handed over to Operational Manager (1): AR-0002'));
      expect(state.bookings.firstWhere((b) => b.id == inProgressArrived.id).isHandedOverToManager, isTrue);
      expect(state.bookings.any((b) => b.id == unarrivedNoShow.id), isTrue);
      expect(state.bookings.any((b) => b.id == inProgressArrived.id), isTrue);

      // Operational Manager postpones arrived unfinished vehicle to tomorrow morning before Night Closing
      await state.postponeBookingToNextDay(
        bookingId: inProgressArrived.id,
        reason: 'Customer pickup tomorrow',
        postponedByRole: 'Operational Manager',
      );
      final postponedCar = state.bookings.firstWhere((b) => b.id == inProgressArrived.id);
      expect(postponedCar.isPostponed, isTrue);
      expect(postponedCar.postponedReason, 'Customer pickup tomorrow');
      expect(postponedCar.postponedByRole, 'Operational Manager');

      // Night Shift Closing auto-deletes unarrived online no-show, preserves postponed arrived car!
      final nightClosing = await state.confirmDailyClosing(
        cashierName: 'Dawit Manager',
        shiftType: 'night',
        closedByRole: 'manager',
        handoverTo: 'Admin / Owner',
      );
      expect(nightClosing.notes, contains('Expired online no-shows cleared: 1'));
      expect(nightClosing.notes, contains('Postponed to next morning (1): AR-0002'));
      expect(state.bookings.any((b) => b.id == unarrivedNoShow.id), isFalse);
      expect(state.bookings.any((b) => b.id == inProgressArrived.id), isTrue);
    });

    testWidgets('Cashier Handover to Op Manager + Manager mandatory-reason Postpone + Accountant Custody Trail', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final state = AppStateNotifier(repository: WashRepositoryImpl());
      await state.loadData();
      state.switchRole(UserRole.cashier);

      final car = await state.registerWalkIn(
        customerName: 'Selamawit Handover',
        licensePlate: 'HO-77777',
        customerPhone: '+251933445566',
        carType: CarType.automobile,
        package: state.packages.first,
        assignedBay: BayType.bay1,
        paymentMethod: PaymentMethod.cash,
      );
      await state.updateWashStatus(car.id, WashStatus.washing);

      // 1. Cashier Queue no longer exposes "Handover to Operational Manager" or "Postpone to Next Day" buttons
      // because Cashier Day Shift closing automatically hands over open vehicles by default.
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(state.tr('handoverToOpManagerAction')), findsNothing);
      expect(find.text(state.tr('postponeNextDayAction')), findsNothing);

      // Cashier submits Day Closing (Manager OTP) -> automatically hands over open vehicle HO-77777 to Op Manager!
      await state.confirmDailyClosing(
        cashierName: 'Day Cashier',
        shiftType: 'day',
        handoverMethod: 'manager_otp',
      );

      final handed = state.bookings.firstWhere((b) => b.id == car.id);
      expect(handed.isHandedOverToManager, isTrue);
      expect(handed.handoverNote, 'Handed over at Day Shift closing');
      expect(handed.isPostponed, isFalse);
      expect(handed.status, WashStatus.washing);

      // 2. Switch to Operational Manager Dashboard
      state.switchRole(UserRole.manager);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Pending Cashier OTP card lists handed-over vehicle HO-77777; Queue shows FROM DAY CASHIER & hides Handover button
      expect(find.textContaining('HO-77777'), findsAtLeastNWidgets(2));
      expect(find.text(state.tr('fromDayCashierBadge')), findsOneWidget);
      expect(find.text(state.tr('handoverToOpManagerAction')), findsNothing);
      expect(find.text(state.tr('postponeNextDayAction')), findsOneWidget);

      // Manager taps Postpone to Next Day -> Empty reason MUST be blocked
      await tester.ensureVisible(find.text(state.tr('postponeNextDayAction')));
      await tester.tap(find.text(state.tr('postponeNextDayAction')));
      await tester.pumpAndSettle();

      await tester.tap(find.text(state.tr('confirm')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('postponeReasonRequiredError')), findsOneWidget);
      expect(state.bookings.firstWhere((b) => b.id == car.id).isPostponed, isFalse);

      // Manager enters valid reason -> Postpone succeeds & frees bay!
      await tester.enterText(find.byType(TextField).last, 'Water outage at night');
      await tester.tap(find.text(state.tr('confirm')));
      await tester.pumpAndSettle();

      final postponed = state.bookings.firstWhere((b) => b.id == car.id);
      expect(postponed.isPostponed, isTrue);
      expect(postponed.postponedByRole, 'Operational Manager');
      expect(postponed.postponedReason, 'Water outage at night');
      expect(postponed.assignedBay, isNull);
      expect(find.text(state.tr('postponedByManagerBadge')), findsOneWidget);

      // 3. Accountant Carry-Over Audit shows full Day Cashier -> Op. Manager -> Postponed by Op. Manager custody trail
      state.switchRole(UserRole.accountant);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AccountantDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.textContaining('Water outage at night'));
      expect(find.textContaining(state.tr('handoffCustodyArrow')), findsOneWidget);
      expect(find.textContaining('Operational Manager'), findsAtLeastNWidgets(1));
      expect(find.textContaining('Water outage at night'), findsOneWidget);
    });

    testWidgets('Postponed & Prepaid carry-over accounting attributes revenue by paidAt and shows in Accountant Audit', (tester) async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final pkg = WashRepositoryImpl().getPackages();
      final resolvedPkg = (await pkg).first;

      // 1. Created yesterday, postponed & paid TODAY -> must count in TODAY revenue!
      final paidTodayCarryOver = WashBooking(
        id: 'BSH-YEST-1',
        customerName: 'Yesterday Unpaid Client',
        customerPhone: '0911220001',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'YEST-PAID',
        package: resolvedPkg,
        status: WashStatus.completed,
        payment: PaymentInfo(isPaid: true, method: PaymentMethod.cash, amount: 500, paidAt: now),
        createdAt: yesterday,
        completedAt: now,
        isPostponed: true,
        postponedReason: 'Postponed to today',
      );

      // 2. Prepaid YESTERDAY, still Washing TODAY -> must NOT count in TODAY cash, MUST appear in carryOverAuditBookings!
      final prepaidYesterdayStillWashing = WashBooking(
        id: 'BSH-YEST-2',
        customerName: 'Prepaid Client',
        customerPhone: '0911220002',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'PRE-WASH',
        package: resolvedPkg,
        status: WashStatus.washing,
        payment: PaymentInfo(isPaid: true, method: PaymentMethod.cash, amount: 700, paidAt: yesterday),
        createdAt: yesterday,
        isPostponed: true,
        postponedReason: 'Finishing detail today',
      );

      final state = AppStateNotifier(repository: _SeededAuditRepository([paidTodayCarryOver, prepaidYesterdayStillWashing]));
      await state.loadData();
      state.switchRole(UserRole.accountant);

      expect(state.totalCashRevenueETB, 500.0);
      expect(state.totalRevenueTodayETB, 500.0);
      expect(state.carryOverAuditBookings.length, 1);
      expect(state.carryOverAuditBookings.first.licensePlate, 'PRE-WASH');

      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AccountantDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text(state.tr('carryOverAuditTitle')));
      expect(find.text(state.tr('carryOverAuditTitle')), findsOneWidget);
      expect(find.textContaining('PRE-WASH'), findsOneWidget);
    });

    test('Supabase booking [BOOKING_META] round-trip preserves online/postpone/handover/paidAt fields', () {
      final now = DateTime.now();
      final encoded = SupabaseWashRepositoryImpl.encodeDeliveryLocationWithMeta(
        baseText: 'Services: Wax, Interior',
        isOnlineBooking: true,
        isPostponed: true,
        postponedReason: 'Morning pickup',
        postponedAt: now,
        postponedByRole: 'Operational Manager',
        isHandedOverToManager: true,
        handedOverBy: 'Meron Cashier',
        handoverNote: 'Wax finished',
        handedOverAt: now,
        paidAt: now,
      );
      expect(SupabaseWashRepositoryImpl.extractCleanDeliveryLocation(encoded), 'Services: Wax, Interior');
      final decoded = SupabaseWashRepositoryImpl.decodeBookingMeta(encoded);
      expect(decoded['isOnline'], isTrue);
      expect(decoded['isPostponed'], isTrue);
      expect(decoded['postponedReason'], 'Morning pickup');
      expect(decoded['postponedByRole'], 'Operational Manager');
      expect(decoded['isHandedOverToManager'], isTrue);
      expect(decoded['handedOverBy'], 'Meron Cashier');
      expect(decoded['handoverNote'], 'Wax finished');
      expect(DateTime.tryParse(decoded['handedOverAt'] as String), isNotNull);
      expect(DateTime.tryParse(decoded['paidAt'] as String), isNotNull);
    });

    test('All new & updated trilingual workflow keys are complete and distinct in EN, OM, AM', () {
      const keys = [
        'statusPending',
        'statusConfirmed',
        'cashierFilterOnlineBookers',
        'onlineBookingBadge',
        'approveAndArrivedAction',
        'postponeNextDayAction',
        'postponedCarryOverBadge',
        'prepaidFinishWashBadge',
        'postponeDialogTitle',
        'postponeDialogDesc',
        'postponeReasonHint',
        'postponedSuccessMsg',
        'openVehiclesHandoverTitle',
        'openVehiclesHandoverDesc',
        'autoClearNoShowsNotice',
        'unarrivedNoShowsClearedLabel',
        'carryOverAuditTitle',
        'carryOverAuditSub',
        'noCarryOverVehicles',
        'stepApprovedDesc',
        'stepArrivedDesc',
        'handoverToOpManagerAction',
        'handedOverToManagerBadge',
        'fromDayCashierBadge',
        'postponedByManagerBadge',
        'handoverDialogTitle',
        'handoverDialogDesc',
        'handoverNoteHint',
        'handoverSuccessMsg',
        'postponeReasonRequiredError',
        'postponeReasonRequiredLabel',
        'handedOverVehiclesTitle',
        'postponedByLabel',
        'custodyChainLabel',
        'handoffCustodyArrow',
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
