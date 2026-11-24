import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

/// Renders a digital wash ticket and 6-stage wash progress stepper
/// once a prototype booking is submitted.
class PrototypeLiveTicketView extends StatelessWidget {
  final WashBooking booking;
  final VoidCallback onReset;
  final VoidCallback onOpenLounge;

  const PrototypeLiveTicketView({
    super.key,
    required this.booking,
    required this.onReset,
    required this.onOpenLounge,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final lang = state.currentLang;

    final stages = [
      {'status': WashStatus.pending, 'label': state.tr('statusConfirmed')},
      {'status': WashStatus.assignedToBay, 'label': state.tr('statusAssignedToBay')},
      {'status': WashStatus.washing, 'label': state.tr('statusWashing')},
      {'status': WashStatus.drying, 'label': state.tr('statusDrying')},
      {'status': WashStatus.readyForPickup, 'label': state.tr('statusReadyForPickup')},
      {'status': WashStatus.completed, 'label': state.tr('statusCompleted')},
    ];

    final currentIdx = stages.indexWhere((s) => s['status'] == booking.status);
    final activeStageIndex = currentIdx == -1 ? 1 : currentIdx;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF007791),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 44),
                const SizedBox(height: 8),
                Text(
                  state.tr('bookingConfirmedTitle'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.tr('ticketRef')}: ${booking.id}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Vehicle & Bay Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('licensePlate'),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            booking.licensePlate,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          booking.assignedBay?.name.toUpperCase() ?? 'BAY 1',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: AppColors.cardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        booking.package.localizedName(lang),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${booking.payment.amount.toStringAsFixed(0)} ETB',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 6-Stage Visual Stepper
          Text(
            state.tr('washProgressStepperTitle'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.cardBorder),
            ),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(stages.length, (index) {
                  final stage = stages[index];
                  final isDone = index < activeStageIndex;
                  final isCurrent = index == activeStageIndex;
                  final isPending = index > activeStageIndex;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDone
                                  ? Colors.teal
                                  : isCurrent
                                      ? AppColors.primary
                                      : Colors.grey.shade200,
                            ),
                            child: Icon(
                              isDone
                                  ? Icons.check
                                  : isCurrent
                                      ? Icons.hourglass_top_rounded
                                      : Icons.circle,
                              size: 16,
                              color: isPending ? Colors.grey : Colors.white,
                            ),
                          ),
                          if (index < stages.length - 1)
                            Container(
                              width: 2,
                              height: 24,
                              color: isDone ? Colors.teal : Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            stage['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                              color: isCurrent
                                  ? AppColors.textPrimary
                                  : isDone
                                      ? Colors.teal.shade800
                                      : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Station Lounge Callout
          OutlinedButton.icon(
            onPressed: onOpenLounge,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.ondemand_video_rounded, color: AppColors.primary),
            label: Text(
              state.tr('exploreStationLoungeBtn'),
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 12),

          // Book Another
          TextButton(
            onPressed: onReset,
            child: Text(state.tr('bookAnotherVehicleBtn')),
          ),
        ],
      ),
    );
  }
}
