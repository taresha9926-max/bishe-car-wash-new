import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/tactile_bounce.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

/// Entrance Splash Screen (Concept 1: Hydro-Kinetic Neon Pulse)
/// Features official 3D chrome supercar emblem covering ~90% of screen,
/// hydro-kinetic shockwave ripple, ambient hydro-particles,
/// glass social media pills dock, "Tap anywhere to continue",
/// tap-anywhere navigation, and a 10-second auto-transition fallback.
class EntranceSplashScreen extends StatefulWidget {
  final VoidCallback? onProceed;

  const EntranceSplashScreen({
    super.key,
    this.onProceed,
  });

  @override
  State<EntranceSplashScreen> createState() => _EntranceSplashScreenState();
}

class _EntranceSplashScreenState extends State<EntranceSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _logoController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _contentFade;

  Timer? _autoTransitionTimer;
  bool _hasProceeded = false;

  @override
  void initState() {
    super.initState();

    // 1. Repeating Shockwave Ripple & Particles (continuous animation until clicked)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // 2. Entrance Sequence Controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.80, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _contentFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();

    // 3. Auto-transition fallback after 10 seconds
    _autoTransitionTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) _proceed();
    });
  }

  @override
  void dispose() {
    _autoTransitionTimer?.cancel();
    _pulseController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_hasProceeded) return;
    _hasProceeded = true;
    _autoTransitionTimer?.cancel();

    if (widget.onProceed != null) {
      widget.onProceed!();
    } else {
      final state = AppStateProvider.of(context);
      state.completeEntranceSplash();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final size = MediaQuery.of(context).size;

    // Largest space coverage (~90% of screen width)
    final logoWidth = (size.width * 0.90).clamp(280.0, 520.0);
    final logoHeight = (size.height * 0.62).clamp(260.0, 520.0);

    return Scaffold(
      backgroundColor: AppColors.midnightCanvas,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceed,
        child: Stack(
          children: [
            // Ambient Radial Gradient
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.15),
                    radius: 1.1,
                    colors: [
                      const Color(0xFF00384D).withValues(alpha: 0.45),
                      AppColors.midnightCanvas,
                    ],
                  ),
                ),
              ),
            ),

            // Animated Hydro Kinetic Bubbles
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _HydroBubblesPainter(progress: _pulseController.value),
                  );
                },
              ),
            ),

            // Main Content Layout
            SafeArea(
              child: Column(
                children: [
                  // Center: 90% Screen Space Dominant 3D Supercar Logo
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing shockwave halo
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              final val = _pulseController.value;
                              final scale = 1.0 + (val * 0.12);
                              final opacity = (1.0 - val).clamp(0.0, 1.0);
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  width: logoWidth,
                                  height: logoHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color: AppColors.liquidCyanNeon.withValues(alpha: opacity * 0.65),
                                      width: 2.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.liquidCyanNeon.withValues(alpha: opacity * 0.35),
                                        blurRadius: 36,
                                        spreadRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),

                          // Inner settled glow ring
                          Container(
                            width: logoWidth,
                            height: logoHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.liquidCyanNeon.withValues(alpha: 0.28),
                                  blurRadius: 40,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),

                          // Animated Logo Card
                          ScaleTransition(
                            scale: _logoScale,
                            child: FadeTransition(
                              opacity: _logoOpacity,
                              child: Container(
                                width: logoWidth,
                                height: logoHeight,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(28),
                                  border: Border.all(
                                    color: AppColors.liquidCyanNeon.withValues(alpha: 0.60),
                                    width: 2.0,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.85),
                                      blurRadius: 32,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.asset(
                                  'assets/images/bishe_logo.jpg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.local_car_wash_rounded,
                                        size: 110,
                                        color: AppColors.liquidCyanNeon,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Dock: Social Media Pills & Tap Anywhere Prompt
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Glass Social Media Pills
                        FadeTransition(
                          opacity: _contentFade,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildSocialPill(
                                  icon: Icons.play_arrow_rounded,
                                  label: 'TikTok',
                                  color: Colors.white,
                                  onTap: () => UrlLauncherHelper.openUrl(state.tiktokUrl),
                                ),
                                const SizedBox(width: 8),
                                _buildSocialPill(
                                  icon: Icons.send_rounded,
                                  label: 'Telegram',
                                  color: const Color(0xFF29B6F6),
                                  onTap: () => UrlLauncherHelper.openUrl('https://t.me/bishecarwash'),
                                ),
                                const SizedBox(width: 8),
                                _buildSocialPill(
                                  icon: Icons.phone_in_talk_rounded,
                                  label: 'Call',
                                  color: AppColors.warmAmberSunset,
                                  onTap: () => UrlLauncherHelper.openUrl('tel:${AppConstants.stationPhoneNumber}'),
                                ),
                                const SizedBox(width: 8),
                                _buildSocialPill(
                                  icon: Icons.map_rounded,
                                  label: 'Maps',
                                  color: AppColors.liquidCyanNeon,
                                  onTap: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // "Tap anywhere to continue" pulsing prompt
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, _) {
                            final opacity = 0.50 + 0.50 * math.sin(_pulseController.value * 2 * math.pi);
                            return Opacity(
                              opacity: opacity.clamp(0.35, 1.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    size: 15,
                                    color: AppColors.liquidCyanNeon,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    state.tr('tapToContinue'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        Shadow(
                                          color: AppColors.liquidCyanNeon,
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialPill({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BounceTappable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.slateGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter generating subtle rising hydro-particles
class _HydroBubblesPainter extends CustomPainter {
  final double progress;

  _HydroBubblesPainter({required this.progress});

  static final List<math.Point<double>> _bubbleSeeds = List.generate(
    14,
    (i) => math.Point((i * 37 % 100) / 100.0, ((i * 59) % 100) / 100.0),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < _bubbleSeeds.length; i++) {
      final seed = _bubbleSeeds[i];
      final x = seed.x * size.width;
      final speed = 0.4 + (i % 3) * 0.2;
      final rawY = (seed.y - (progress * speed)) % 1.0;
      final y = (rawY < 0 ? rawY + 1.0 : rawY) * size.height;

      final radius = 2.0 + (i % 4) * 1.5;
      final alpha = (0.12 + 0.15 * math.sin((progress + i) * math.pi)).clamp(0.05, 0.28);

      paint.color = AppColors.liquidCyanNeon.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HydroBubblesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
