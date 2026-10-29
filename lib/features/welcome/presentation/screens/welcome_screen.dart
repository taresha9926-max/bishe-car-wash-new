import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _videoFade;
  late final Animation<Offset> _videoSlide;
  late final Animation<double> _gpsFade;
  late final Animation<Offset> _gpsSlide;
  late final Animation<double> _portalsFade;
  late final Animation<Offset> _portalsSlide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _headerFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
    );
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic)),
    );

    _videoFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.65, curve: Curves.easeIn),
    );
    _videoSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic)),
    );

    _gpsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.4, 0.85, curve: Curves.easeIn),
    );
    _gpsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic)),
    );

    _portalsFade = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
    );
    _portalsSlide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic)),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _copyGpsCoordinates(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: AppConstants.stationGpsCoordinates));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'GPS Coordinates copied: ${AppConstants.stationGpsCoordinates}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.statusReady,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 48 : 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Bar: Language Selector & Status Beacon
                  FadeTransition(
                    opacity: _headerFade,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_rounded, size: 15, color: AppColors.primary),
                              SizedBox(width: 6),
                              Text(
                                'BISHE OFFICIAL HUB',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Language Switcher Dropdown
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
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
                              icon: const Icon(Icons.language_rounded, size: 17, color: AppColors.primary),
                              items: const [
                                DropdownMenuItem(
                                  value: 'EN',
                                  child: Text('English (EN)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                ),
                                DropdownMenuItem(
                                  value: 'OM',
                                  child: Text('Afaan Oromoo (OM)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                ),
                                DropdownMenuItem(
                                  value: 'AM',
                                  child: Text('አማርኛ (AM)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                ),
                              ],
                              onChanged: (lang) {
                                if (lang != null) state.setLanguage(lang);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Brand Hero Header Card with Entrance Animation
                  SlideTransition(
                    position: _headerSlide,
                    child: FadeTransition(
                      opacity: _headerFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primaryDark, Color(0xFF1E3A8A), AppColors.primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 26,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.35), width: 2.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.local_car_wash_rounded, size: 44, color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.tr('welcomeTitle'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 27,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.92),
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Capacity & Feature Pills Row
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildFeaturePill(Icons.speed_rounded, '2 Pressure Bays'),
                                _buildFeaturePill(Icons.airport_shuttle_rounded, '1 At-Home Van'),
                                _buildFeaturePill(Icons.layers_rounded, '10 Detailing Packages'),
                                _buildFeaturePill(Icons.sms_rounded, 'Live SMS Alerts'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Commercial Advertising Video Showcase Card
                  SlideTransition(
                    position: _videoSlide,
                    child: FadeTransition(
                      opacity: _videoFade,
                      child: const AdVideoShowcaseCard(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // GPS Live Station Location Card (Exact Coordinates)
                  SlideTransition(
                    position: _gpsSlide,
                    child: FadeTransition(
                      opacity: _gpsFade,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.statusPending.withOpacity(0.45), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Location Title & Badges
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusPending.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(16),
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
                                          Flexible(
                                            child: Text(
                                              AppConstants.stationName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w900,
                                                color: AppColors.textPrimary,
                                                letterSpacing: -0.3,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: Colors.green.withOpacity(0.3)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.radar_rounded, size: 10, color: Colors.green),
                                                SizedBox(width: 4),
                                                Text(
                                                  'LIVE GPS',
                                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.green),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      const Text(
                                        'Bishoftu (Debre Zeyit), Oromia, Ethiopia',
                                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Middle Coordinates Banner
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.pin_drop_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'STATION GPS COORDINATES',
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.textMuted, letterSpacing: 0.8),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${AppConstants.stationGpsCoordinates}  (${AppConstants.stationGpsDecimal})',
                                          style: const TextStyle(
                                            fontFamily: 'monospace',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Copy GPS Coordinates',
                                    onPressed: () => _copyGpsCoordinates(context),
                                    icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Actions Row: Copy & Open in Google Maps
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _copyGpsCoordinates(context),
                                  icon: const Icon(Icons.copy_rounded, size: 15),
                                  label: const Text('Copy GPS', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textPrimary,
                                    side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
                                    icon: const Icon(Icons.navigation_rounded, size: 16),
                                    label: Text(
                                      state.tr('openGoogleMaps'),
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Gateway Heading with Section Accent
                  SlideTransition(
                    position: _portalsSlide,
                    child: FadeTransition(
                      opacity: _portalsFade,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'CHOOSE YOUR PORTAL',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // 3 Animated Interactive Portal Gateway Cards
                          _InteractivePortalCard(
                            icon: Icons.directions_car_filled_rounded,
                            color: AppColors.primary,
                            title: state.tr('customerPortal'),
                            subtitle: state.tr('customerPortalDesc'),
                            badge: 'PUBLIC ACCESS',
                            badgeColor: const Color(0xFF2563EB),
                            trustPill: 'Instant Booking • Live Wash Tracker',
                            onTap: () {
                              state.switchRole(UserRole.customer);
                              widget.onEnterCustomer?.call();
                            },
                          ),
                          const SizedBox(height: 14),

                          _InteractivePortalCard(
                            icon: Icons.point_of_sale_rounded,
                            color: AppColors.secondary,
                            title: state.tr('cashierPortal'),
                            subtitle: state.tr('cashierPortalDesc'),
                            badge: 'PIN PROTECTED',
                            badgeColor: const Color(0xFFF59E0B),
                            trustPill: 'Walk-ins • SMS Dispatch Gateway',
                            onTap: () async {
                              final auth = await RoleAuthDialog.show(context, UserRole.cashier);
                              if (auth) {
                                state.switchRole(UserRole.cashier);
                                widget.onEnterCashier?.call();
                              }
                            },
                          ),
                          const SizedBox(height: 14),

                          _InteractivePortalCard(
                            icon: Icons.admin_panel_settings_rounded,
                            color: const Color(0xFFDC2626),
                            title: state.tr('adminPortal'),
                            subtitle: state.tr('adminPortalDesc'),
                            badge: 'SUPER ADMIN',
                            badgeColor: const Color(0xFFDC2626),
                            trustPill: 'Super Attendance • Financials • Bay Logs',
                            onTap: () async {
                              final auth = await RoleAuthDialog.show(context, UserRole.admin);
                              if (auth) {
                                state.switchRole(UserRole.admin);
                                widget.onEnterAdmin?.call();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Professional Footer
                  FadeTransition(
                    opacity: _portalsFade,
                    child: Text(
                      '© ${DateTime.now().year} BISHE Car Wash Services • Powered by Clean Architecture & Supabase',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w500),
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

  Widget _buildFeaturePill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _InteractivePortalCard extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final String trustPill;
  final VoidCallback onTap;

  const _InteractivePortalCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.trustPill,
    required this.onTap,
  });

  @override
  State<_InteractivePortalCard> createState() => _InteractivePortalCardState();
}

class _InteractivePortalCardState extends State<_InteractivePortalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.015 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? widget.color.withOpacity(0.6) : AppColors.cardBorder,
              width: _isHovered ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _isHovered ? widget.color.withOpacity(0.12) : Colors.black.withOpacity(0.03),
                blurRadius: _isHovered ? 18 : 8,
                offset: Offset(0, _isHovered ? 6 : 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(20),
              splashColor: widget.color.withOpacity(0.1),
              highlightColor: widget.color.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: widget.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(widget.icon, size: 28, color: widget.color),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: widget.badgeColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.badge,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: widget.badgeColor,
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline_rounded, size: 12, color: widget.color),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.trustPill,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: widget.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: _isHovered ? widget.color : AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
