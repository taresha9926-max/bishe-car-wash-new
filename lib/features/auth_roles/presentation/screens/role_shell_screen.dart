import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/widgets/responsive_layout.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/admin_dashboard_screen.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/presentation/widgets/role_auth_dialog.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/cashier_dashboard_screen.dart';
import 'package:bishe_car_wash/features/manager/presentation/screens/operational_manager_dashboard_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/customer_home_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:bishe_car_wash/features/welcome/presentation/screens/entrance_splash_screen.dart';
import 'package:bishe_car_wash/features/inventory/presentation/screens/storekeeper_dashboard_screen.dart';
import 'package:bishe_car_wash/features/admin/presentation/screens/accountant_dashboard_screen.dart';

class RoleShellScreen extends StatelessWidget {
  const RoleShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    if (!state.hasSeenEntranceSplash) {
      return const EntranceSplashScreen();
    }
    if (state.isWelcomeActive) {
      return const WelcomeScreen();
    }

    final currentRole = state.currentRole;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    Widget body;
    switch (currentRole) {
      case UserRole.customer:
        body = const CustomerHomeScreen();
        break;
      case UserRole.cashier:
        body = const CashierDashboardScreen();
        break;
      case UserRole.manager:
        body = const OperationalManagerDashboardScreen();
        break;
      case UserRole.admin:
        body = const AdminDashboardScreen();
        break;
      case UserRole.storekeeper:
        body = const StorekeeperDashboardScreen();
        break;
      case UserRole.accountant:
        body = const AccountantDashboardScreen();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Desktop / Tablet Navigation Sidebar
                  _buildNavigationRail(context, state, currentRole),
                  const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),
                  // Main Body
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: body,
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 850),
                  child: body,
                ),
              ),
      ),
    );
  }

  Widget _buildNavigationRail(BuildContext context, dynamic state, UserRole currentRole) {
    return Material(
      color: Colors.white,
      child: Container(
        width: 230,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_car_wash_rounded, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr('appName'),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('bishoftu'),
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: AppColors.primary.withOpacity(0.08),
            leading: const Icon(Icons.home_rounded, color: AppColors.primary, size: 20),
            title: const Text(
              'Welcome Hub',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
            onTap: () => state.goToWelcome(),
          ),
          const SizedBox(height: 16),
          const Text(
            'ROLES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textMuted,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          ...UserRole.values.map((role) {
            final isSelected = role == currentRole;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: isSelected ? AppColors.primary.withOpacity(0.09) : Colors.transparent,
                leading: Icon(
                  role.icon,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 20,
                ),
                title: Text(
                  role.localizedName(state.currentLang),
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                onTap: () async {
                  if (role == currentRole) return;
                  if (role == UserRole.customer) {
                    state.switchRole(role);
                    return;
                  }
                  final auth = await RoleAuthDialog.show(context, role);
                  if (auth) {
                    state.switchRole(role);
                  }
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: const Color(0xFFEF4444).withValues(alpha: 0.08),
            leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            title: Text(
              state.tr('logout'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFEF4444)),
            ),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF161A26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFF334155)),
                  ),
                  title: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.tr('confirmLogout'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  content: Text(
                    state.tr('confirmLogoutMessage'),
                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: Text(state.tr('cancel'), style: const TextStyle(color: Color(0xFF94A3B8))),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: Text(state.tr('logout'), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                state.logout();
              }
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.tr('bishoftu'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
}
}
