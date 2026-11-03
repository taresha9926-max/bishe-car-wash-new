import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Modern capsule meter bar with animated gradient fill, rounded ends,
/// and optional metrics header (label, leading icon, and trailing value).
class RoundedMeterBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final String? label;
  final String? valueText;
  final IconData? icon;
  final List<Color> gradientColors;
  final Color trackColor;
  final Color? labelColor;
  final Color? valueColor;
  final Duration duration;

  const RoundedMeterBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.label,
    this.valueText,
    this.icon,
    this.gradientColors = const [AppColors.primary, AppColors.secondary],
    this.trackColor = const Color(0xFFE2E8F0),
    this.labelColor,
    this.valueColor,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    final clampedProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || valueText != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 14, color: gradientColors.first),
                      const SizedBox(width: 5),
                    ],
                    if (label != null)
                      Text(
                        label!,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: labelColor ?? AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
                if (valueText != null)
                  Text(
                    valueText!,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: valueColor ?? gradientColors.first,
                    ),
                  ),
              ],
            ),
          ),
        ],
        Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: clampedProgress),
            duration: duration,
            curve: Curves.easeOutCubic,
            builder: (context, val, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: val.clamp(0.001, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(height / 2),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
