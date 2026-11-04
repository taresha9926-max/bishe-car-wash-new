import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bishe_car_wash/core/constants/app_theme.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/presentation/screens/role_shell_screen.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/accountant_dashboard_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:bishe_car_wash/features/inventory/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:bishe_car_wash/features/booking_service/data/repositories/wash_repository_impl.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

void main() {
  late AppStateNotifier notifier;

  setUp(() async {
    notifier = AppStateNotifier(repository: WashRepositoryImpl());
    await notifier.loadData();
  });

  Future<void> testAllTabs(WidgetTester tester, Widget screen, int tabCount, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tabFinders = find.byType(Tab);
    final count = tabFinders.evaluate().length;
    for (int i = 0; i < count; i++) {
      await tester.tap(tabFinders.at(i));
      await tester.pumpAndSettle();
    }
  }

  group('Mobile viewport (375x812)', () {
    const mobileSize = Size(375, 812);

    testWidgets('Cashier all tabs on mobile', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await testAllTabs(tester, const CashierDashboardScreen(), 4, mobileSize);
    });

    testWidgets('Accountant all tabs on mobile', (tester) async {
      notifier.switchRole(UserRole.accountant);
      await testAllTabs(tester, const AccountantDashboardScreen(), 4, mobileSize);
    });

    testWidgets('Storekeeper all tabs on mobile', (tester) async {
      notifier.switchRole(UserRole.storekeeper);
      await testAllTabs(tester, const StorekeeperDashboardScreen(), 4, mobileSize);
    });

    testWidgets('Admin all tabs on mobile', (tester) async {
      notifier.switchRole(UserRole.admin);
      await testAllTabs(tester, const AdminDashboardScreen(), 5, mobileSize);
    });
  });

  group('Desktop viewport (1280x800)', () {
    const desktopSize = Size(1280, 800);

    testWidgets('Cashier all tabs on desktop', (tester) async {
      notifier.switchRole(UserRole.cashier);
      await testAllTabs(tester, const CashierDashboardScreen(), 4, desktopSize);
    });

    testWidgets('Accountant all tabs on desktop', (tester) async {
      notifier.switchRole(UserRole.accountant);
      await testAllTabs(tester, const AccountantDashboardScreen(), 4, desktopSize);
    });

    testWidgets('Storekeeper all tabs on desktop', (tester) async {
      notifier.switchRole(UserRole.storekeeper);
      await testAllTabs(tester, const StorekeeperDashboardScreen(), 4, desktopSize);
    });

    testWidgets('Admin all tabs on desktop', (tester) async {
      notifier.switchRole(UserRole.admin);
      await testAllTabs(tester, const AdminDashboardScreen(), 5, desktopSize);
    });
  });

  group('RoleShellScreen all roles across viewports', () {
    for (final size in [const Size(360, 780), const Size(768, 1024), const Size(1280, 800)]) {
      for (final role in UserRole.values) {
        testWidgets('RoleShellScreen for ${role.name} on ${size.width}x${size.height}', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          notifier.switchRole(role);
          await tester.pumpWidget(
            AppStateProvider(
              notifier: notifier,
              child: MaterialApp(
                theme: AppTheme.lightTheme,
                home: const RoleShellScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(RoleShellScreen), findsOneWidget);
        });
      }
    }
  });
}
