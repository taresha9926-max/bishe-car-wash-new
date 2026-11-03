import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Modern animated circular radial ring with gradient arc,
/// smooth tween physics, center metric display, and soft background track.
class AnimatedCircularRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final Color primaryColor;
  final Color? secondaryColor;
  final Color trackColor;
  final String centerValue;
  final String? centerLabel;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;
  final Duration duration;

  const AnimatedCircularRing({
    super.key,
    required this.progress,
    this.size = 80,
    this.strokeWidth = 7,
    this.primaryColor = AppColors.primary,
    this.secondaryColor,
    this.trackColor = const Color(0xFFE2E8F0),
    required this.centerValue,
    this.centerLabel,
    this.valueStyle,
    this.labelStyle,
    this.duration = const Duration(milliseconds: 900),
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    final secColor = secondaryColor ?? primaryColor.withValues(alpha: 0.7);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: clampedProgress),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _CircularRingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  primaryColor: primaryColor,
                  secondaryColor: secColor,
                  trackColor: trackColor,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    centerValue,
                    textAlign: TextAlign.center,
                    style: valueStyle ??
                        TextStyle(
                          fontSize: size * 0.20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                  ),
                  if (centerLabel != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      centerLabel!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: labelStyle ??
                          TextStyle(
                            fontSize: size * 0.12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CircularRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color primaryColor;
  final Color secondaryColor;
  final Color trackColor;

  _CircularRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.primaryColor,
    required this.secondaryColor,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.001) return;

    // 2. Gradient Arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      colors: [primaryColor, secondaryColor],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at top 12 o'clock
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
