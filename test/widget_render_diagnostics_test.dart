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

  testWidgets('Cashier Dashboard renders without exceptions', (tester) async {
    notifier.switchRole(UserRole.cashier);
    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CashierDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CashierDashboardScreen), findsOneWidget);
  });

  testWidgets('Accountant Dashboard renders without exceptions', (tester) async {
    notifier.switchRole(UserRole.accountant);
    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AccountantDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AccountantDashboardScreen), findsOneWidget);
  });

  testWidgets('Storekeeper Dashboard renders without exceptions', (tester) async {
    notifier.switchRole(UserRole.storekeeper);
    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const StorekeeperDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StorekeeperDashboardScreen), findsOneWidget);
  });

  testWidgets('Admin Dashboard renders without exceptions', (tester) async {
    notifier.switchRole(UserRole.admin);
    await tester.pumpWidget(
      AppStateProvider(
        notifier: notifier,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AdminDashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AdminDashboardScreen), findsOneWidget);
  });

  testWidgets('RoleShellScreen renders without exceptions', (tester) async {
    notifier.switchRole(UserRole.cashier);
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
