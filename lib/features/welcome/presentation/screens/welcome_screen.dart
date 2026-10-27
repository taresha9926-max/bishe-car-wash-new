import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth_roles/domain/models/user_role.dart';
import '../../../auth_roles/presentation/widgets/role_auth_dialog.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class WelcomeScreen extends StatelessWidget {
  final VoidCallback? onEnterCustomer;
  final VoidCallback? onEnterCashier;
  final VoidCallback? onEnterAdmin;

  const WelcomeScreen({
    super.key,
    this.onEnterCustomer,
    this.onEnterCashier,
    this.onEnterAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar: Language Selector & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Text(
                              'BISHE OFFICIAL HUB',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 0.5),
                            ),
                          ],
                        ),
                      ),
                      // Language Switcher Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.currentLang,
                            icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                            items: const [
                              DropdownMenuItem(value: 'EN', child: Text('English (EN)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                              DropdownMenuItem(value: 'OM', child: Text('Afaan Oromoo (OM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                              DropdownMenuItem(value: 'AM', child: Text('አማርኛ (AM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                            ],
                            onChanged: (lang) {
                              if (lang != null) state.setLanguage(lang);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Brand Hero Header Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          child: const Icon(Icons.local_car_wash_rounded, size: 42, color: Colors.white),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          state.tr('welcomeTitle'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.tr('welcomeSubtitle'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Capacity Pills Row
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildFeaturePill(Icons.speed_rounded, '2 Pressure Bays'),
                            _buildFeaturePill(Icons.airport_shuttle_rounded, '1 At-Home Van'),
                            _buildFeaturePill(Icons.layers_rounded, '10 Detailing Packages'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // GPS Live Station Location Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.statusPending.withOpacity(0.4), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.statusPending.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.location_on_rounded, size: 28, color: AppColors.statusPending),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    state.tr('locateBisheStation'),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('LIVE GPS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Bishoftu (Debre Zeyit), Oromia, Ethiopia',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
                          icon: const Icon(Icons.navigation_rounded, size: 15),
                          label: Text(
                            state.tr('openGoogleMaps'),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Gateway Heading
                  const Text(
                    'CHOOSE YOUR PORTAL',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 3 Gateway Cards
                  _buildPortalCard(
                    context: context,
                    icon: Icons.directions_car_filled_rounded,
                    color: AppColors.primary,
                    title: state.tr('customerPortal'),
                    subtitle: state.tr('customerPortalDesc'),
                    badge: 'PUBLIC ACCESS',
                    badgeColor: Colors.blue,
                    onTap: () {
                      state.switchRole(UserRole.customer);
                      onEnterCustomer?.call();
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildPortalCard(
                    context: context,
                    icon: Icons.point_of_sale_rounded,
                    color: AppColors.secondary,
                    title: state.tr('cashierPortal'),
                    subtitle: state.tr('cashierPortalDesc'),
                    badge: 'PIN PROTECTED',
                    badgeColor: Colors.orange,
                    onTap: () async {
                      final auth = await RoleAuthDialog.show(context, UserRole.cashier);
                      if (auth) {
                        state.switchRole(UserRole.cashier);
                        onEnterCashier?.call();
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildPortalCard(
                    context: context,
                    icon: Icons.admin_panel_settings_rounded,
                    color: AppColors.statusCancelled,
                    title: state.tr('adminPortal'),
                    subtitle: state.tr('adminPortalDesc'),
                    badge: 'SUPER ADMIN',
                    badgeColor: Colors.red,
                    onTap: () async {
                      final auth = await RoleAuthDialog.show(context, UserRole.admin);
                      if (auth) {
                        state.switchRole(UserRole.admin);
                        onEnterAdmin?.call();
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Text(
                    '© ${DateTime.now().year} BISHE Car Wash Services • Powered by Clean Architecture & Supabase',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 26, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
