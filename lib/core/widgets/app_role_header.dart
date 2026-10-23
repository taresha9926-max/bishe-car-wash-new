import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class AppRoleHeader extends StatelessWidget {
  const AppRoleHeader({super.key});

  void _showPinDialog(BuildContext context, UserRole targetRole) {
    final notifier = AppStateProvider.of(context);
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(notifier.tr('staffLogin')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${notifier.tr('enterPin')} (${targetRole.displayName}):',
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(notifier.tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              // 4-digit PIN check: default 1234 or role specific
              if (pinController.text == '1234' || pinController.text == '9926') {
                notifier.switchRole(targetRole);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(notifier.tr('invalidPin')),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(notifier.tr('unlock')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateProvider.of(context);
    final currentRole = notifier.currentRole;
    final currentLang = notifier.currentLanguage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(bottom: BorderSide(color: AppColors.cardBorder, width: 1)),
      ),
      child: Row(
        children: [
          // Branding
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.local_car_wash_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notifier.tr('appName'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  notifier.tr('tagline'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // Trilingual Switcher (EN, OM, AM)
          DropdownButtonHideUnderline(
            child: DropdownButton<AppLanguage>(
              value: currentLang,
              icon: const Icon(Icons.language_rounded, size: 18, color: AppColors.primary),
              items: AppLanguage.values.map((lang) {
                return DropdownMenuItem(
                  value: lang,
                  child: Text(
                    lang.code,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (lang) {
                if (lang != null) notifier.setLanguage(lang);
              },
            ),
          ),
          const SizedBox(width: 8),

          // Role Switcher / Staff Gate
          if (currentRole == UserRole.customer) ...[
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              ),
              icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
              label: Text(notifier.tr('staffLogin'), style: const TextStyle(fontSize: 12)),
              onPressed: () => _showPinDialog(context, UserRole.cashier),
            ),
          ] else ...[
            PopupMenuButton<UserRole>(
              initialValue: currentRole,
              tooltip: 'Switch Role',
              child: Chip(
                avatar: const Icon(Icons.shield_rounded, size: 16, color: Colors.white),
                label: Text(
                  currentRole.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                backgroundColor: currentRole == UserRole.admin ? AppColors.primaryDark : AppColors.primary,
              ),
              onSelected: (role) {
                if (role == UserRole.customer) {
                  notifier.switchRole(UserRole.customer);
                } else {
                  _showPinDialog(context, role);
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(
                  value: UserRole.customer,
                  child: Text('Customer (Public)'),
                ),
                const PopupMenuItem(
                  value: UserRole.cashier,
                  child: Text('Cashier Dashboard'),
                ),
                const PopupMenuItem(
                  value: UserRole.admin,
                  child: Text('Admin Management'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
