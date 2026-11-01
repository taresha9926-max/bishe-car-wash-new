import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class StationTypeCard extends StatelessWidget {
  final ServiceType serviceType;
  final bool isSelected;
  final VoidCallback onTap;
  final int availableCapacity; // e.g. 2 bays or 1 mobile van

  const StationTypeCard({
    super.key,
    required this.serviceType,
    required this.isSelected,
    required this.onTap,
    required this.availableCapacity,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isStation = serviceType == ServiceType.walkInStation;
    final isValet = serviceType == ServiceType.valetPickUp;
    final primaryAccent = isStation
        ? AppColors.bay1Color
        : (isValet ? const Color(0xFF7C3AED) : AppColors.mobileVanColor);

    final title = isStation
        ? state.tr('driveInStation')
        : (isValet ? 'Driver Pick-up & Return' : state.tr('atHomeMobile'));
    final subtitle = isStation
        ? state.tr('driveInSub')
        : (isValet
            ? 'Dedicated driver picks up your car in Bishoftu, washes it at our station, and returns it clean to your doorstep.'
            : state.tr('atHomeSub'));
    final badgeText = availableCapacity > 0 ? state.tr('availableNow') : state.tr('busyWashing');

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? primaryAccent.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryAccent : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoCareAssets.buildPhotoThumbnail(
              imageUrl: isStation
                  ? AutoCareAssets.stationBayUrl
                  : (isValet ? AutoCareAssets.valetDriverUrl : AutoCareAssets.mobileVanUrl),
              width: 54,
              height: 54,
              borderRadius: 14,
              fallbackIcon: serviceType.icon,
              fallbackColor: primaryAccent,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? primaryAccent : AppColors.textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (availableCapacity > 0 ? AppColors.statusReady : AppColors.statusCancelled)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badgeText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: availableCapacity > 0 ? AppColors.statusReady : AppColors.statusCancelled,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primaryAccent : Colors.transparent,
                border: Border.all(
                  color: isSelected ? primaryAccent : AppColors.cardBorder,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
