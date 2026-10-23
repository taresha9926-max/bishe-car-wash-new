import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class AppRoleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showRoleSwitcher;

  const AppRoleHeader({
    super.key,
    required this.title,
    this.actions,
    this.showRoleSwitcher = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final currentRole = state.currentRole;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_car_wash, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'BISHOFTU',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Bishoftu • Oromia, Ethiopia',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (showRoleSwitcher) ...[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: PopupMenuButton<UserRole>(
              initialValue: currentRole,
              tooltip: 'Switch User Role',
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (role) {
                state.switchRole(role);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(currentRole.icon, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      currentRole.displayName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
                  ],
                ),
              ),
              itemBuilder: (context) => [
                _buildRoleMenuItem(
                  UserRole.customer,
                  'Customer View',
                  'Book & track walk-in or mobile van',
                  currentRole == UserRole.customer,
                ),
                _buildRoleMenuItem(
                  UserRole.cashier,
                  'Cashier Dashboard',
                  'Gate check-in, bay & payment desk',
                  currentRole == UserRole.cashier,
                ),
                _buildRoleMenuItem(
                  UserRole.admin,
                  'Admin Control Panel',
                  'Pricing matrix, salaries & commissions',
                  currentRole == UserRole.admin,
                ),
              ],
            ),
          ),
        ],
        if (actions != null) ...actions!,
        const SizedBox(width: 8),
      ],
    );
  }

  PopupMenuItem<UserRole> _buildRoleMenuItem(
    UserRole role,
    String title,
    String subtitle,
    bool isSelected,
  ) {
    return PopupMenuItem<UserRole>(
      value: role,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              role.icon,
              size: 18,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            const Icon(Icons.check, size: 18, color: AppColors.primary),
        ],
      ),
    );
  }
}
