import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/core/widgets/custom_button.dart';
import 'package:bishe_car_wash/core/widgets/custom_text_field.dart';
import 'package:bishe_car_wash/core/widgets/language_switcher_action.dart';
import 'package:bishe_car_wash/core/widgets/service_location_picker_card.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_wash_service_item.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/car_type_selector.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/negotiable_price_badge.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/station_type_card.dart';

/// Guided 3-step customer booking wizard:
/// Step 1: Pick service delivery mode (+ location if Pick-up / Mobile Van)
/// Step 2: Pick vehicle/carpet & services (with standard ETB prices + "Prices are negotiable")
/// Step 3: Enter Name, Phone & Plate/Tag -> Confirm
class NewBookingScreen extends StatefulWidget {
  final ServiceType? initialServiceType;
  final CarType? initialCarType;
  final WashPackage? initialPackage;
  final bool isCarpet;
  final String? initialCarpetType;
  final List<String>? initialSelectedServices;
  final bool? initialUseCustomChecklist;
  final double? initialCustomPrice;

  const NewBookingScreen({
    super.key,
    this.initialServiceType,
    this.initialCarType,
    this.initialPackage,
    this.isCarpet = false,
    this.initialCarpetType,
    this.initialSelectedServices,
    this.initialUseCustomChecklist,
    this.initialCustomPrice,
  });

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  int _currentStep = 1;
  late ServiceType _selectedServiceType;
  late CarType _selectedCarType;

  final Set<String> _selectedServiceIds = {};
  bool _useCustomChecklist = true;
  WashPackage? _selectedPackage;

  late bool _isCarpet;
  String _carpetType = 'type_a';
  final _lengthController = TextEditingController(text: '3.0');
  final _widthController = TextEditingController(text: '2.0');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _plateController = TextEditingController();
  final _addressController = TextEditingController();
  final _gpsController = TextEditingController();
  final _tipController = TextEditingController();
  double _tipAmount = 0.0;
  String _selectedBishoftuArea = AppConstants.bishoftuAreas.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isCarpet = widget.isCarpet;
    if (widget.initialCarpetType != null) {
      _carpetType = widget.initialCarpetType!;
    }
    _selectedServiceType = widget.initialServiceType ?? ServiceType.walkInStation;
    _selectedCarType = widget.initialCarType ?? CarType.automobile;
    _useCustomChecklist = widget.initialUseCustomChecklist ?? (widget.initialPackage == null);
    _selectedPackage = widget.initialPackage;

    if (widget.initialSelectedServices != null && widget.initialSelectedServices!.isNotEmpty) {
      _selectedServiceIds.addAll(widget.initialSelectedServices!);
    } else {
      _selectedServiceIds.addAll({'srv_body_wash', 'srv_tire_clean'});
    }

    if (_isCarpet) {
      _plateController.text = 'CPT-${DateTime.now().millisecondsSinceEpoch % 10000}';
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _addressController.dispose();
    _gpsController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _tipController.dispose();
    super.dispose();
  }

  double get _carpetArea {
    final l = double.tryParse(_lengthController.text.trim()) ?? 0.0;
    final w = double.tryParse(_widthController.text.trim()) ?? 0.0;
    return l * w;
  }

  double _calculateCustomTotal(dynamic state) {
    double total = 0.0;
    final items = state.activeServiceItems as List<CarWashServiceItem>;
    for (final item in items) {
      if (_selectedServiceIds.contains(item.id)) {
        total += item.getPriceFor(_selectedCarType);
      }
    }
    return total;
  }

  void _setStep(int step) {
    setState(() => _currentStep = step);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    }
  }

  void _advanceFromStep1(dynamic state) {
    if (_selectedServiceType.requiresLocation &&
        _addressController.text.trim().isEmpty &&
        _gpsController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          content: Text(state.tr('deliveryModeRequiredAddress')),
        ),
      );
      return;
    }
    _setStep(2);
  }

  void _advanceFromStep2(dynamic state) {
    if (!_isCarpet && _useCustomChecklist && _selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          content: Text(state.tr('selectAtLeastOneService')),
        ),
      );
      return;
    }
    _setStep(3);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final effectivePackage = _selectedPackage ?? (state.packages.isNotEmpty ? state.packages.first : null);
    final deliveryAddonFee = state.getDeliveryAddonFee(_selectedServiceType, isCarpet: _isCarpet) as double;
    final carpetPrice = (_carpetArea * state.getCarpetPricePerSqM(_carpetType, _selectedServiceType)) + deliveryAddonFee;
    final carPrice = (_useCustomChecklist
        ? _calculateCustomTotal(state)
        : (effectivePackage?.getPriceFor(_selectedCarType) ?? 0.0)) + deliveryAddonFee;
    final currentPrice = widget.initialCustomPrice ?? (_isCarpet ? carpetPrice : carPrice);
    final grandTotal = currentPrice + _tipAmount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isCarpet ? state.tr('washMyCarpetTitle') : state.tr('washMyCarTitle')),
        actions: const [
          LanguageSwitcherAction(isDark: false),
        ],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStepProgressHeader(state),
                  const SizedBox(height: 16),

                  if (_currentStep == 1) _buildStep1ServiceMode(context, state),
                  if (_currentStep == 2) _buildStep2ServiceSelection(context, state, effectivePackage, currentPrice),
                  if (_currentStep == 3) _buildStep3CustomerAndSummary(context, state, effectivePackage, currentPrice, grandTotal),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepProgressHeader(dynamic state) {
    String title;
    if (_currentStep == 1) {
      title = state.tr('step1ModeInstruction');
    } else if (_currentStep == 2) {
      title = state.tr(_isCarpet ? 'step2CarpetInstruction' : 'step2CarInstruction');
    } else {
      title = state.tr(_isCarpet ? 'step3CarpetDetailsInstruction' : 'step3DetailsInstruction');
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [1, 2, 3].map((step) {
              final isDone = step < _currentStep;
              final isCurrent = step == _currentStep;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: step < 3 ? 6 : 0),
                  decoration: BoxDecoration(
                    color: (isDone || isCurrent) ? AppColors.primary : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2ServiceSelection(
    BuildContext context,
    dynamic state,
    WashPackage? effectivePackage,
    double currentPrice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!_isCarpet) ...[
          CarTypeSelector(
            selectedType: _selectedCarType,
            onSelected: (type) => setState(() => _selectedCarType = type),
          ),
          const SizedBox(height: 16),

          // Dual Tab Bar - Custom Detailing vs Preset Service Packages
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildServiceModeTabButton(
                  icon: Icons.checklist_rounded,
                  label: state.tr('customDetailingTab'),
                  selected: _useCustomChecklist,
                  onTap: () => setState(() => _useCustomChecklist = true),
                ),
                const SizedBox(width: 4),
                _buildServiceModeTabButton(
                  icon: Icons.inventory_2_outlined,
                  label: state.tr('presetPackagesTab'),
                  selected: !_useCustomChecklist,
                  onTap: () {
                    setState(() {
                      _useCustomChecklist = false;
                      _selectedPackage ??= state.packages.isNotEmpty ? state.packages.first : null;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (_useCustomChecklist)
            ...state.activeServiceItems.map((item) => _buildCustomServiceCheckbox(state, item))
          else
            ...state.packages.map((pkg) => _buildPresetPackageCard(state, pkg, effectivePackage)),
        ] else ...[
          _buildCarpetTypeSelector(state),
          const SizedBox(height: 14),
          _buildCarpetDimensionsCard(state, currentPrice),
        ],

        const SizedBox(height: 14),

        // Simple Total Preview + "Prices are negotiable"
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primary.withOpacity(0.35), width: 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('estimatedTotalLabel'),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                  ),
                  Text(
                    CurrencyFormatter.format(currentPrice),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  ),
                ],
              ),
              if ((state.getDeliveryAddonFee(_selectedServiceType, isCarpet: _isCarpet) as double) > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${state.tr("deliveryAddonIncluded")}: +${CurrencyFormatter.format(state.getDeliveryAddonFee(_selectedServiceType, isCarpet: _isCarpet) as double)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
              const SizedBox(height: 8),
              const NegotiablePriceBadge(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _setStep(1),
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: Text(state.tr('backStep'), style: const TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: state.tr('nextStep'),
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _advanceFromStep2(state),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceModeTabButton({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textPrimary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomServiceCheckbox(dynamic state, CarWashServiceItem item) {
    final isChecked = _selectedServiceIds.contains(item.id);
    final itemPrice = item.getPriceFor(_selectedCarType);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isChecked ? AppColors.primary.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? AppColors.primary : AppColors.cardBorder,
          width: isChecked ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: CheckboxListTile(
          value: isChecked,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          activeColor: AppColors.primary,
          title: Row(
            children: [
              Expanded(
                child: Text(
                  item.localizedName(state.currentLang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isChecked ? FontWeight.w800 : FontWeight.w600,
                    color: isChecked ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  CurrencyFormatter.format(itemPrice),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                ),
              ),
            ],
          ),
          subtitle: item.description != null && item.description!.isNotEmpty
              ? Text(item.description!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted))
              : null,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                _selectedServiceIds.add(item.id);
              } else {
                _selectedServiceIds.remove(item.id);
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildPresetPackageCard(dynamic state, WashPackage pkg, WashPackage? activePkg) {
    final isSelected = pkg.id == activePkg?.id;
    final pkgPrice = pkg.getPriceFor(_selectedCarType);
    return GestureDetector(
      onTap: () => setState(() => _selectedPackage = pkg),
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
              groupValue: activePkg?.id,
              activeColor: AppColors.primary,
              onChanged: (_) => setState(() => _selectedPackage = pkg),
            ),
            AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.getPackageImage(pkg),
              width: 48,
              height: 48,
              borderRadius: 8,
              durationBadge: '${pkg.durationMinutes}m',
            ),
            const SizedBox(width: 8),
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
                    '${pkg.durationMinutes}m • ${pkg.localizedDescription(state.currentLang)}',
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
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarpetTypeSelector(dynamic state) {
    return Row(
      children: [
        _buildCarpetTypeOption(
          state: state,
          typeKey: 'type_a',
          title: state.tr('carpetTypeA'),
          desc: state.tr('carpetTypeADesc'),
          imageUrl: AutoCareAssets.carpetTypeAUrl,
          accent: const Color(0xFF6366F1),
        ),
        const SizedBox(width: 10),
        _buildCarpetTypeOption(
          state: state,
          typeKey: 'type_b',
          title: state.tr('carpetTypeB'),
          desc: state.tr('carpetTypeBDesc'),
          imageUrl: AutoCareAssets.carpetTypeBUrl,
          accent: const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _buildCarpetTypeOption({
    required dynamic state,
    required String typeKey,
    required String title,
    required String desc,
    required String imageUrl,
    required Color accent,
  }) {
    final selected = _carpetType == typeKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _carpetType = typeKey),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? accent.withOpacity(0.08) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? accent : AppColors.cardBorder, width: selected ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AutoCareAssets.buildPhotoThumbnail(
                    imageUrl: imageUrl,
                    width: 38,
                    height: 38,
                    borderRadius: 8,
                    fallbackIcon: Icons.texture_rounded,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? accent : AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${state.getCarpetPricePerSqM(typeKey, _selectedServiceType).toStringAsFixed(0)} ETB / m²',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: accent),
              ),
              Text(desc, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarpetDimensionsCard(dynamic state, double carpetPrice) {
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
          Text(
            state.tr('carpetDimensionsTitle'),
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _lengthController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${state.tr("carpetLength")} (m)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('×', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: TextField(
                  controller: _widthController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: '${state.tr("carpetWidth")} (m)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.tr("carpetTotalArea")}: ${_carpetArea.toStringAsFixed(1)} m²',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                ),
                Text(
                  CurrencyFormatter.format(carpetPrice),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF312E81)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1ServiceMode(BuildContext context, dynamic state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StationTypeCard(
          serviceType: ServiceType.walkInStation,
          isCarpet: _isCarpet,
          isSelected: _selectedServiceType == ServiceType.walkInStation,
          availableCapacity: state.availableBaysCount,
          onTap: () => setState(() => _selectedServiceType = ServiceType.walkInStation),
        ),
        const SizedBox(height: 10),
        StationTypeCard(
          serviceType: ServiceType.valetPickUp,
          isCarpet: _isCarpet,
          isSelected: _selectedServiceType == ServiceType.valetPickUp,
          availableCapacity: 1,
          onTap: () => setState(() => _selectedServiceType = ServiceType.valetPickUp),
        ),
        const SizedBox(height: 10),
        StationTypeCard(
          serviceType: ServiceType.atHomeMobile,
          isCarpet: _isCarpet,
          isSelected: _selectedServiceType == ServiceType.atHomeMobile,
          availableCapacity: state.isMobileVanAvailable ? 1 : 0,
          onTap: () => setState(() => _selectedServiceType = ServiceType.atHomeMobile),
        ),

        if (_selectedServiceType.requiresLocation) ...[
          const SizedBox(height: 16),
          ServiceLocationPickerCard(
            state: state,
            serviceType: _selectedServiceType,
            isCarpet: _isCarpet,
            selectedArea: _selectedBishoftuArea,
            onAreaChanged: (val) => setState(() => _selectedBishoftuArea = val),
            addressController: _addressController,
            gpsController: _gpsController,
          ),
        ],
        const SizedBox(height: 20),

        CustomButton(
          text: state.tr('nextStep'),
          icon: Icons.arrow_forward_rounded,
          onPressed: () => _advanceFromStep1(state),
        ),
      ],
    );
  }

  Widget _buildStep3CustomerAndSummary(
    BuildContext context,
    dynamic state,
    WashPackage? effectivePackage,
    double currentPrice,
    double grandTotal,
  ) {
    final serviceSummary = _isCarpet
        ? '${state.tr("carpetService")}: ${_carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
        : (_useCustomChecklist
            ? '${_selectedServiceIds.length} ${state.tr("customWashServices")}'
            : (effectivePackage?.localizedName(state.currentLang) ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                label: state.tr('customerName'),
                hint: 'e.g. Girma Tadesse',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterName') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: state.tr('customerPhone'),
                hint: '+251 91 234 5678',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (val) => val == null || val.length < 9 ? state.tr('enterValidPhone') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _plateController,
                label: _isCarpet ? state.tr('carpetTrackingTag') : state.tr('licensePlate'),
                hint: _isCarpet ? 'e.g. CPT-8941' : 'e.g. 3-B78945 ET',
                prefixIcon: _isCarpet ? Icons.texture_rounded : Icons.tag,
                validator: (val) => val == null || val.trim().isEmpty
                    ? (_isCarpet ? state.tr('enterCarpetTag') : state.tr('enterPlate'))
                    : null,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Optional Washer Gratuity / Tip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.shade50.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.volunteer_activism_rounded, size: 16, color: Colors.amber.shade900),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      state.tr('washersTip'),
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.amber.shade900),
                    ),
                  ),
                  if (_tipAmount > 0)
                    Text(
                      '+ETB ${_tipAmount.toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.amber.shade900),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final tipVal in [50, 100, 200])
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text('+$tipVal'),
                        selected: _tipAmount == tipVal.toDouble(),
                        onSelected: (selected) {
                          setState(() {
                            _tipAmount = selected ? tipVal.toDouble() : 0.0;
                            _tipController.text = _tipAmount > 0 ? _tipAmount.toStringAsFixed(0) : '';
                          });
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        controller: _tipController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: state.tr('customTip'),
                          hintStyle: const TextStyle(fontSize: 11),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _tipAmount = double.tryParse(val) ?? 0.0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Order Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      serviceSummary,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(currentPrice),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                _isCarpet
                    ? '${_carpetArea.toStringAsFixed(1)} m² (${_lengthController.text.trim()}m × ${_widthController.text.trim()}m) • ${_selectedServiceType.localizedName(state.currentLang, isCarpet: true)}'
                    : '${_selectedCarType.localizedName(state.currentLang)} • ${_selectedServiceType.localizedName(state.currentLang)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 10),
              const NegotiablePriceBadge(onDark: true),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${state.tr("total")}:', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  Text(
                    CurrencyFormatter.format(grandTotal),
                    style: const TextStyle(color: AppColors.oromiaGold, fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.oromiaGold, size: 17),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isCarpet ? state.tr('carpetPaymentAtGateNote') : state.tr('paymentAtGateNote'),
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _isSubmitting ? null : () => _setStep(2),
              icon: const Icon(Icons.arrow_back_rounded, size: 17),
              label: Text(state.tr('backStep'), style: const TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                text: _isCarpet ? state.tr('bookCarpetCleaning') : state.tr('bookNow'),
                isLoading: _isSubmitting,
                onPressed: _handleBookingSubmit,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleBookingSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = AppStateProvider.read(context);

    final activePackage = _selectedPackage ?? (state.packages.isNotEmpty ? state.packages.first : null);
    if (!_isCarpet && !_useCustomChecklist && activePackage == null) return;

    setState(() => _isSubmitting = true);

    try {
      String? fullAddress;
      if (_selectedServiceType.requiresLocation) {
        final street = _addressController.text.trim();
        fullAddress = street.isNotEmpty ? '$_selectedBishoftuArea - $street' : _selectedBishoftuArea;
      }
      final gpsCoords = _selectedServiceType.requiresLocation && _gpsController.text.trim().isNotEmpty
          ? _gpsController.text.trim()
          : null;

      final deliveryAddonFee = state.getDeliveryAddonFee(_selectedServiceType, isCarpet: _isCarpet) as double;
      final carpetPrice = (_carpetArea * state.getCarpetPricePerSqM(_carpetType, _selectedServiceType)) + deliveryAddonFee;
      final carPrice = (_useCustomChecklist
          ? _calculateCustomTotal(state)
          : (activePackage?.getPriceFor(_selectedCarType) ?? 0.0)) + deliveryAddonFee;
      final totalPrice = widget.initialCustomPrice ?? (_isCarpet ? carpetPrice : carPrice);

      List<String>? selectedServiceNames;
      if (!_isCarpet && _useCustomChecklist) {
        selectedServiceNames = state.activeServiceItems
            .where((item) => _selectedServiceIds.contains(item.id))
            .map((item) => item.name)
            .toList();
      }

      final booking = await state.bookNewWash(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        serviceType: _selectedServiceType,
        carType: _isCarpet ? CarType.automobile : _selectedCarType,
        licensePlate: _plateController.text.trim().toUpperCase(),
        package: activePackage ?? state.packages.first,
        deliveryLocation: fullAddress,
        paymentMethod: PaymentMethod.cash,
        gpsCoordinates: gpsCoords,
        isCarpet: _isCarpet,
        carpetType: _isCarpet ? _carpetType : null,
        carpetAreaSqMeters: _isCarpet ? _carpetArea : null,
        carpetDimensions: _isCarpet ? '${_lengthController.text.trim()}m x ${_widthController.text.trim()}m' : null,
        customTotalPrice: totalPrice,
        tipAmount: _tipAmount,
        selectedServices: selectedServiceNames,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('${state.tr("bookingSuccess")} (#${booking.id})'),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: booking.id)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.redAccent, content: Text('${state.tr("bookingFailedPrefix")}: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
