import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../admin/domain/models/staff_member.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/car_type_selector.dart';

class WalkInRegistrationScreen extends StatefulWidget {
  final BayType? preselectedBay;

  const WalkInRegistrationScreen({
    super.key,
    this.preselectedBay,
  });

  @override
  State<WalkInRegistrationScreen> createState() => _WalkInRegistrationScreenState();
}

class _WalkInRegistrationScreenState extends State<WalkInRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _plateController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _refCodeController = TextEditingController();

  CarType _carType = CarType.automobile;
  late BayType _bayType;
  WashPackage? _package;

  bool _isPaidNow = false;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _bayType = widget.preselectedBay ?? BayType.bay1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _phoneController.dispose();
    _refCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;

    if (_package == null && packages.isNotEmpty) {
      _package = packages.first;
    }

    final price = _package?.getPriceFor(_carType) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.tr('walkInTitle')),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gate Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.door_sliding_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('appName'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                          ),
                          Text(
                            state.tr('tagline'),
                            style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 1. Customer Name, License Plate & Phone
              Text(
                state.tr('customerRole'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _nameController,
                label: state.tr('fullName'),
                hint: 'e.g. Abebe Kebede',
                prefixIcon: Icons.person_outline_rounded,
                validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterName') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _plateController,
                label: state.tr('licensePlate'),
                hint: 'e.g. ET-3-B98124 or 3-B98124',
                prefixIcon: Icons.badge_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterPlate') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: state.tr('customerPhone'),
                hint: '+251 91 123 4567',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (val) => val == null || val.length < 9 ? state.tr('enterValidPhone') : null,
              ),
              const SizedBox(height: 18),

              // 2. Select Car Type
              CarTypeSelector(
                selectedType: _carType,
                onSelected: (type) => setState(() => _carType = type),
              ),
              const SizedBox(height: 18),

              // 3. Package Selection
              Text(
                state.tr('servicePackages'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              ...packages.map((pkg) {
                final isSelected = pkg.id == _package?.id;
                final pkgPrice = pkg.getPriceFor(_carType);
                return GestureDetector(
                  onTap: () => setState(() => _package = pkg),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Radio<String>(
                          value: pkg.id,
                          groupValue: _package?.id,
                          activeColor: AppColors.primary,
                          onChanged: (_) => setState(() => _package = pkg),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg.localizedName(state.currentLang),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${pkg.durationMinutes} mins • ${pkg.localizedDescription(state.currentLang)}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                              if (isSelected && pkg.features.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                ...pkg.localizedFeatures(state.currentLang).map((f) => Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 12, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          f,
                                          style: const TextStyle(fontSize: 10.5, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyFormatter.format(pkgPrice),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 18),

              // 4. Station Bay / Van Assignment
              Text(
                state.tr('assignVehicle'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Row(
                children: BayType.values.map((bay) {
                  final isSelected = bay == _bayType;
                  final bayData = state.bays.firstWhere(
                    (b) => b.type == bay,
                    orElse: () => StationBay(type: bay),
                  );

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _bayType = bay),
                      child: Container(
                        margin: EdgeInsets.only(right: bay != BayType.values.last ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? bay.color.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? bay.color : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(bay.icon, color: bay.color, size: 22),
                            const SizedBox(height: 4),
                            Text(
                              bay.shortName,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                color: isSelected ? bay.color : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              bayData.isVacant ? state.tr('availableNow') : state.tr('busyWashing'),
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: bayData.isVacant ? AppColors.statusReady : AppColors.statusPending,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Submit Action
              CustomButton(
                text: 'Book Now 🚗 • ${CurrencyFormatter.format(price)}',
                icon: Icons.bookmark_added_rounded,
                isLoading: _isSubmitting,
                onPressed: () => _handleSubmitWalkIn(context),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitWalkIn(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    if (_package == null) return;

    setState(() => _isSubmitting = true);

    try {
      final state = AppStateProvider.read(context);

      final booking = await state.registerWalkIn(
        customerName: _nameController.text.trim(),
        licensePlate: _plateController.text.trim().toUpperCase(),
        customerPhone: _phoneController.text.trim(),
        carType: _carType,
        package: _package!,
        assignedBay: _bayType,
        paymentMethod: PaymentMethod.cash,
        markPaid: false,
        transactionRef: null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('Gate entry ${booking.licensePlate} stationed at ${_bayType.displayName}!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
