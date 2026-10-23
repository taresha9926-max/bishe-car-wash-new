import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_status.dart';

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
                      bay.type.displayName,
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
                        isVacant ? 'VACANT' : 'ACTIVE',
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
                ? _buildVacantContent()
                : _buildOccupiedContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildVacantContent() {
    return Column(
      children: [
        const SizedBox(height: 6),
        const Icon(Icons.car_repair_rounded, size: 36, color: AppColors.textMuted),
        const SizedBox(height: 8),
        const Text(
          'Bay is clear & available',
          style: TextStyle(
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
            label: const Text('Assign Car Here', style: TextStyle(fontSize: 12.5)),
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

  Widget _buildOccupiedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VEHICLE PLATE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                ),
                Text(
                  bay.activeLicensePlate ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: AppColors.textPrimary,
                  ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(currentWashStatus!.icon, size: 12, color: currentWashStatus!.color),
                    const SizedBox(width: 4),
                    Text(
                      currentWashStatus!.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: currentWashStatus!.color,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Washer: ${bay.assignedWasherName ?? "Unassigned"}',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (bay.startedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Started: ${DateFormatter.timeAgo(bay.startedAt!)}',
                style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 36,
          child: ElevatedButton.icon(
            onPressed: onQuickAdvanceStatus,
            icon: const Icon(Icons.fast_forward_rounded, size: 16),
            label: Text(
              _getNextActionLabel(currentWashStatus),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: bay.type.color,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  String _getNextActionLabel(WashStatus? status) {
    if (status == null) return 'Update Status';
    switch (status) {
      case WashStatus.pending:
      case WashStatus.confirmed:
      case WashStatus.assignedToBay:
        return 'Start Washing';
      case WashStatus.washing:
        return 'Move to Drying';
      case WashStatus.drying:
        return 'Mark Ready for Pickup';
      case WashStatus.readyForPickup:
        return 'Complete & Free Bay';
      default:
        return 'Update Status';
    }
  }
}
