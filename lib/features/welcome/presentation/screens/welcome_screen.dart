import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth_roles/domain/models/user_role.dart';
import '../../../auth_roles/presentation/widgets/role_auth_dialog.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/ad_video_showcase_card.dart';

class WelcomeScreen extends StatefulWidget {
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
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _topBarFade;
  late final Animation<double> _customerFade;
  late final Animation<Offset> _customerSlide;
  late final Animation<double> _reelsFade;
  late final Animation<Offset> _reelsSlide;
  late final Animation<double> _mapsFade;
  late final Animation<Offset> _mapsSlide;
  bool _isCustomerHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _topBarFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );

    _customerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.15, 0.6, curve: Curves.easeIn),
    );
    _customerSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.15, 0.6, curve: Curves.easeOutCubic)),
    );

    _reelsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.35, 0.8, curve: Curves.easeIn),
    );
    _reelsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic)),
    );

    _mapsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
    );
    _mapsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic)),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _openCashierPortal() async {
    final state = AppStateProvider.read(context);
    final auth = await RoleAuthDialog.show(context, UserRole.cashier);
    if (auth) {
      state.switchRole(UserRole.cashier);
      widget.onEnterCashier?.call();
    }
  }

  void _openAdminPortal() async {
    final state = AppStateProvider.read(context);
    final auth = await RoleAuthDialog.show(context, UserRole.admin);
    if (auth) {
      state.switchRole(UserRole.admin);
      widget.onEnterAdmin?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 18, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Bar: Language & Staff Portals Sandwich Menu (Top Right)
                  FadeTransition(
                    opacity: _topBarFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Language Switcher Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: state.currentLang,
                              icon: const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                              items: const [
                                DropdownMenuItem(
                                  value: 'EN',
                                  child: Text('English (EN)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                                DropdownMenuItem(
                                  value: 'OM',
                                  child: Text('Afaan Oromoo (OM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                                DropdownMenuItem(
                                  value: 'AM',
                                  child: Text('አማርኛ (AM)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ],
                              onChanged: (lang) {
                                if (lang != null) state.setLanguage(lang);
                              },
                            ),
                          ),
                        ),

                        // Right: Relocated Cashier & Admin Entry (Sandwich Button)
                        PopupMenuButton<String>(
                          tooltip: 'Staff Portals (Cashier & Admin)',
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                          color: Colors.white,
                          offset: const Offset(0, 42),
                          onSelected: (value) {
                            if (value == 'cashier') {
                              _openCashierPortal();
                            } else if (value == 'admin') {
                              _openAdminPortal();
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withOpacity(0.25), width: 1.2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.menu_rounded, size: 18, color: AppColors.primary),
                                SizedBox(width: 7),
                                Text(
                                  'Staff Portals',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                          itemBuilder: (ctx) => [
                            PopupMenuItem(
                              value: 'cashier',
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondary.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.point_of_sale_rounded, color: AppColors.secondary, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.tr('cashierPortal'),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                        ),
                                        const Text(
                                          'Gate Desk • PIN: 2233',
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(),
                            PopupMenuItem(
                              value: 'admin',
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.red, size: 18),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          state.tr('adminPortal'),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                        ),
                                        const Text(
                                          'Super Admin Hub • PIN: 4450',
                                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Minimized, Space-Saving Brand Header
                  FadeTransition(
                    opacity: _topBarFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primaryDark, Color(0xFF1E3A8A), AppColors.primary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.22),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Minimized Logo Icon
                          Container(
                            padding: const EdgeInsets.all(9),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                            ),
                            child: const Icon(Icons.local_car_wash_rounded, size: 24, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.tr('welcomeTitle'),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  state.tr('welcomeSubtitle'),
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Compact Capacity Chips
                          if (isDesktop)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildMiniChip('2 Bays'),
                                const SizedBox(width: 6),
                                _buildMiniChip('1 Mobile Van'),
                                const SizedBox(width: 6),
                                _buildMiniChip('10 Packages'),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Customer Portal Positioned at the Top (Easily Found)
                  SlideTransition(
                    position: _customerSlide,
                    child: FadeTransition(
                      opacity: _customerFade,
                      child: MouseRegion(
                        onEnter: (_) => setState(() => _isCustomerHovered = true),
                        onExit: (_) => setState(() => _isCustomerHovered = false),
                        child: AnimatedScale(
                          scale: _isCustomerHovered ? 1.012 : 1.0,
                          duration: const Duration(milliseconds: 180),
                          child: InkWell(
                            onTap: () {
                              state.switchRole(UserRole.customer);
                              widget.onEnterCustomer?.call();
                            },
                            borderRadius: BorderRadius.circular(22),
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: _isCustomerHovered ? AppColors.primary : AppColors.cardBorder,
                                  width: _isCustomerHovered ? 2.0 : 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(_isCustomerHovered ? 0.16 : 0.06),
                                    blurRadius: _isCustomerHovered ? 20 : 10,
                                    offset: Offset(0, _isCustomerHovered ? 6 : 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Glowing Vehicle Portal Icon
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [AppColors.primaryDark, AppColors.primary],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.directions_car_filled_rounded,
                                      size: 32,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              state.tr('customerPortal'),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2563EB).withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'PUBLIC ACCESS',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w900,
                                                  color: Color(0xFF2563EB),
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          state.tr('customerPortalDesc'),
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: AppColors.textSecondary,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        const Row(
                                          children: [
                                            Icon(Icons.check_circle_rounded, size: 13, color: AppColors.statusReady),
                                            SizedBox(width: 4),
                                            Text(
                                              'Instant Wash Booking • Private Live Queue Tracker',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Enter Button
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      state.switchRole(UserRole.customer);
                                      widget.onEnterCustomer?.call();
                                    },
                                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                    label: const Text('Enter Portal', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. Auto-Rolling TikTok Video Reels Carousel
                  SlideTransition(
                    position: _reelsSlide,
                    child: FadeTransition(
                      opacity: _reelsFade,
                      child: const AdVideoShowcaseCard(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 5. Clean Google Maps Bar (Coordinates & Copy Removed)
                  SlideTransition(
                    position: _mapsSlide,
                    child: FadeTransition(
                      opacity: _mapsFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardBorder),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.statusPending.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on_rounded, size: 24, color: AppColors.statusPending),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        AppConstants.stationName,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('OPEN', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
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
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Footer
                  FadeTransition(
                    opacity: _mapsFade,
                    child: Text(
                      '© ${DateTime.now().year} BISHE Car Wash Services • Bishoftu, Oromia',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.white),
      ),
    );
  }
}
