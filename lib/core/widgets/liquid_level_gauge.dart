import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';

/// Animated 3D chemical canister liquid level gauge with glowing meniscus line
/// and real-time depletion status.
class LiquidLevelGauge extends StatelessWidget {
  final String title;
  final double currentLevel; // 0.0 to 1.0
  final String currentAmountStr;
  final String maxAmountStr;
  final Color? fluidColor;
  final double height;
  final double width;

  const LiquidLevelGauge({
    super.key,
    required this.title,
    required this.currentLevel,
    required this.currentAmountStr,
    required this.maxAmountStr,
    this.fluidColor,
    this.height = 140,
    this.width = 70,
  });

  Color _getStatusColor() {
    if (fluidColor != null) return fluidColor!;
    if (currentLevel < 0.20) return Colors.redAccent;
    if (currentLevel < 0.40) return AppColors.warmAmberSunset;
    return AppColors.liquidCyanNeon;
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final clampedLevel = currentLevel.clamp(0.0, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Cylinder Tube
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0C12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Measurement ticks on glass
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      4,
                      (_) => Container(
                        height: 1,
                        width: width * 0.4,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ),

                // Fluid level container
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  heightFactor: clampedLevel,
                  widthFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          statusColor.withValues(alpha: 0.85),
                          statusColor.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 3,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),

                // Percentage overlay
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${(clampedLevel * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Title and quantity
        Text(
          title,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '$currentAmountStr / $maxAmountStr',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ],
    );
  }
}
