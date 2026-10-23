import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class BayLiveStatusCard extends StatelessWidget {
  final StationBay bay;
  final VoidCallback onAssignTap;
  final VoidCallback onQuickAdvanceStatus;
  final WashStatus? currentWashStatus;

  const BayLiveStatusCard({
    super.key,
    required this.bay,
    required this.onAssignTap,
    required this.onQuickAdvanceStatus,
    this.currentWashStatus,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isVacant = bay.isVacant;
    final bayColor = bay.type.color;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVacant ? AppColors.cardBorder : bayColor.withOpacity(0.5),
          width: isVacant ? 1 : 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: (isVacant ? Colors.black : bayColor).withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bayColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(bay.type.icon, size: 18, color: bayColor),
                    const SizedBox(width: 8),
                    Text(
                      bay.type.localizedName(state.currentLang),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: bayColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isVacant
                        ? AppColors.statusReady.withOpacity(0.15)
                        : bayColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isVacant ? AppColors.statusReady : bayColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isVacant ? state.tr('availableNow') : state.tr('busyWashing'),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: isVacant ? AppColors.statusReady : bayColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: isVacant
                ? _buildVacantContent(state)
                : _buildOccupiedContent(state),
          ),
        ],
      ),
    );
  }

  Widget _buildVacantContent(dynamic state) {
    return Column(
      children: [
        const SizedBox(height: 6),
        const Icon(Icons.car_repair_rounded, size: 36, color: AppColors.textMuted),
        const SizedBox(height: 8),
        Text(
          state.tr('availableNow'),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: OutlinedButton.icon(
            onPressed: onAssignTap,
            icon: const Icon(Icons.add, size: 16),
            label: Text(state.tr('assignVehicle'), style: const TextStyle(fontSize: 12.5)),
            style: OutlinedButton.styleFrom(
              foregroundColor: bay.type.color,
              side: BorderSide(color: bay.type.color, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOccupiedContent(dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bay.activeLicensePlate ?? 'Plate Unknown',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.tr("activeWashers")}: ${bay.assignedWasherName ?? "Washer"}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
            if (currentWashStatus != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: currentWashStatus!.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentWashStatus!.localizedName(state.currentLang),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: currentWashStatus!.color,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (bay.startedAt != null)
          Text(
            'Started: ${DateFormatter.formatTime(bay.startedAt!)}',
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton.icon(
            onPressed: onQuickAdvanceStatus,
            icon: const Icon(Icons.arrow_forward_rounded, size: 16),
            label: Text(
              _getQuickActionLabel(currentWashStatus, state),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: bay.type.color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  String _getQuickActionLabel(WashStatus? status, dynamic state) {
    if (status == null) return state.tr('startWashing');
    switch (status) {
      case WashStatus.assignedToBay:
        return state.tr('startWashing');
      case WashStatus.washing:
        return state.tr('setToDrying');
      case WashStatus.drying:
        return state.tr('markReady');
      case WashStatus.readyForPickup:
        return state.tr('completeArchive');
      default:
        return state.tr('startWashing');
    }
  }
}
