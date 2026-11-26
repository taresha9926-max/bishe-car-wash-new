import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/widgets/tactile_bounce.dart';

/// Centralized glassmorphism design system for the Obsidian Automotive Studio.
/// Provides unified glass surfaces, metallic border gradients, and card containers.
class AppGlass {
  AppGlass._();

  /// Standard dark slate glass card decoration with metallic cyan neon border.
  static BoxDecoration cardDecoration({
    Color? borderColor,
    double radius = 16,
    List<Color>? gradientColors,
    bool glow = false,
    Color? glowColor,
  }) {
    final border = borderColor ?? AppColors.cardBorder;
    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors ??
            const [
              Color(0xFF162032),
              Color(0xFF0F172A),
            ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.45),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
        if (glow)
          BoxShadow(
            color: (glowColor ?? AppColors.liquidCyanNeon).withValues(alpha: 0.22),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
      ],
    );
  }

  /// Floating segmented pill tab decoration.
  static BoxDecoration pillDecoration({
    Color? activeColor,
    bool isActive = false,
    double radius = 24,
  }) {
    if (isActive) {
      final color = activeColor ?? AppColors.primary;
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );
    }
    return BoxDecoration(
      color: const Color(0xFF0F172A).withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
    );
  }

  /// Frosted glass bottom sheet or dialog decoration.
  static BoxDecoration modalDecoration({
    double radius = 24,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: const Color(0xFF111827),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? AppColors.liquidCyanNeon.withValues(alpha: 0.3),
        width: 1.4,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.65),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: AppColors.liquidCyanNeon.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Compact status badge decoration with glowing border.
  static BoxDecoration badgeDecoration({
    required Color accent,
    double radius = 8,
  }) {
    return BoxDecoration(
      color: accent.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.1),
    );
  }
}

/// Reusable interactive tactile glass card.
class AppGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double radius;
  final bool glow;
  final Color? glowColor;

  const AppGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.onTap,
    this.borderColor,
    this.radius = 16,
    this.glow = false,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: AppGlass.cardDecoration(
        borderColor: borderColor,
        radius: radius,
        glow: glow,
        glowColor: glowColor,
      ),
      child: child,
    );

    if (onTap != null) {
      return BounceTappable(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
