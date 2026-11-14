import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/tactile_bounce.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

/// Entrance Splash Screen (Concept 1: Hydro-Kinetic Neon Pulse)
/// Features official 3D chrome water shield emblem, shockwave ripple,
/// ambient hydro-particles, Bishoftu location, social dock, and auto-transition.
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
  late final Animation<Offset> _contentSlide;

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
      duration: const Duration(milliseconds: 1000),
    );

    _logoScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack),
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
        curve: const Interval(0.40, 1.0, curve: Curves.easeIn),
      ),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.40, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _logoController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  void _proceed() {
    if (_hasProceeded) return;
    _hasProceeded = true;

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
    final isCompact = size.width < 400;
    final isShort = size.height < 720;
    final logoSize = isShort ? 140.0 : 180.0;
    final shieldContainerSize = isShort ? 175.0 : 220.0;

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
                    center: const Alignment(0, -0.2),
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

            // Main Interactive Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: isCompact ? 16 : 24,
                    vertical: isShort ? 10 : 20,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isShort ? 6 : 12),

                        // Trilingual Greeting Pill
                        FadeTransition(
                          opacity: _contentFade,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.slateGlass.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.liquidCyanNeon.withValues(alpha: 0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.liquidCyanNeon.withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.liquidCyanNeon,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.liquidCyanNeon,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Baga Nagaan Dhuftan • እንኳን ደህና መጡ • Welcome',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.cyan.shade100,
                                      fontSize: isCompact ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: isShort ? 14 : 24),

                        // Logo Shield with Hydro Kinetic Shockwave
                        SizedBox(
                          width: shieldContainerSize + 30,
                          height: shieldContainerSize + 30,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Pulsing shockwave ring
                              AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, _) {
                                  final val = _pulseController.value;
                                  final scale = 1.0 + (val * 0.30);
                                  final opacity = (1.0 - val).clamp(0.0, 1.0);
                                  return Transform.scale(
                                    scale: scale,
                                    child: Container(
                                      width: shieldContainerSize,
                                      height: shieldContainerSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.liquidCyanNeon.withValues(alpha: opacity * 0.6),
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.liquidCyanNeon.withValues(alpha: opacity * 0.25),
                                            blurRadius: 24,
                                            spreadRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Inner settled glow ring
                              Container(
                                width: shieldContainerSize,
                                height: shieldContainerSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.liquidCyanNeon.withValues(alpha: 0.3),
                                      blurRadius: 36,
                                      spreadRadius: 6,
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
                                    width: logoSize,
                                    height: logoSize,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(24),
                                      border: Border.all(
                                        color: AppColors.liquidCyanNeon.withValues(alpha: 0.45),
                                        width: 1.8,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.8),
                                          blurRadius: 25,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/images/bishe_logo.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Center(
                                          child: Icon(
                                            Icons.local_car_wash_rounded,
                                            size: 70,
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

                        SizedBox(height: isShort ? 14 : 20),

                        // Title & Studio Tagline
                        SlideTransition(
                          position: _contentSlide,
                          child: FadeTransition(
                            opacity: _contentFade,
                            child: Column(
                              children: [
                                Text(
                                  'BISHE CAR WASH',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isCompact ? 22 : 25,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.4,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: AppColors.liquidCyanNeon.withValues(alpha: 0.6),
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  state.tr('entranceTagline'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isCompact ? 12 : 13,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: isShort ? 8 : 12),

                                // Bishoftu Lake Hora Address Chip
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: AppColors.slateGlass.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white12,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.location_on_rounded,
                                        size: 15,
                                        color: AppColors.warmAmberSunset,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          state.tr('entranceLocation'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: isCompact ? 11 : 12,
                                            color: Colors.white.withValues(alpha: 0.85),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: isShort ? 14 : 20),

                                // Glass Social Connect Dock
                                Text(
                                  state.tr('socialConnect'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                    color: Colors.white.withValues(alpha: 0.45),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
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
                                      onTap: () => UrlLauncherHelper.openUrl('tel:0962274450'),
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

                                SizedBox(height: isShort ? 20 : 28),

                                // Enter Station Portal Button (Thumb-zone anchor)
                                BounceTappable(
                                  onTap: _proceed,
                                  child: Container(
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF00B4D8),
                                          Color(0xFF007791),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.liquidCyanNeon.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: AppColors.liquidCyanNeon.withValues(alpha: 0.5),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          state.tr('enterStationPortal'),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 10),
                                Text(
                                  state.tr('tapToContinue'),
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
            color: color.withValues(alpha: 0.3),
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
