import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/widgets/app_role_header.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';

class RoleShellScreen extends StatelessWidget {
  const RoleShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final role = notifier.currentRole;

    Widget body;
    switch (role) {
      case UserRole.customer:
        body = const CustomerHomeScreen();
        break;
      case UserRole.cashier:
        body = const CashierDashboardScreen();
        break;
      case UserRole.admin:
        body = const AdminDashboardScreen();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                const AppRoleHeader(),
                Expanded(child: body),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
