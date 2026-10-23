import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../admin/domain/models/staff_member.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class BayAssignmentModal extends StatefulWidget {
  final WashBooking booking;

  const BayAssignmentModal({
    super.key,
    required this.booking,
  });

  static Future<void> show(BuildContext context, WashBooking booking) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BayAssignmentModal(booking: booking),
    );
  }

  @override
  State<BayAssignmentModal> createState() => _BayAssignmentModalState();
}

class _BayAssignmentModalState extends State<BayAssignmentModal> {
  late BayType _selectedBay;
  StaffMember? _selectedWasher;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedBay = widget.booking.assignedBay ?? BayType.bay1;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final washers = state.availableWashers;

    if (_selectedWasher == null && washers.isNotEmpty) {
      if (widget.booking.assignedWasherId != null) {
        _selectedWasher = washers.firstWhere(
          (w) => w.id == widget.booking.assignedWasherId,
          orElse: () => washers.first,
        );
      } else {
        _selectedWasher = washers.first;
      }
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Assign Bay & Washer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Vehicle: ${widget.booking.licensePlate} (${widget.booking.carType.displayName})',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 24),

          // 1. Bay Selection (Bay 1, Bay 2, Mobile Van)
          const Text(
            'Select Station Bay or Van',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: BayType.values.map((bayType) {
              final isSelected = bayType == _selectedBay;
              final bayData = state.bays.firstWhere(
                (b) => b.type == bayType,
                orElse: () => StationBay(type: bayType),
              );
              final isVacant = bayData.isVacant;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBay = bayType;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: bayType != BayType.values.last ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? bayType.color.withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? bayType.color : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(bayType.icon, color: bayType.color, size: 24),
                        const SizedBox(height: 6),
                        Text(
                          bayType.shortName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? bayType.color : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isVacant ? 'FREE' : 'IN USE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isVacant ? AppColors.statusReady : AppColors.statusPending,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // 2. Washer Selection
          const Text(
            'Select Dedicated Washer',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<StaffMember>(
                isExpanded: true,
                value: _selectedWasher,
                items: washers.map((washer) {
                  return DropdownMenuItem<StaffMember>(
                    value: washer,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: AppColors.primary.withOpacity(0.12),
                          child: Text(
                            washer.name.substring(0, 1),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${washer.name} (${washer.role.displayName})',
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (washer.isAvailable ? AppColors.statusReady : AppColors.statusPending).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            washer.isAvailable ? 'AVAILABLE' : 'BUSY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: washer.isAvailable ? AppColors.statusReady : AppColors.statusPending,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedWasher = val;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Confirm Button
          CustomButton(
            text: 'Save Assignment & Station Car',
            icon: Icons.check,
            isLoading: _isSaving,
            onPressed: () => _handleSave(context),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    if (_selectedWasher == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final state = AppStateProvider.read(context);
      await state.assignBayAndWasher(
        bookingId: widget.booking.id,
        bay: _selectedBay,
        washerId: _selectedWasher!.id,
        washerName: _selectedWasher!.name,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text(
              '${widget.booking.licensePlate} assigned to ${_selectedBay.displayName} with ${_selectedWasher!.name}',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}
