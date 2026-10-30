import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../auth_roles/domain/models/user_role.dart';
import '../../../auth_roles/presentation/widgets/role_auth_dialog.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/ad_video_showcase_card.dart';
import '../widgets/welcome_service_carousel_banner.dart';

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : (isDesktop ? 48 : 24),
            vertical: isMobile ? 12 : 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Bar: Language Selector & Staff Portals Sandwich Menu (Top Right)
                  FadeTransition(
                    opacity: _topBarFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left: Language Switcher Dropdown (EN, OM, AM)
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

                        // Right: Relocated Cashier & Admin Entry (Top-Right Sandwich Menu)
                        PopupMenuButton<String>(
                          tooltip: state.tr('staffPortals'),
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
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: 7),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.menu_rounded, size: 18, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  state.tr('staffPortals'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.lock_outline_rounded, size: 13, color: AppColors.textSecondary),
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
                                        Text(
                                          state.tr('cashierPinBadge'),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                                        Text(
                                          state.tr('adminPinBadge'),
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                  const SizedBox(height: 12),

                  // 2. Horizontally Rolling 4-Slide Service Carousel Banner
                  FadeTransition(
                    opacity: _topBarFade,
                    child: WelcomeServiceCarouselBanner(isMobile: isMobile),
                  ),
                  const SizedBox(height: 14),

                  // 3. Customer Portal Positioned at the Top (Easily Found & Mobile-Thumb Friendly)
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
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: EdgeInsets.all(isMobile ? 15 : 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
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
                              child: isMobile
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [AppColors.primaryDark, AppColors.primary],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(14),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppColors.primary.withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 3),
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.directions_car_filled_rounded,
                                                size: 26,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        state.tr('customerPortal'),
                                                        style: const TextStyle(
                                                          fontSize: 16.5,
                                                          fontWeight: FontWeight.w900,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFF2563EB).withOpacity(0.12),
                                                          borderRadius: BorderRadius.circular(6),
                                                        ),
                                                        child: Text(
                                                          state.tr('publicAccess'),
                                                          style: const TextStyle(
                                                            fontSize: 8.5,
                                                            fontWeight: FontWeight.w900,
                                                            color: Color(0xFF2563EB),
                                                            letterSpacing: 0.4,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    state.tr('customerPortalDesc'),
                                                    style: const TextStyle(
                                                      fontSize: 11.5,
                                                      color: AppColors.textSecondary,
                                                      height: 1.25,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.statusReady),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                state.tr('customerTrustPill'),
                                                style: const TextStyle(
                                                  fontSize: 10.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        // Full-width mobile tap button
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              state.switchRole(UserRole.customer);
                                              widget.onEnterCustomer?.call();
                                            },
                                            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                            label: Text(
                                              state.tr('enterCustomerPortal'),
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                              elevation: 0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        // Desktop View Layout
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
                                                    child: Text(
                                                      state.tr('publicAccess'),
                                                      style: const TextStyle(
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
                                              Row(
                                                children: [
                                                  const Icon(Icons.check_circle_rounded, size: 13, color: AppColors.statusReady),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    state.tr('customerTrustPill'),
                                                    style: const TextStyle(
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
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            state.switchRole(UserRole.customer);
                                            widget.onEnterCustomer?.call();
                                          },
                                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                          label: Text(
                                            state.tr('enterCustomerPortal'),
                                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                          ),
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
                  const SizedBox(height: 16),

                  // 4. Auto-Rolling TikTok Video Reels Carousel (100% Read-Only, Localized)
                  SlideTransition(
                    position: _reelsSlide,
                    child: FadeTransition(
                      opacity: _reelsFade,
                      child: const AdVideoShowcaseCard(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Clean Google Maps Bar (Coordinates & Copy Removed, Localized)
                  SlideTransition(
                    position: _mapsSlide,
                    child: FadeTransition(
                      opacity: _mapsFade,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: isMobile ? 12 : 14),
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
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: AppColors.statusPending.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.location_on_rounded, size: 22, color: AppColors.statusPending),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          AppConstants.stationName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: isMobile ? 13.5 : 14.5,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          state.tr('openBadge'),
                                          style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.green),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.tr('stationBishoftuLocation'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
                              icon: const Icon(Icons.navigation_rounded, size: 14),
                              label: Text(
                                state.tr('openGoogleMaps'),
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 11.5 : 12.5),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 15, vertical: isMobile ? 10 : 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 6. Footer (Localized)
                  FadeTransition(
                    opacity: _mapsFade,
                    child: Text(
                      '© ${DateTime.now().year} BISHE Car Wash Services • ${state.tr('bishoftu')}',
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


}
