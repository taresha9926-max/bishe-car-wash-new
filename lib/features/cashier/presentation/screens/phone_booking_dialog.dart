import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../customer/presentation/widgets/car_type_selector.dart';

class PhoneBookingDialog extends StatefulWidget {
  const PhoneBookingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PhoneBookingDialog(),
    );
  }

  @override
  State<PhoneBookingDialog> createState() => _PhoneBookingDialogState();
}

class _PhoneBookingDialogState extends State<PhoneBookingDialog> {
  final _formKey = GlobalKey<FormState>();

  final _callerNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _plateController = TextEditingController();
  final _arrivalSlotController = TextEditingController(text: 'Today within 30 mins');
  final _addressController = TextEditingController();

  CarType _carType = CarType.automobile;
  ServiceType _serviceType = ServiceType.walkInStation;
  WashPackage? _selectedPackage;
  String _selectedBishoftuArea = AppConstants.bishoftuAreas.first;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _callerNameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _arrivalSlotController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;
    if (_selectedPackage == null && packages.isNotEmpty) {
      _selectedPackage = packages.first;
    }

    final price = _selectedPackage?.getPriceFor(_carType) ?? 0.0;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr('registerPhoneBooking'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Intake for calling customers (Drive-in / At-Home)',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Form Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Caller Name & Phone
                      CustomTextField(
                        controller: _callerNameController,
                        label: state.tr('phoneBookingCallerName'),
                        hint: 'e.g. Almaz Bekele',
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter caller name' : null,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _phoneController,
                        label: state.tr('customerPhone'),
                        hint: '+251 91 234 5678',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android,
                        validator: (v) => v == null || v.length < 9 ? 'Please enter valid phone' : null,
                      ),
                      const SizedBox(height: 12),

                      // 2. License Plate
                      CustomTextField(
                        controller: _plateController,
                        label: state.tr('licensePlate'),
                        hint: 'e.g. 3-A12345 ET',
                        prefixIcon: Icons.tag,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter license plate' : null,
                      ),
                      const SizedBox(height: 14),

                      // 3. Service Mode (Station Bay vs Mobile Van)
                      const Text(
                        'Service Mode',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Drive-in Station (Bays)'),
                              selected: _serviceType == ServiceType.walkInStation,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _serviceType == ServiceType.walkInStation ? Colors.white : AppColors.textPrimary,
                              ),
                              onSelected: (_) => setState(() => _serviceType = ServiceType.walkInStation),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('At-Home Mobile Van'),
                              selected: _serviceType == ServiceType.atHomeMobile,
                              selectedColor: AppColors.mobileVanColor,
                              labelStyle: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: _serviceType == ServiceType.atHomeMobile ? Colors.white : AppColors.textPrimary,
                              ),
                              onSelected: (_) => setState(() => _serviceType = ServiceType.atHomeMobile),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Address if Mobile Van
                      if (_serviceType == ServiceType.atHomeMobile) ...[
                        DropdownButtonFormField<String>(
                          value: _selectedBishoftuArea,
                          decoration: InputDecoration(
                            labelText: state.tr('locationArea'),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          items: AppConstants.bishoftuAreas.map((area) {
                            return DropdownMenuItem(value: area, child: Text(area, style: const TextStyle(fontSize: 12)));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedBishoftuArea = val);
                          },
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _addressController,
                          label: 'House / Landmark',
                          hint: 'e.g. Near Babogaya Resort',
                          prefixIcon: Icons.home,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 4. Car Type Selector
                      CarTypeSelector(
                        selectedType: _carType,
                        onSelected: (t) => setState(() => _carType = t),
                      ),
                      const SizedBox(height: 14),

                      // 5. Package Selection Dropdown
                      const Text(
                        'Selected Wash Package',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedPackage?.id,
                            items: packages.map((pkg) {
                              final pkgPrice = pkg.getPriceFor(_carType);
                              return DropdownMenuItem(
                                value: pkg.id,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        pkg.localizedName(state.currentLang),
                                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.format(pkgPrice),
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (id) {
                              if (id != null) {
                                setState(() {
                                  _selectedPackage = packages.firstWhere((p) => p.id == id);
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 6. Arrival Slot
                      CustomTextField(
                        controller: _arrivalSlotController,
                        label: state.tr('phoneBookingArrival'),
                        hint: 'e.g. Today 3:00 PM',
                        prefixIcon: Icons.schedule,
                      ),
                      const SizedBox(height: 16),

                      // Summary Price Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${state.tr("total")}:',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                            ),
                            Text(
                              CurrencyFormatter.format(price),
                              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Action
              CustomButton(
                text: 'Confirm Phone Reservation 📞',
                isLoading: _isSubmitting,
                onPressed: () => _submitPhoneBooking(context, state),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitPhoneBooking(BuildContext context, dynamic state) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPackage == null) return;

    setState(() => _isSubmitting = true);

    try {
      String? deliveryLoc;
      if (_serviceType == ServiceType.atHomeMobile) {
        deliveryLoc = '$_selectedBishoftuArea - ${_addressController.text.trim()}';
      }

      await state.bookNewWash(
        customerName: '${_callerNameController.text.trim()} [Phone 📞]',
        customerPhone: _phoneController.text.trim(),
        serviceType: _serviceType,
        carType: _carType,
        licensePlate: _plateController.text.trim(),
        package: _selectedPackage!,
        deliveryLocation: deliveryLoc,
        paymentMethod: PaymentMethod.cash,
        gpsCoordinates: null,
      );

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('Phone booking recorded for ${_plateController.text.trim()}!'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to record phone booking: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
