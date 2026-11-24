import 'package:flutter/material.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

/// Digital wash ticket and 6-stage wash progress stepper styled with
/// Apple Design standards: Action Blue (#0071E3), clean hairline borders (#E5E5EA),
/// stadium pill buttons, and robust out-of-bounds protection.
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

    // Apple Style Tokens
    const appleActionBlue = Color(0xFF0071E3);
    const appleInk = Color(0xFF1D1D1F);
    const appleMuted = Color(0xFF86868B);
    const appleHairline = Color(0xFFE5E5EA);

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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Apple Action Blue Success Banner
          Container(
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
            decoration: BoxDecoration(
              color: appleActionBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: appleActionBlue.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 44),
                const SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    state.tr('bookingConfirmedTitle'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '${state.tr('ticketRef')}: ${booking.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Vehicle & Bay Card (Apple Studio White Card)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appleHairline),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('licensePlate'),
                            style: const TextStyle(
                              color: appleMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            booking.licensePlate,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                              color: appleInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(9999),
                        border: Border.all(color: appleActionBlue.withOpacity(0.3)),
                      ),
                      child: Text(
                        booking.assignedBay?.name.toUpperCase() ?? 'BAY 1',
                        style: const TextStyle(
                          color: appleActionBlue,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(height: 1, color: appleHairline),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.package.localizedName(lang),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: appleInk,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${booking.payment.amount.toStringAsFixed(0)} ETB',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: appleActionBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 6-Stage Visual Stepper
          Text(
            state.tr('washProgressStepperTitle'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
              color: appleInk,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: appleHairline),
            ),
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
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone || isCurrent ? appleActionBlue : const Color(0xFFF5F5F7),
                            border: isPending ? Border.all(color: const Color(0xFFD2D2D7)) : null,
                          ),
                          child: Center(
                            child: isDone
                                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                : isCurrent
                                    ? Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(0xFFD2D2D7),
                                        ),
                                      ),
                          ),
                        ),
                        if (index < stages.length - 1)
                          Container(
                            width: 2,
                            height: 28,
                            color: isDone ? appleActionBlue : const Color(0xFFE5E5EA),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          stage['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                            color: isCurrent
                                ? appleInk
                                : isDone
                                    ? appleActionBlue
                                    : appleMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 24),

          // Station Lounge Stadium Pill Callout
          ElevatedButton.icon(
            onPressed: onOpenLounge,
            style: ElevatedButton.styleFrom(
              backgroundColor: appleActionBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.ondemand_video_rounded, size: 18),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                state.tr('exploreStationLoungeBtn'),
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Book Another Action
          TextButton(
            onPressed: onReset,
            style: TextButton.styleFrom(
              foregroundColor: appleMuted,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              state.tr('bookAnotherVehicleBtn'),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
