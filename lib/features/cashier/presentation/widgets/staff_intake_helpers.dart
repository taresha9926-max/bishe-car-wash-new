import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../admin/domain/models/staff_member.dart';
import '../../../booking_service/domain/models/service_type.dart';

/// Shared editable negotiated-total card used across both Custom Detailing
/// and Preset Packages in Walk-In Registration and Phone Booking.
class StaffNegotiatedPriceCard extends StatelessWidget {
  final dynamic state;
  final TextEditingController controller;
  final double baseSuggestedPrice;
  final double deliveryAddonFee;
  final VoidCallback onUseSuggested;
  final VoidCallback onChanged;

  const StaffNegotiatedPriceCard({
    super.key,
    required this.state,
    required this.controller,
    required this.baseSuggestedPrice,
    required this.deliveryAddonFee,
    required this.onUseSuggested,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final fullSuggested = baseSuggestedPrice + deliveryAddonFee;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.handshake_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.tr('negotiatedTotalPriceTitle'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                ),
              ),
              TextButton(
                onPressed: onUseSuggested,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '${state.tr("useSuggestedPrice")} (${fullSuggested.toStringAsFixed(0)} ETB)',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          if (deliveryAddonFee > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${state.tr("basePrice")}: ${CurrencyFormatter.format(baseSuggestedPrice)}  •  ${state.tr("deliveryAddonIncluded")}: +${CurrencyFormatter.format(deliveryAddonFee)}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
            ),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onChanged(),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixText: 'ETB',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared Washer picker used during Walk-In & Phone booking intake so
/// customer tips credit 100% to that booking's assigned washer.
class StaffWasherPickerCard extends StatelessWidget {
  final dynamic state;
  final List<StaffMember> washers;
  final String? selectedWasherId;
  final ValueChanged<StaffMember?> onChanged;

  const StaffWasherPickerCard({
    super.key,
    required this.state,
    required this.washers,
    required this.selectedWasherId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validSelected = washers.any((w) => w.id == selectedWasherId) ? selectedWasherId : null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.cleaning_services_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  state.tr('assignWasherDuringBooking'),
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            initialValue: validSelected,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceVariant.withValues(alpha: 0.45),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(
                  state.tr('noWasherAssignedOption'),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ),
              ...washers.map((w) {
                final busyTag = w.isAvailable ? '' : ' • ${state.tr("busyLabel")}';
                return DropdownMenuItem<String?>(
                  value: w.id,
                  child: Text(
                    '${w.name}$busyTag',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                );
              }),
            ],
            onChanged: (val) {
              if (val == null) {
                onChanged(null);
              } else {
                onChanged(washers.firstWhere((w) => w.id == val));
              }
            },
          ),
        ],
      ),
    );
  }
}

/// Shared 3-option delivery mode selector showing live flat add-on fee badges.
class StaffDeliveryModeSelector extends StatelessWidget {
  final dynamic state;
  final ServiceType selectedMode;
  final bool isCarpet;
  final ValueChanged<ServiceType> onChanged;

  const StaffDeliveryModeSelector({
    super.key,
    required this.state,
    required this.selectedMode,
    required this.isCarpet,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      (
        ServiceType.walkInStation,
        isCarpet ? state.tr('carpetStationService') : state.tr('walkInStation'),
        Icons.storefront_rounded,
        isCarpet ? const Color(0xFF4F46E5) : AppColors.bay1Color,
      ),
      (
        ServiceType.valetPickUp,
        isCarpet ? state.tr('carpetValetTitle') : state.tr('serviceValetPickUp'),
        Icons.directions_car_rounded,
        const Color(0xFF7C3AED),
      ),
      (
        ServiceType.atHomeMobile,
        isCarpet ? state.tr('carpetHomeTitle') : state.tr('atHomeMobile'),
        Icons.home_repair_service_rounded,
        const Color(0xFF0D9488),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.tr('deliveryModeLabel'),
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          children: modes.map((entry) {
            final mode = entry.$1;
            final label = entry.$2 as String;
            final icon = entry.$3;
            final color = entry.$4;
            final isSelected = selectedMode == mode;
            final addon = state.getDeliveryAddonFee(mode, isCarpet: isCarpet) as double;

            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(mode),
                child: Container(
                  margin: EdgeInsets.only(right: mode != ServiceType.atHomeMobile ? 6 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withValues(alpha: 0.12) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? color : AppColors.cardBorder,
                      width: isSelected ? 1.8 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(icon, size: 18, color: isSelected ? color : AppColors.textMuted),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      if (addon > 0) ...[
                        const SizedBox(height: 3),
                        Text(
                          '+${addon.toStringAsFixed(0)} ETB',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
