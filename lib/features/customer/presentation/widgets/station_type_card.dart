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
  final bool isCarpet;

  const StationTypeCard({
    super.key,
    required this.serviceType,
    required this.isSelected,
    required this.onTap,
    required this.availableCapacity,
    this.isCarpet = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isStation = serviceType == ServiceType.walkInStation;
    final isValet = serviceType == ServiceType.valetPickUp;
    final primaryAccent = isStation
        ? (isCarpet ? const Color(0xFF4F46E5) : AppColors.bay1Color)
        : (isValet ? const Color(0xFF7C3AED) : (isCarpet ? const Color(0xFF0D9488) : AppColors.mobileVanColor));

    final title = isCarpet
        ? (isStation
            ? state.tr('carpetStationService')
            : (isValet ? state.tr('carpetValetTitle') : state.tr('carpetHomeTitle')))
        : (isStation
            ? state.tr('driveInStation')
            : (isValet ? state.tr('serviceValetPickUp') : state.tr('atHomeMobile')));
    final subtitle = isCarpet
        ? (isStation
            ? state.tr('carpetStationSub')
            : (isValet ? state.tr('carpetValetSub') : state.tr('carpetHomeSub')))
        : (isStation
            ? state.tr('driveInSub')
            : (isValet
                ? state.tr('serviceValetPickUpSub')
                : state.tr('atHomeSub')));
    final imageUrl = isCarpet
        ? (isStation
            ? AutoCareAssets.carpetStationWashUrl
            : (isValet ? AutoCareAssets.carpetValetPickupUrl : AutoCareAssets.carpetHomeWashUrl))
        : (isStation
            ? AutoCareAssets.stationBayUrl
            : (isValet ? AutoCareAssets.valetDriverUrl : AutoCareAssets.mobileVanUrl));
    final fallbackIcon = isCarpet
        ? (isStation
            ? Icons.wash_rounded
            : (isValet ? Icons.local_shipping_rounded : Icons.home_repair_service_rounded))
        : serviceType.icon;
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
              imageUrl: imageUrl,
              width: 54,
              height: 54,
              borderRadius: 14,
              fallbackIcon: fallbackIcon,
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
