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

  final _plateController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _refCodeController = TextEditingController();

  CarType _carType = CarType.automobile;
  late BayType _bayType;
  WashPackage? _package;
  StaffMember? _washer;

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
    _plateController.dispose();
    _phoneController.dispose();
    _refCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;
    final washers = state.availableWashers;

    if (_package == null && packages.isNotEmpty) {
      _package = packages.first;
    }
    if (_washer == null && washers.isNotEmpty) {
      _washer = washers.first;
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

              // 1. License Plate & Phone
              Text(
                state.tr('customerRole'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 10),
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
                                '${pkg.durationMinutes} mins',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
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

              // 5. Assign Washer
              Text(
                state.tr('activeWashers'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
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
                    value: _washer,
                    items: washers.map((w) {
                      return DropdownMenuItem<StaffMember>(
                        value: w,
                        child: Text('${w.name} (${w.role.localizedName(state.currentLang)})', style: const TextStyle(fontSize: 13.5)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _washer = val);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 6. Upfront Payment Option
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.tr('confirmAndPay'),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                        ),
                        Switch(
                          value: _isPaidNow,
                          activeColor: AppColors.cashGreen,
                          onChanged: (val) => setState(() => _isPaidNow = val),
                        ),
                      ],
                    ),
                    if (_isPaidNow) ...[
                      const Divider(height: 16),
                      Row(
                        children: [
                          PaymentMethod.cash,
                          PaymentMethod.telebirr,
                          PaymentMethod.cbeBirr,
                        ].map((m) {
                          final isSel = m == _paymentMethod;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _paymentMethod = m),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSel ? m.color : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: m.color),
                                ),
                                child: Center(
                                  child: Text(
                                    m.shortName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isSel ? Colors.white : m.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      if (_paymentMethod.isDigital) ...[
                        const SizedBox(height: 10),
                        CustomTextField(
                          controller: _refCodeController,
                          label: state.tr('transactionRef'),
                          hint: 'e.g. TB-9988221',
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              CustomButton(
                text: '${state.tr("startWashing")} (${CurrencyFormatter.format(price)})',
                icon: Icons.check_circle_outline,
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
        licensePlate: _plateController.text.trim().toUpperCase(),
        customerPhone: _phoneController.text.trim(),
        carType: _carType,
        package: _package!,
        assignedBay: _bayType,
        assignedWasherId: _washer?.id,
        assignedWasherName: _washer?.name,
        paymentMethod: _paymentMethod,
        markPaid: _isPaidNow,
        transactionRef: _isPaidNow && _paymentMethod.isDigital ? _refCodeController.text.trim() : null,
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
