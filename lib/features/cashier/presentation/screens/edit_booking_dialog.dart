import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/widgets/custom_button.dart';
import 'package:bishe_car_wash/core/widgets/custom_text_field.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class EditBookingDialog extends StatefulWidget {
  final WashBooking booking;

  const EditBookingDialog({super.key, required this.booking});

  static Future<void> show(BuildContext context, WashBooking booking) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EditBookingDialog(booking: booking),
    );
  }

  @override
  State<EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends State<EditBookingDialog> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _plateController;
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _priceController;
  late final TextEditingController _notesController;
  late final TextEditingController _dimensionsController;
  late final TextEditingController _areaController;

  late CarType _carType;
  late WashPackage _package;
  late String _carpetType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final b = widget.booking;
    _plateController = TextEditingController(text: b.licensePlate);
    _nameController = TextEditingController(text: b.customerName);
    _phoneController = TextEditingController(text: b.customerPhone);
    final initialPrice = b.payment.amount > 0 ? b.payment.amount : b.totalPrice;
    _priceController = TextEditingController(text: initialPrice.toStringAsFixed(0));
    _notesController = TextEditingController(text: b.deliveryLocation ?? '');
    _dimensionsController = TextEditingController(text: b.carpetDimensions ?? '');
    _areaController = TextEditingController(
      text: b.carpetAreaSqMeters != null ? b.carpetAreaSqMeters!.toStringAsFixed(1) : '',
    );
    _carType = b.carType;
    _package = b.package;
    _carpetType = b.carpetType ?? 'type_a';
  }

  @override
  void dispose() {
    _plateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    _dimensionsController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isCarpet = widget.booking.isCarpet;

    return Dialog(
      backgroundColor: const Color(0xFF10131C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.cardBorder, width: 1.2),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isCarpet ? const Color(0xFF7C3AED) : AppColors.warmGold).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isCarpet ? Icons.texture_rounded : Icons.edit_note_rounded,
                        color: isCarpet ? const Color(0xFFA78BFA) : const Color(0xFFFBBF24),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('editBooking'),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            'ID: ${widget.booking.id} • ${isCarpet ? state.tr("carpetService") : widget.booking.status.localizedName(state.currentLang)}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 14),

                // Scrollable Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plate or Carpet Tag
                        CustomTextField(
                          controller: _plateController,
                          label: isCarpet ? state.tr('carpetTrackingTag') : state.tr('licensePlate'),
                          hint: isCarpet ? 'e.g. CPT-8941' : 'e.g. ET-3-B98124',
                          prefixIcon: isCarpet ? Icons.tag_rounded : Icons.badge_outlined,
                          validator: (val) => val == null || val.trim().isEmpty
                              ? (isCarpet ? 'Enter tracking code' : state.tr('enterPlate'))
                              : null,
                        ),
                        const SizedBox(height: 12),

                        // Customer Name or Car Type
                        CustomTextField(
                          controller: _nameController,
                          label: state.tr('fullNameOrCarType'),
                          hint: 'e.g. Abebe Kebede / Toyota V8',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterNameOrCarType') : null,
                        ),
                        const SizedBox(height: 12),

                        // Optional Customer Phone
                        CustomTextField(
                          controller: _phoneController,
                          label: '${state.tr('customerPhone')} (${state.tr('optional')})',
                          hint: '+251 91 123 4567',
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_android,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty || val.trim() == '+251 9' || val.trim() == '+251') {
                              return null;
                            }
                            return val.length < 9 ? state.tr('enterValidPhone') : null;
                          },
                        ),
                        const SizedBox(height: 14),

                        if (!isCarpet) ...[
                          // Car Type Selection
                          Text(
                            state.tr('vehicleType'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161A26),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CarType>(
                                value: _carType,
                                isExpanded: true,
                                dropdownColor: const Color(0xFF161A26),
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                                items: CarType.values.map((ct) {
                                  return DropdownMenuItem<CarType>(
                                    value: ct,
                                    child: Text(
                                      ct.localizedName(state.currentLang),
                                      style: const TextStyle(fontSize: 13, color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newType) {
                                  if (newType != null) {
                                    setState(() {
                                      _carType = newType;
                                      _priceController.text = _package.getPriceFor(newType).toStringAsFixed(0);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Wash Package Selection
                          Text(
                            state.tr('servicePackages'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF161A26),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<WashPackage>(
                                value: state.packages.any((p) => p.id == _package.id)
                                    ? state.packages.firstWhere((p) => p.id == _package.id)
                                    : (state.packages.isNotEmpty ? state.packages.first : _package),
                                isExpanded: true,
                                dropdownColor: const Color(0xFF161A26),
                                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                                items: state.packages.map((pkg) {
                                  return DropdownMenuItem<WashPackage>(
                                    value: pkg,
                                    child: Text(
                                      '${pkg.localizedName(state.currentLang)} (${pkg.getPriceFor(_carType).toStringAsFixed(0)} ETB)',
                                      style: const TextStyle(fontSize: 13, color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (newPkg) {
                                  if (newPkg != null) {
                                    setState(() {
                                      _package = newPkg;
                                      _priceController.text = newPkg.getPriceFor(_carType).toStringAsFixed(0);
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ] else ...[
                          // Carpet Treatment Type
                          Text(
                            state.tr('carpetTypeSelection'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _carpetType = 'type_a'),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _carpetType == 'type_a' ? const Color(0xFF7C3AED).withOpacity(0.2) : const Color(0xFF161A26),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _carpetType == 'type_a' ? const Color(0xFFA78BFA) : AppColors.cardBorder,
                                        width: _carpetType == 'type_a' ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      state.tr('carpetTypeA'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _carpetType == 'type_a' ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => setState(() => _carpetType = 'type_b'),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _carpetType == 'type_b' ? const Color(0xFF7C3AED).withOpacity(0.2) : const Color(0xFF161A26),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _carpetType == 'type_b' ? const Color(0xFFA78BFA) : AppColors.cardBorder,
                                        width: _carpetType == 'type_b' ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      state.tr('carpetTypeB'),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _carpetType == 'type_b' ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  controller: _dimensionsController,
                                  label: 'Dimensions',
                                  hint: 'e.g. 3m x 2m',
                                  prefixIcon: Icons.straighten_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: CustomTextField(
                                  controller: _areaController,
                                  label: 'Area (m²)',
                                  hint: 'e.g. 6.0',
                                  keyboardType: TextInputType.number,
                                  prefixIcon: Icons.aspect_ratio_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 14),

                        // Negotiable / Custom Price (ETB)
                        CustomTextField(
                          controller: _priceController,
                          label: '${state.tr('price')} (ETB)',
                          hint: 'e.g. 350',
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.attach_money_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'Enter price';
                            final parsed = double.tryParse(val.trim());
                            if (parsed == null || parsed < 0) return 'Invalid price';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        // Notes / Location
                        CustomTextField(
                          controller: _notesController,
                          label: state.tr('notesOrSpecialInstructions'),
                          hint: 'Optional notes, service adjustments...',
                          prefixIcon: Icons.notes_rounded,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 16),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: AppColors.cardBorder),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(state.tr('cancel')),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: state.tr('saveChanges'),
                        icon: Icons.check_circle_rounded,
                        backgroundColor: AppColors.primary,
                        isLoading: _isSaving,
                        onPressed: _isSaving ? null : () => _handleSave(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final state = AppStateProvider.read(context);
    final isCarpet = widget.booking.isCarpet;
    final parsedPrice = double.tryParse(_priceController.text.trim());
    final phoneText = _phoneController.text.trim();
    final cleanPhone = (phoneText.isEmpty || phoneText == '+251 9' || phoneText == '+251') ? '' : phoneText;
    final areaVal = double.tryParse(_areaController.text.trim());

    try {
      await state.updateBookingDetails(
        bookingId: widget.booking.id,
        licensePlate: _plateController.text.trim().toUpperCase(),
        customerName: _nameController.text.trim(),
        customerPhone: cleanPhone,
        carType: isCarpet ? CarType.automobile : _carType,
        package: _package,
        customTotalPrice: parsedPrice,
        carpetType: isCarpet ? _carpetType : null,
        carpetAreaSqMeters: areaVal,
        carpetDimensions: _dimensionsController.text.trim().isNotEmpty ? _dimensionsController.text.trim() : null,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('bookingUpdatedToast')),
            backgroundColor: AppColors.cashGreen,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update booking: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
