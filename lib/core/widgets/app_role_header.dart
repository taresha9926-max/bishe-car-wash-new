import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/widgets/language_switcher_action.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/presentation/widgets/role_auth_dialog.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class AppRoleHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showRoleSwitcher;
  final VoidCallback? onHomePressed;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showLogoutButton;

  const AppRoleHeader({
    super.key,
    required this.title,
    this.actions,
    this.showRoleSwitcher = true,
    this.onHomePressed,
    this.leading,
    this.showBackButton = false,
    this.onBack,
    this.showLogoutButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  Color _getRoleAccentColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return AppColors.champagneGold; // Champagne Gold
      case UserRole.cashier:
        return const Color(0xFF10B981); // Emerald
      case UserRole.manager:
        return const Color(0xFFA78BFA); // Soft Indigo
      case UserRole.accountant:
        return AppColors.warmGold; // Warm Gold
      case UserRole.storekeeper:
        return const Color(0xFF2DD4BF); // Teal
      case UserRole.customer:
        return AppColors.warmGold; // Warm Brushed Gold
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final currentRole = state.currentRole;
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final roleAccent = _getRoleAccentColor(currentRole);

    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF0A0C12),
      surfaceTintColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      centerTitle: false,
      automaticallyImplyLeading: showBackButton || leading != null,
      leadingWidth: (showBackButton || leading != null) ? (isMobile ? 36 : 44) : null,
      leading: (showBackButton || leading != null)
          ? (leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                tooltip: state.tr('back'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onBack ??
                    () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        state.goToWelcome();
                      }
                    },
              ))
          : null,
      titleSpacing: (showBackButton || leading != null) ? (isMobile ? 4 : 8) : (isMobile ? 8 : 16),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF06070B), Color(0xFF15120C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border(
            bottom: BorderSide(color: Color(0x33F59E0B), width: 1.2),
          ),
        ),
      ),
      title: isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!showBackButton && leading == null) ...[
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(color: AppColors.liquidCyanNeon.withValues(alpha: 0.45)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.liquidCyanNeon.withValues(alpha: 0.25),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/bishe_logo.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(Icons.local_car_wash, color: roleAccent, size: 16),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Flexible(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.liquidCyanNeon.withValues(alpha: 0.45)),
                    boxShadow: [
                      BoxShadow(
                        color: roleAccent.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/bishe_logo.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.local_car_wash, color: Colors.white, size: 22),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: roleAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: roleAccent.withValues(alpha: 0.4), width: 0.8),
                            ),
                            child: Text(
                              'BISHOFTU',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: roleAccent,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        (state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty && currentRole != UserRole.customer)
                            ? 'Staff: ${state.activeStaffFullName} • Bishoftu Station'
                            : 'Bishoftu • Oromia, Ethiopia',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      actions: [
        // Return to Welcome Hub / Back to Root
        IconButton(
          icon: const Icon(Icons.home_rounded, color: Colors.white70, size: 21),
          tooltip: state.tr('home'),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          onPressed: () {
            if (onHomePressed != null) {
              onHomePressed!();
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              state.goToWelcome();
            }
          },
        ),

        // Language Switcher Dropdown (EN / OM / AM)
        const LanguageSwitcherAction(isDark: true),

        // Role Switcher / Staff Entrance
        if (showRoleSwitcher) ...[
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 2 : 6),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 6),
            decoration: BoxDecoration(
              color: const Color(0xFF161A26),
              borderRadius: BorderRadius.circular(isMobile ? 10 : 20),
              border: Border.all(color: roleAccent.withValues(alpha: 0.5), width: 1.2),
            ),
            child: PopupMenuButton<UserRole>(
              initialValue: currentRole,
              tooltip: currentRole == UserRole.customer ? state.tr('staffPortals') : state.tr('staffPortals'),
              offset: const Offset(0, 42),
              color: const Color(0xFF161A26),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (role) async {
                if (role == currentRole) return;
                if (role == UserRole.customer) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  state.switchRole(role);
                  return;
                }
                final authenticated = await RoleAuthDialog.show(context, role);
                if (authenticated && context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  state.switchRole(role);
                }
              },
              itemBuilder: (context) {
                return UserRole.values.map((role) {
                  final isCurrent = role == currentRole;
                  final itemAccent = _getRoleAccentColor(role);
                  return PopupMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          role.icon,
                          size: 18,
                          color: isCurrent ? itemAccent : Colors.white70,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          role.localizedName(state.currentLang),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                            color: isCurrent ? itemAccent : Colors.white,
                          ),
                        ),
                        if (isCurrent) ...[
                          const Spacer(),
                          Icon(Icons.check, size: 16, color: itemAccent),
                        ],
                      ],
                    ),
                  );
                }).toList();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 8, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentRole == UserRole.customer ? Icons.badge_outlined : currentRole.icon,
                      size: 16,
                      color: roleAccent,
                    ),
                    if (currentRole == UserRole.customer) ...[
                      if (!isMobile) ...[
                        const SizedBox(width: 4),
                        Text(
                          state.tr('staffPortals'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: roleAccent,
                          ),
                        ),
                      ],
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 16,
                        color: roleAccent,
                      ),
                    ] else if (!isMobile) ...[
                      const SizedBox(width: 6),
                      Text(
                        (state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty)
                            ? state.activeStaffFullName!
                            : currentRole.localizedName(state.currentLang),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: roleAccent,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: roleAccent,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        if (actions != null) ...actions!,
        if (showLogoutButton)
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            tooltip: state.tr('logout'),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            onPressed: () => _confirmLogout(context, state),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, dynamic state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161A26),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0x38F59E0B)),
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
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF94A3B8),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              state.tr('cancel'),
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              state.tr('logout'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      state.logout();
    }
  }
}
