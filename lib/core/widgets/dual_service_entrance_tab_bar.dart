import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_notifier.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class DualServiceEntranceTabBar extends StatelessWidget {
  final EdgeInsetsGeometry padding;

  const DualServiceEntranceTabBar({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isCarWash = state.isCarWashDivisionActive;

    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: Row(
          children: [
            // 1. Car Washing Service Tab
            Expanded(
              child: GestureDetector(
                onTap: () => state.setActiveServiceDivision(ActiveServiceDivision.carWash),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isCarWash
                        ? const LinearGradient(
                            colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isCarWash ? null : const Color(0xFF0F172A).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: isCarWash
                        ? Border.all(color: AppColors.liquidCyanNeon.withValues(alpha: 0.6), width: 1)
                        : null,
                    boxShadow: isCarWash
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: AutoCareAssets.carSedanUrl,
                        width: 32,
                        height: 32,
                        borderRadius: 8,
                        fallbackIcon: Icons.local_car_wash_rounded,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          state.tr('carWashingService'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: isCarWash ? Colors.white : Colors.white70,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // 2. Carpet Washing Service Tab
            Expanded(
              child: GestureDetector(
                onTap: () => state.setActiveServiceDivision(ActiveServiceDivision.carpetWash),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: !isCarWash
                        ? const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: !isCarWash ? null : const Color(0xFF0F172A).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: !isCarWash
                        ? Border.all(color: const Color(0xFFA78BFA).withValues(alpha: 0.6), width: 1)
                        : null,
                    boxShadow: !isCarWash
                        ? [
                            BoxShadow(
                              color: const Color(0xFF7C3AED).withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: AutoCareAssets.carpetTypeAUrl,
                        width: 32,
                        height: 32,
                        borderRadius: 8,
                        fallbackIcon: Icons.texture_rounded,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          state.tr('carpetWashingService'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: !isCarWash ? Colors.white : Colors.white70,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
