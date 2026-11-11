import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/core/utils/receipt_image_helper.dart';
import 'package:bishe_car_wash/core/widgets/service_location_picker_card.dart';
import 'package:bishe_car_wash/core/widgets/shared_washer_commission_hub.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/supabase_wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/screens/financial_reports_view.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/daily_closing_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/phone_booking_dialog.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';

const _samplePngDataUrl =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

void main() {
  late AppStateNotifier state;

  setUp(() async {
    state = AppStateNotifier(repository: WashRepositoryImpl());
    await state.loadData();
  });

  group('Service Delivery Options, Exact Home Location & Live GPS', () {
    testWidgets('CustomerHomeScreen stays clean 2-button Option 1 hub and NewBookingScreen Step 2 presents all 3 isolated delivery options', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CustomerHomeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Home stays clean Option 1 hub (delivery choices moved purely into Step 2 of booking)
      expect(find.text(state.tr('washMyCarTitle')), findsOneWidget);
      expect(find.text(state.tr('chooseDeliveryQuick')), findsNothing);
      expect(find.text(state.tr('washMyCarpetTitle')), findsNothing);

      // Tap Car CTA -> Step 1 -> Step 2 shows all 3 Car delivery modes
      await tester.tap(find.text(state.tr('startCarBooking')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(state.tr('nextStep')));
      await tester.tap(find.text(state.tr('nextStep')));
      await tester.pumpAndSettle();

      expect(find.text(state.tr('driveInStation')), findsOneWidget);
      expect(find.text(state.tr('atHomeMobile')), findsOneWidget);
      expect(find.text(state.tr('serviceValetPickUp')), findsOneWidget);
      expect(find.text(state.tr('carpetStationService')), findsNothing);

      // Carpet guided flow Step 2 shows all 3 Carpet delivery modes with zero Car text
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            key: const ValueKey('carpet-step2-app'),
            theme: AppTheme.lightTheme,
            home: const NewBookingScreen(isCarpet: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text(state.tr('nextStep')));
      await tester.tap(find.text(state.tr('nextStep')));
      await tester.pumpAndSettle();

      expect(find.text(state.tr('carpetStationService')), findsOneWidget);
      expect(find.text(state.tr('carpetHomeTitle')), findsOneWidget);
      expect(find.text(state.tr('carpetValetTitle')), findsOneWidget);
      expect(find.text(state.tr('driveInStation')), findsNothing);
    });

    testWidgets('PhoneBookingDialog shows 3 full delivery options & reveals exact address + live GPS for Home Van / VIP', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: PhoneBookingDialog()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(state.tr('driveInStation')), findsOneWidget);
      expect(find.text(state.tr('atHomeMobile')), findsOneWidget);
      expect(find.text(state.tr('serviceValetPickUp')), findsOneWidget);
      expect(find.byType(ServiceLocationPickerCard), findsNothing);

      await tester.ensureVisible(find.text(state.tr('atHomeMobile')));
      await tester.tap(find.text(state.tr('atHomeMobile')));
      await tester.pumpAndSettle();

      expect(find.byType(ServiceLocationPickerCard), findsOneWidget);
      expect(find.text(state.tr('exactHomePlaceLabel')), findsOneWidget);
      expect(find.text(state.tr('liveGpsLocatorBtn')), findsOneWidget);
      expect(find.text(state.tr('gpsCoordinatesLabel')), findsOneWidget);

      await tester.ensureVisible(find.text(state.tr('serviceValetPickUp')));
      await tester.tap(find.text(state.tr('serviceValetPickUp')));
      await tester.pumpAndSettle();
      expect(find.byType(ServiceLocationPickerCard), findsOneWidget);
    });

    testWidgets('NewBookingScreen Step 2 displays ServiceLocationPickerCard with Live GPS for VIP Driver', (tester) async {
      tester.view.physicalSize = const Size(440, 960);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const NewBookingScreen(initialServiceType: ServiceType.valetPickUp),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Advance from Step 1 -> Step 2
      await tester.ensureVisible(find.text('Next Step'));
      await tester.tap(find.text('Next Step'));
      await tester.pumpAndSettle();

      expect(find.text(state.tr('serviceValetPickUp')), findsAtLeastNWidgets(1));
      expect(find.byType(ServiceLocationPickerCard), findsOneWidget);
      expect(find.text(state.tr('liveGpsLocatorBtn')), findsOneWidget);
    });

    test('SupabaseWashRepositoryImpl [BOOKING_META] round-trip preserves GPS coordinates', () {
      final encoded = SupabaseWashRepositoryImpl.encodeDeliveryLocationWithMeta(
        baseText: 'Kebele 04, Villa 12',
        isOnlineBooking: false,
        isPostponed: false,
        gpsCoordinates: '8.75230, 38.97850',
      );
      expect(SupabaseWashRepositoryImpl.extractCleanDeliveryLocation(encoded), 'Kebele 04, Villa 12');
      final decoded = SupabaseWashRepositoryImpl.decodeBookingMeta(encoded);
      expect(decoded['gps'], '8.75230, 38.97850');
    });
  });

  group('Conditional OTP Handover Visibility & Night Shift Expiry', () {
    testWidgets('OTP banner never shows before request, shows only to recipient role, and disappears immediately upon verification', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 1. Before any handover request -> zero OTP/handover cards anywhere on Admin, Manager, or Cashier Money Tab!
      expect(state.pendingCashierHandover, isNull);
      expect(state.pendingCashierAdminHandover, isNull);
      expect(state.pendingAdminNightHandover, isNull);

      state.switchRole(UserRole.cashier);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(find.textContaining(state.tr('shiftHandoverMethodTitle')), findsNothing);
      expect(find.text(state.tr('confirmDailyClosingOtp')), findsNothing);

      state.switchRole(UserRole.manager);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Money & Closing ('), findsOneWidget);
      expect(find.textContaining('Handover & Close'), findsNothing);
      expect(find.text(state.tr('acceptCashierHandover')), findsNothing);
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('cashierHandoverTitle')), findsNothing);
      expect(find.text(state.tr('nightClosingSubDesc')), findsNothing);

      state.switchRole(UserRole.admin);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(body: DailyClosingDialog(isManagerClosing: false)),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Handover to Operational Manager'), findsNothing);
      expect(find.text(state.tr('handoverToManagerOption')), findsOneWidget);
      expect(find.text(state.tr('handoverToAdminOption')), findsOneWidget);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('confirmCashierHandover')), findsNothing);
      expect(find.text(state.tr('confirmManagerNightCash')), findsNothing);

      // 2. Cashier sends Manager OTP handover -> visible on Manager ONLY, NOT Admin!
      final closing = await state.confirmDailyClosing(
        cashierName: 'Day Cashier',
        shiftType: 'day',
        handoverMethod: 'manager_otp',
      );
      expect(closing.handoverOtp, isNotNull);
      expect(state.pendingCashierHandover, isNotNull);
      expect(state.pendingCashierAdminHandover, isNull);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('confirmCashierHandover')), findsNothing);

      state.switchRole(UserRole.manager);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('acceptCashierHandover')), findsOneWidget);
      expect(find.text(state.tr('verifyAndTakeCustody')), findsOneWidget);

      // 3. Manager verifies exact OTP -> disappears immediately on BOTH Manager & Cashier + no custody card remains on Money Tab
      await tester.enterText(find.byType(TextField).first, closing.handoverOtp!);
      await tester.tap(find.text(state.tr('verifyAndTakeCustody')));
      await tester.pumpAndSettle();

      expect(state.pendingCashierHandover, isNull);
      expect(find.text(state.tr('acceptCashierHandover')), findsNothing);
      expect(find.text(state.tr('handoverVerifiedTitle')), findsNothing);
      await tester.tap(find.byType(Tab).at(1));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('cashierHandoverTitle')), findsNothing);
      expect(find.text(state.tr('nightClosingSubDesc')), findsNothing);

      state.switchRole(UserRole.cashier);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const CashierDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(closing.handoverOtp!), findsNothing);

      // 4. Cashier sends Admin OTP -> visible on Admin & Cashier, hidden on Manager -> Admin verifies -> disappears on BOTH + clears closing alert!
      final adminDayClosing = await state.confirmDailyClosing(
        cashierName: 'Day Cashier',
        shiftType: 'day',
        handoverMethod: 'admin_otp',
      );
      expect(adminDayClosing.handoverOtp, isNotNull);

      state.switchRole(UserRole.manager);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(key: const ValueKey('mgr-admin-otp'), theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('acceptCashierHandover')), findsNothing);

      state.switchRole(UserRole.admin);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(key: const ValueKey('adm-day-otp'), theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('confirmCashierHandover')), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, adminDayClosing.handoverOtp!);
      await tester.tap(find.text(state.tr('confirmCashierHandover')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('confirmCashierHandover')), findsNothing);
      expect(state.hasNewCashierClosingAlert, isFalse);

      // 5. Manager submits Night Closing -> Night OTP visible on Manager & Admin -> Admin verifies -> disappears on BOTH!
      final nightClosing = await state.confirmDailyClosing(
        cashierName: 'Night Manager',
        shiftType: 'night',
        closedByRole: 'manager',
      );
      expect(nightClosing.handoverOtp, isNotNull);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(key: const ValueKey('adm-night-otp'), theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('confirmManagerNightCash')), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, nightClosing.handoverOtp!);
      await tester.tap(find.text(state.tr('confirmManagerNightCash')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('confirmManagerNightCash')), findsNothing);

      state.switchRole(UserRole.manager);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(key: const ValueKey('mgr-after-night'), theme: AppTheme.lightTheme, home: const OperationalManagerDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining(nightClosing.handoverOtp!), findsNothing);
    });

    test('Night Closing cancels both unarrived online and unarrived phone pending bookings', () async {
      final onlineUnarrived = await state.bookNewWash(
        customerName: 'Online User',
        customerPhone: '0911110001',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'ONL-UNARR',
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
      );
      final phoneUnarrived = await state.bookNewWash(
        customerName: 'Phone User',
        customerPhone: '0911110002',
        serviceType: ServiceType.walkInStation,
        carType: CarType.automobile,
        licensePlate: 'PHN-UNARR',
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        isPhoneBooking: true,
      );

      expect(state.unarrivedOnlineBookingsToday.length, 2);

      await state.confirmDailyClosing(
        cashierName: 'Night Manager',
        shiftType: 'night',
        closedByRole: 'manager',
      );

      expect(state.bookings.any((b) => b.id == onlineUnarrived.id), isFalse);
      expect(state.bookings.any((b) => b.id == phoneUnarrived.id), isFalse);
    });
  });

  group('Admin Filters, Tabular Financial Reports, Matrix & Digital Receipts', () {
    testWidgets('FinancialReportsView renders dynamic consolidated titles & tables without Payroll Policy or Commission Report', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const FinancialReportsView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(state.tr('consolidatedDailyTitle')), findsAtLeastNWidgets(1));
      expect(find.text(state.tr('pnlStatementTitle')), findsOneWidget);
      expect(find.byType(DataTable), findsAtLeastNWidgets(2));
      expect(find.text(state.tr('weeklyCommissionReport')), findsNothing);
      expect(find.text(state.tr('washerPayrollTitle')), findsNothing);

      // Tap This Week -> dynamic title updates to Weekly
      await tester.ensureVisible(find.text(state.tr('filterThisWeek')));
      await tester.tap(find.text(state.tr('filterThisWeek')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('consolidatedWeeklyTitle')), findsAtLeastNWidgets(1));

      // Tap This Month -> dynamic title updates to Monthly
      await tester.ensureVisible(find.text(state.tr('filterThisMonth')));
      await tester.tap(find.text(state.tr('filterThisMonth')));
      await tester.pumpAndSettle();
      expect(find.text(state.tr('consolidatedMonthlyTitle')), findsAtLeastNWidgets(1));

      // Embedded custom range test
      final customStart = DateTime(2026, 11, 1);
      final customEnd = DateTime(2026, 11, 5);
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: FinancialReportsView(
              key: const ValueKey('custom-reports'),
              initialFilter: FinancialReportFilter.customRange,
              initialCustomRange: DateTimeRange(start: customStart, end: customEnd),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1/11/2026 - 5/11/2026'), findsAtLeastNWidgets(1));

      // Cashier embedded mode (325px width inside CashierDashboard Money tab) hides P&L & Net Profit cleanly without overflow
      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: const Scaffold(
              body: SizedBox(
                width: 325,
                child: SingleChildScrollView(
                  child: FinancialReportsView(
                    key: ValueKey('cashier-embedded'),
                    isEmbedded: true,
                    isCashierMode: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(state.tr('pnlStatementTitle')), findsNothing);
      expect(find.text(state.tr('netStationProfit')), findsNothing);
    });

    testWidgets('SharedWasherCommissionHub renders Mon-Sun DataTable with A for absent and daily ETB for present', (tester) async {
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // Register & pay a car wash today so present washers earn > 0 ETB commission
      final b = await state.registerWalkIn(
        customerName: 'Matrix Car',
        licensePlate: 'MTX-101',
        customerPhone: '0911223344',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.cash,
        customTotalPrice: 1000,
      );
      await state.updateWashStatus(b.id, WashStatus.completed);
      await state.processPayment(bookingId: b.id, method: PaymentMethod.cash, amount: 1000);

      // Mark first washer absent today
      final firstWasher = state.availableWashers.first;
      state.setWasherAttendance(firstWasher.id, false);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(
            theme: AppTheme.lightTheme,
            home: Scaffold(
              body: SingleChildScrollView(
                child: SharedWasherCommissionHub(
                  state: state,
                  role: WasherHubRole.admin,
                  isMobile: true,
                  initiallyExpanded: true,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must render as DataTable even on mobile width (375)
      expect(find.byType(DataTable), findsAtLeastNWidgets(1));
      expect(find.text(state.tr('weeklyTotalLabel')), findsOneWidget);
      // Absent washer shows 'A'
      expect(find.text('A'), findsAtLeastNWidgets(1));
    });

    testWidgets('ReceiptImageHelper decodes Base64 Data URL and Admin Customers Tab displays Digital Receipt image', (tester) async {
      final decoded = ReceiptImageHelper.tryDecodeBytes(_samplePngDataUrl);
      expect(decoded, isNotNull);
      expect(decoded!.isNotEmpty, isTrue);

      final b = await state.registerWalkIn(
        customerName: 'Telebirr Receipt Client',
        licensePlate: 'RCP-909',
        customerPhone: '0911889900',
        carType: CarType.automobile,
        package: state.packages.first,
        paymentMethod: PaymentMethod.telebirr,
        customTotalPrice: 500,
      );
      await state.updateWashStatus(b.id, WashStatus.completed);
      await state.processPayment(
        bookingId: b.id,
        method: PaymentMethod.telebirr,
        amount: 500,
        receiptScreenshot: _samplePngDataUrl,
      );

      state.switchRole(UserRole.admin);
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        AppStateProvider(
          notifier: state,
          child: MaterialApp(theme: AppTheme.lightTheme, home: const AdminDashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 0 has date filters & P&L without KPI grid / Shift Handover Desk
      expect(find.text(state.tr('filterThisWeek')), findsOneWidget);
      expect(find.text(state.tr('filterThisMonth')), findsOneWidget);
      expect(find.text(state.tr('filterCustomRange')), findsOneWidget);
      expect(find.text(state.tr('cashierHandoverTitle')), findsNothing);

      // Switch to Tab 2 (Customers & Ads)
      await tester.tap(find.byType(Tab).at(2));
      await tester.pumpAndSettle();

      expect(find.textContaining('RCP-909'), findsOneWidget);
      // Inline receipt thumbnail should render an Image.memory widget
      expect(
        find.byWidgetPredicate((w) => w is Image && w.image is MemoryImage),
        findsAtLeastNWidgets(1),
      );
    });
  });

  test('All new trilingual keys exist and are distinct in EN, OM, AM', () {
    const newKeys = [
      'exactHomePlaceLabel',
      'exactHomePlaceHint',
      'liveGpsLocatorBtn',
      'liveGpsFetching',
      'gpsCoordinatesLabel',
      'gpsUnavailableMsg',
      'phoneIntakeDeliverySub',
      'deliveryModeRequiredAddress',
      'chooseDeliveryQuick',
      'consolidatedDailyTitle',
      'consolidatedWeeklyTitle',
      'consolidatedMonthlyTitle',
      'consolidatedCustomPrefix',
      'consolidatedCustomSuffix',
      'divisionSummaryTableTitle',
      'paymentSummaryTableTitle',
      'categoryColLabel',
      'countColLabel',
      'amountColLabel',
      'weeklyTotalLabel',
      'driveInStation',
      'driveInSub',
      'atHomeMobile',
      'atHomeSub',
      'serviceValetPickUp',
      'serviceValetPickUpSub',
      'reconcileAndCloseShift',
      'carpetDeliveryOptionsTitle',
      'carpetTrustFooter',
      'dayShiftClosingSubtitle',
      'remainingCashInDrawerLabel',
      'sendManagerOtpSub',
    ];

    for (final k in newKeys) {
      final en = AppStrings.get(k, AppLanguage.en);
      final om = AppStrings.get(k, AppLanguage.om);
      final am = AppStrings.get(k, AppLanguage.am);
      expect(en, isNot(equals(k)), reason: 'Missing EN for $k');
      expect(om, isNot(equals(k)), reason: 'Missing OM for $k');
      expect(om, isNot(equals(en)), reason: 'Untranslated OM for $k');
      expect(am, isNot(equals(k)), reason: 'Missing AM for $k');
      expect(am, isNot(equals(en)), reason: 'Untranslated AM for $k');
    }
  });
}
