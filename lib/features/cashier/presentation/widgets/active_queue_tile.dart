import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class ActiveQueueTile extends StatelessWidget {
  final WashBooking booking;
  final VoidCallback onAssignBayWasher;
  final VoidCallback onProcessPayment;
  final VoidCallback onUpdateStatus;

  const ActiveQueueTile({
    super.key,
    required this.booking,
    required this.onAssignBayWasher,
    required this.onProcessPayment,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final payment = booking.payment;
    final isPaid = payment.isPaid;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: License Plate, Car Type, Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Text(
                      booking.licensePlate,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(booking.carType.icon, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    booking.carType.localizedName(state.currentLang),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              StatusBadge(
                label: booking.status.localizedName(state.currentLang),
                color: booking.status.color,
                icon: booking.status.icon,
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 2: Customer, Package, Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.package.localizedName(state.currentLang),
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${booking.customerName} • ${booking.customerPhone}',
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                CurrencyFormatter.format(booking.totalPrice),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Row 3: Bay & Washer assignments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.garage_rounded,
                      size: 14,
                      color: booking.assignedBay != null ? booking.assignedBay!.color : AppColors.textMuted,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      booking.assignedBay != null ? booking.assignedBay!.shortName : 'No Bay',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: booking.assignedBay != null ? booking.assignedBay!.color : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 14, color: AppColors.cardBorder),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      booking.assignedWasherName ?? 'Unassigned',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                Container(width: 1, height: 14, color: AppColors.cardBorder),
                Row(
                  children: [
                    Icon(
                      payment.method.icon,
                      size: 13,
                      color: isPaid ? AppColors.statusReady : AppColors.statusPending,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isPaid ? 'PAID (${payment.method.shortName})' : 'UNPAID',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isPaid ? AppColors.statusReady : AppColors.statusPending,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons Bar
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 34,
                  child: OutlinedButton.icon(
                    onPressed: onAssignBayWasher,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 15),
                    label: Text(state.tr('assignBayWasher'), style: const TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: const BorderSide(color: AppColors.primary, width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!isPaid) ...[
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: ElevatedButton.icon(
                      onPressed: onProcessPayment,
                      icon: const Icon(Icons.payments_rounded, size: 15),
                      label: Text(state.tr('payButton'), style: const TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cashGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              SizedBox(
                height: 34,
                child: IconButton.filledTonal(
                  onPressed: onUpdateStatus,
                  tooltip: 'Next Status',
                  icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
