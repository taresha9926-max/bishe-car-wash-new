import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/presentation/screens/role_shell_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/entrance_splash_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/booking_history_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/walk_in_registration_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/edit_booking_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/payment_process_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/phone_booking_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/daily_closing_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/petty_cash_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/bank_deposit_dialog.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/bay_assignment_modal.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/weekly_commission_report_dialog.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';
import 'package:bishe_car_wash/features/inventory/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/accountant_dashboard_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/pricing_management_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/staff_management_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/commission_logs_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/credentials_management_screen.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/screens/vehicle_history_screen.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/screens/financial_reports_view.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/admin/presentation/widgets/bishe_ai_executive_sheet.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppStateNotifier notifier;

  setUp(() async {
    notifier = AppStateNotifier(repository: WashRepositoryImpl());
    await notifier.loadData();
  });

  Widget buildApp(Widget child) {
    return AppStateProvider(
      notifier: notifier,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('Deep Deployment Check - Welcome & Customer Screens', () {
    testWidgets('EntranceSplashScreen renders cleanly', (tester) async {
      await tester.pumpWidget(buildApp(const EntranceSplashScreen()));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(EntranceSplashScreen), findsOneWidget);
    });

    testWidgets('WelcomeScreen renders all hero sections and language switcher', (tester) async {
      await tester.pumpWidget(buildApp(const WelcomeScreen()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(WelcomeScreen), findsOneWidget);
    });

    testWidgets('CustomerHomeScreen renders cleanly on mobile and desktop', (tester) async {
      notifier.switchRole(UserRole.customer);
      for (final size in [const Size(375, 812), const Size(1280, 800)]) {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(buildApp(const CustomerHomeScreen()));
        await tester.pumpAndSettle();
        expect(find.byType(CustomerHomeScreen), findsOneWidget);
      }
    });

    testWidgets('NewBookingScreen vehicle and carpet forms render cleanly', (tester) async {
      notifier.switchRole(UserRole.customer);
      await tester.pumpWidget(buildApp(const NewBookingScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(NewBookingScreen), findsOneWidget);
    });

    testWidgets('LiveTrackingScreen renders search and status state cleanly', (tester) async {
      notifier.switchRole(UserRole.customer);
      await tester.pumpWidget(buildApp(const LiveTrackingScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LiveTrackingScreen), findsOneWidget);
    });

    testWidgets('BookingHistoryScreen renders without exceptions', (tester) async {
      notifier.switchRole(UserRole.customer);
      await tester.pumpWidget(buildApp(const BookingHistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(BookingHistoryScreen), findsOneWidget);
    });
  });

  group('Deep Deployment Check - Cashier & Manager Shift Desks', () {
    testWidgets('CashierDashboardScreen renders all tabs & sub-queue filters cleanly', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await tester.pumpWidget(buildApp(const CashierDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CashierDashboardScreen), findsOneWidget);

      final tabs = find.byType(Tab);
      for (int i = 0; i < tabs.evaluate().length; i++) {
        await tester.tap(tabs.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('OperationalManagerDashboardScreen preserves day/night shift symmetry', (tester) async {
      notifier.switchRole(UserRole.manager);
      await tester.pumpWidget(buildApp(const OperationalManagerDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(OperationalManagerDashboardScreen), findsOneWidget);

      final tabs = find.byType(Tab);
      for (int i = 0; i < tabs.evaluate().length; i++) {
        await tester.tap(tabs.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('WalkInRegistrationScreen renders intake form cleanly', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await tester.pumpWidget(buildApp(const WalkInRegistrationScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(WalkInRegistrationScreen), findsOneWidget);
    });
  });

  group('Deep Deployment Check - Storekeeper, Accountant & Admin Desks', () {
    testWidgets('StorekeeperDashboardScreen renders Rapid Refill, Storeroom Stock & Fixed Assets', (tester) async {
      notifier.switchRole(UserRole.storekeeper);
      await tester.pumpWidget(buildApp(const StorekeeperDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(StorekeeperDashboardScreen), findsOneWidget);

      final tabs = find.byType(Tab);
      for (int i = 0; i < tabs.evaluate().length; i++) {
        await tester.tap(tabs.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('AccountantDashboardScreen renders P&L, Closings, Petty Cash & Payroll tabs', (tester) async {
      notifier.switchRole(UserRole.accountant);
      await tester.pumpWidget(buildApp(const AccountantDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AccountantDashboardScreen), findsOneWidget);

      final tabs = find.byType(Tab);
      for (int i = 0; i < tabs.evaluate().length; i++) {
        await tester.tap(tabs.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('AdminDashboardScreen renders all administration tabs cleanly', (tester) async {
      notifier.switchRole(UserRole.admin);
      await tester.pumpWidget(buildApp(const AdminDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AdminDashboardScreen), findsOneWidget);

      final tabs = find.byType(Tab);
      for (int i = 0; i < tabs.evaluate().length; i++) {
        await tester.tap(tabs.at(i), warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('PricingManagementScreen, StaffManagementScreen & CommissionLogsScreen render cleanly', (tester) async {
      notifier.switchRole(UserRole.admin);

      await tester.pumpWidget(buildApp(const PricingManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(PricingManagementScreen), findsOneWidget);

      await tester.pumpWidget(buildApp(const StaffManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(StaffManagementScreen), findsOneWidget);

      await tester.pumpWidget(buildApp(const CommissionLogsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CommissionLogsScreen), findsOneWidget);

      await tester.pumpWidget(buildApp(const CredentialsManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CredentialsManagementScreen), findsOneWidget);
    });

    testWidgets('FinancialReportsView and VehicleHistoryScreen render cleanly', (tester) async {
      notifier.switchRole(UserRole.admin);

      await tester.pumpWidget(buildApp(const FinancialReportsView()));
      await tester.pumpAndSettle();
      expect(find.byType(FinancialReportsView), findsOneWidget);

      await tester.pumpWidget(buildApp(const VehicleHistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(VehicleHistoryScreen), findsOneWidget);
    });
  });

  group('Deep Deployment Check - Modals, Dialogs and AI Sheets', () {
    const testPkg = WashPackage(
      id: 'pkg-standard',
      name: 'Standard Wash',
      description: 'Standard exterior body wash',
      durationMinutes: 30,
      pricingByCarType: {
        CarType.automobile: 350.0,
        CarType.minibus: 450.0,
        CarType.truck: 650.0,
      },
      features: ['Foam wash', 'Rinse', 'Tire shine'],
    );
    final testBooking = WashBooking(
      id: 'test-booking-1',
      customerName: 'Dawit Abebe',
      customerPhone: '0912345678',
      serviceType: ServiceType.walkInStation,
      carType: CarType.automobile,
      licensePlate: '2-B12345',
      package: testPkg,
      status: WashStatus.washing,
      payment: const PaymentInfo(
        method: PaymentMethod.cash,
        isPaid: false,
        amount: 350.0,
      ),
      createdAt: DateTime.now(),
    );

    testWidgets('PhoneBookingDialog renders vehicle and carpet modes without error', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await tester.pumpWidget(buildApp(const Scaffold(body: PhoneBookingDialog())));
      await tester.pumpAndSettle();
      expect(find.byType(PhoneBookingDialog), findsOneWidget);
    });

    testWidgets('EditBookingDialog renders details and pricing cleanly', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await tester.pumpWidget(buildApp(Scaffold(body: EditBookingDialog(booking: testBooking))));
      await tester.pumpAndSettle();
      expect(find.byType(EditBookingDialog), findsOneWidget);
    });

    testWidgets('PaymentProcessDialog renders split payment modes and photo uploads cleanly', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await tester.pumpWidget(buildApp(Scaffold(body: PaymentProcessDialog(booking: testBooking))));
      await tester.pumpAndSettle();
      expect(find.byType(PaymentProcessDialog), findsOneWidget);
    });

    testWidgets('BayAssignmentModal, DailyClosingDialog & PettyCashDialog render cleanly', (tester) async {
      notifier.switchRole(UserRole.cashier);

      await tester.pumpWidget(buildApp(Scaffold(body: BayAssignmentModal(booking: testBooking))));
      await tester.pumpAndSettle();
      expect(find.byType(BayAssignmentModal), findsOneWidget);

      await tester.pumpWidget(buildApp(const Scaffold(body: DailyClosingDialog())));
      await tester.pumpAndSettle();
      expect(find.byType(DailyClosingDialog), findsOneWidget);

      await tester.pumpWidget(buildApp(const Scaffold(body: PettyCashDialog())));
      await tester.pumpAndSettle();
      expect(find.byType(PettyCashDialog), findsOneWidget);

      await tester.pumpWidget(buildApp(const Scaffold(body: BankDepositDialog())));
      await tester.pumpAndSettle();
      expect(find.byType(BankDepositDialog), findsOneWidget);

      await tester.pumpWidget(buildApp(const Scaffold(body: WeeklyCommissionReportDialog())));
      await tester.pumpAndSettle();
      expect(find.byType(WeeklyCommissionReportDialog), findsOneWidget);
    });

    testWidgets('BisheAiExecutiveSheet renders chat interface and prompt pills', (tester) async {
      notifier.switchRole(UserRole.admin);
      await tester.pumpWidget(buildApp(const Scaffold(body: BisheAiExecutiveSheet())));
      await tester.pumpAndSettle();
      expect(find.byType(BisheAiExecutiveSheet), findsOneWidget);
    });
  });

  group('Deep Deployment Check - Empty Database Boot Resilience', () {
    testWidgets('Zero records in collections does not throw StateError on any screen', (tester) async {
      await notifier.clearAllBookings();

      notifier.switchRole(UserRole.customer);
      await tester.pumpWidget(buildApp(const CustomerHomeScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerHomeScreen), findsOneWidget);

      notifier.switchRole(UserRole.cashier);
      await tester.pumpWidget(buildApp(const CashierDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CashierDashboardScreen), findsOneWidget);

      notifier.switchRole(UserRole.manager);
      await tester.pumpWidget(buildApp(const OperationalManagerDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(OperationalManagerDashboardScreen), findsOneWidget);

      notifier.switchRole(UserRole.storekeeper);
      await tester.pumpWidget(buildApp(const StorekeeperDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(StorekeeperDashboardScreen), findsOneWidget);

      notifier.switchRole(UserRole.accountant);
      await tester.pumpWidget(buildApp(const AccountantDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AccountantDashboardScreen), findsOneWidget);

      notifier.switchRole(UserRole.admin);
      await tester.pumpWidget(buildApp(const AdminDashboardScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(AdminDashboardScreen), findsOneWidget);
    });
  });
}
