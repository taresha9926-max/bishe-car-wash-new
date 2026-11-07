import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../booking_service/domain/models/wash_status.dart';

class LiveWashStepper extends StatelessWidget {
  final WashStatus currentStatus;
  final bool isCarpet;

  const LiveWashStepper({
    super.key,
    required this.currentStatus,
    this.isCarpet = false,
  });

  static const List<WashStatus> _steps = [
    WashStatus.confirmed,
    WashStatus.assignedToBay,
    WashStatus.washing,
    WashStatus.drying,
    WashStatus.readyForPickup,
    WashStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(currentStatus);

    return Column(
      children: List.generate(_steps.length, (index) {
        final step = _steps[index];
        final isDone = currentIndex > index || currentStatus == WashStatus.completed;
        final isCurrent = currentIndex == index && currentStatus != WashStatus.completed;
        final isLast = index == _steps.length - 1;
        final stepIcon = isCarpet
            ? (step == WashStatus.assignedToBay
                ? Icons.layers_rounded
                : (step == WashStatus.washing ? Icons.wash_rounded : step.icon))
            : step.icon;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppColors.statusCompleted
                        : (isCurrent ? step.color : AppColors.surfaceVariant),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? step.color : (isDone ? AppColors.statusCompleted : AppColors.cardBorder),
                      width: isCurrent ? 3 : 1.5,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: step.color.withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      isDone ? Icons.check : stepIcon,
                      size: 18,
                      color: isDone || isCurrent ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 38,
                    margin: const EdgeInsets.symmetric(vertical: 3),
                    color: isDone ? AppColors.statusCompleted : AppColors.cardBorder,
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isCarpet && step == WashStatus.assignedToBay ? 'Assigned to Wash Floor' : step.displayName,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isCurrent ? FontWeight.w800 : (isDone ? FontWeight.w700 : FontWeight.w500),
                            color: isCurrent
                                ? step.color
                                : (isDone ? AppColors.textPrimary : AppColors.textMuted),
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: step.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getStepSubtitle(step, isCurrent, isDone, isCarpet: isCarpet),
                      style: TextStyle(
                        fontSize: 12,
                        color: isCurrent ? AppColors.textSecondary : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _getStepSubtitle(WashStatus status, bool isCurrent, bool isDone, {bool isCarpet = false}) {
    if (isDone) return 'Completed successfully';
    if (isCarpet) {
      switch (status) {
        case WashStatus.confirmed:
          return 'Carpet received & registered into cleaning queue';
        case WashStatus.assignedToBay:
          return 'Carpet laid on dedicated wash floor for treatment';
        case WashStatus.washing:
          return 'Deep rotary shampoo scrub, dust extraction & stain treatment';
        case WashStatus.drying:
          return 'Transferred to ventilated drying racks for thorough drying';
        case WashStatus.readyForPickup:
          return 'Inspection passed, sanitized, rolled & ready for pickup/delivery';
        case WashStatus.completed:
          return 'Carpet delivered safely to customer';
        default:
          return '';
      }
    }
    switch (status) {
      case WashStatus.confirmed:
        return 'Booking verified & added to queue';
      case WashStatus.assignedToBay:
        return 'Vehicle pulled into designated service bay';
      case WashStatus.washing:
        return 'High pressure active foam spray & wheel rinse';
      case WashStatus.drying:
        return 'Hand microfiber drying, vacuum & window polish';
      case WashStatus.readyForPickup:
        return 'Final inspection passed, ready for customer handover';
      case WashStatus.completed:
        return 'Payment settled & gate pass issued';
      default:
        return '';
    }
  }
}
