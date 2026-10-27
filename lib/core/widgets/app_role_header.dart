import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/auth_roles/presentation/widgets/role_auth_dialog.dart';
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
    final currentLang = state.currentLang;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      titleSpacing: isMobile ? 10 : 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(isMobile ? 8 : 10),
            ),
            child: Icon(Icons.local_car_wash, color: Colors.white, size: isMobile ? 18 : 22),
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
                        style: TextStyle(
                          fontSize: isMobile ? 14.5 : 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (!isMobile) ...[
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
                  ],
                ),
                if (!isMobile)
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
        // Return to Welcome Hub
        IconButton(
          icon: const Icon(Icons.home_outlined, color: AppColors.primary, size: 21),
          tooltip: 'Return to Welcome Hub',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          onPressed: () => state.goToWelcome(),
        ),

        // Language Switcher Dropdown (EN / OM / AM)
        Container(
          margin: EdgeInsets.symmetric(vertical: isMobile ? 14 : 14, horizontal: 4),
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentLang,
              icon: const Icon(Icons.language_rounded, size: 15, color: AppColors.primary),
              items: const [
                DropdownMenuItem(value: 'EN', child: Text('EN', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                DropdownMenuItem(value: 'OM', child: Text('OM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                DropdownMenuItem(value: 'AM', child: Text('AM', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
              ],
              onChanged: (lang) {
                if (lang != null) state.setLanguage(lang);
              },
            ),
          ),
        ),

        // Role Switcher
        if (showRoleSwitcher) ...[
          Container(
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: isMobile ? 4 : 8),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 2 : 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: PopupMenuButton<UserRole>(
              initialValue: currentRole,
              tooltip: 'Switch User Role',
              offset: const Offset(0, 42),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onSelected: (role) async {
                if (role == currentRole) return;
                if (role == UserRole.customer) {
                  state.switchRole(role);
                  return;
                }
                final authenticated = await RoleAuthDialog.show(context, role);
                if (authenticated) {
                  state.switchRole(role);
                }
              },
              itemBuilder: (context) {
                return UserRole.values.map((role) {
                  final isCurrent = role == currentRole;
                  return PopupMenuItem(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          role.icon,
                          size: 18,
                          color: isCurrent ? AppColors.primary : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          role.displayName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                            color: isCurrent ? AppColors.primary : AppColors.textPrimary,
                          ),
                        ),
                        if (isCurrent) ...[
                          const Spacer(),
                          const Icon(Icons.check, size: 16, color: AppColors.primary),
                        ],
                      ],
                    ),
                  );
                }).toList();
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentRole.icon,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    if (!isMobile) ...[
                      const SizedBox(width: 6),
                      Text(
                        currentRole.displayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
        if (actions != null) ...actions!,
        const SizedBox(width: 4),
      ],
    );
  }
}
