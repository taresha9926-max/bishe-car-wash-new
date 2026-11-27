import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
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

/// Single-screen customer booking flow mirroring staff intake:
/// - Top row: "How should we serve you?" (3 compact cards in a row + expanding Location/GPS)
/// - Middle: Vehicle size row + expandable Custom Detailing / Preset Packages (or Carpet Type row + expandable Dimensions)
/// - Bottom: Inline Name, Phone (Optional), Plate/Tag + Summary -> Book Now -> LiveTrackingScreen
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

  late ServiceType _selectedServiceType;
  late CarType _selectedCarType;

  final Set<String> _selectedServiceIds = {};
  bool _useCustomChecklist = true;
  WashPackage? _selectedPackage;
  bool _isCustomExpanded = false;
  bool _isPresetExpanded = false;
  bool _isCarpetDimensionsExpanded = false;

  late bool _isCarpet;
  String _carpetType = 'type_a';
  final _lengthController = TextEditingController(text: '3.0');
  final _widthController = TextEditingController(text: '2.0');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _plateController = TextEditingController();
  final _addressController = TextEditingController();
  final _gpsController = TextEditingController();
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
    final grandTotal = currentPrice;

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
                  _buildMergedSingleScreenContent(context, state, effectivePackage, currentPrice, grandTotal),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMergedSingleScreenContent(
    BuildContext context,
    dynamic state,
    WashPackage? effectivePackage,
    double currentPrice,
    double grandTotal,
  ) {
    final customTotal = _calculateCustomTotal(state);
    final presetTotal = effectivePackage?.getPriceFor(_selectedCarType) ?? 0.0;
    final deliveryFee = state.getDeliveryAddonFee(_selectedServiceType, isCarpet: _isCarpet) as double;
    final serviceSummary = _isCarpet
        ? '${state.tr("carpetService")}: ${_carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
        : (_useCustomChecklist
            ? '${_selectedServiceIds.length} ${state.tr("customWashServices")}'
            : (effectivePackage?.localizedName(state.currentLang) ?? ''));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Row: "How should we serve you?" (3 compact cards side-by-side in a Row + expanding GPS/Address)
        Text(
          state.tr('howShouldWeServeYou'),
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        _buildServiceModeRow(state),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: _selectedServiceType.requiresLocation
              ? Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ServiceLocationPickerCard(
                    state: state,
                    serviceType: _selectedServiceType,
                    isCarpet: _isCarpet,
                    selectedArea: _selectedBishoftuArea,
                    onAreaChanged: (val) => setState(() => _selectedBishoftuArea = val),
                    addressController: _addressController,
                    gpsController: _gpsController,
                  ),
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 18),

        // 2. Vehicle Size Row & Expandable Custom Detailing / Preset Packages (or Carpet Type Row & Expandable Dimensions)
        if (!_isCarpet) ...[
          Text(
            state.tr('pickVehicleAndWashTitle'),
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          CarTypeSelector(
            selectedType: _selectedCarType,
            onSelected: (type) => setState(() => _selectedCarType = type),
          ),
          const SizedBox(height: 14),
          _buildExpandableWashSection(
            icon: Icons.checklist_rounded,
            title: state.tr('customDetailingTab'),
            summary: '${_selectedServiceIds.length} • ${CurrencyFormatter.format(customTotal)}',
            isActiveMode: _useCustomChecklist,
            isExpanded: _isCustomExpanded,
            onToggle: () {
              setState(() {
                _useCustomChecklist = true;
                _isCustomExpanded = !_isCustomExpanded;
                if (_isCustomExpanded) _isPresetExpanded = false;
              });
            },
            children: state.activeServiceItems
                .map<Widget>((item) => _buildCustomServiceCheckbox(state, item))
                .toList(),
          ),
          const SizedBox(height: 10),
          _buildExpandableWashSection(
            icon: Icons.inventory_2_outlined,
            title: state.tr('presetPackagesTab'),
            summary: '${effectivePackage?.localizedName(state.currentLang) ?? ''} • ${CurrencyFormatter.format(presetTotal)}',
            isActiveMode: !_useCustomChecklist,
            isExpanded: _isPresetExpanded,
            onToggle: () {
              setState(() {
                _useCustomChecklist = false;
                _selectedPackage ??= state.packages.isNotEmpty ? state.packages.first : null;
                _isPresetExpanded = !_isPresetExpanded;
                if (_isPresetExpanded) _isCustomExpanded = false;
              });
            },
            children: state.packages
                .map<Widget>((pkg) => _buildPresetPackageCard(state, pkg, effectivePackage))
                .toList(),
          ),
        ] else ...[
          Text(
            state.tr('pickCarpetTypeAndSizeTitle'),
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          _buildCarpetTypeSelector(state),
          const SizedBox(height: 12),
          _buildExpandableWashSection(
            icon: Icons.straighten_rounded,
            title: state.tr('carpetDimensionsTitle'),
            summary: '${_lengthController.text.trim()}m × ${_widthController.text.trim()}m (${_carpetArea.toStringAsFixed(1)} m²)',
            isActiveMode: true,
            isExpanded: _isCarpetDimensionsExpanded,
            onToggle: () => setState(() => _isCarpetDimensionsExpanded = !_isCarpetDimensionsExpanded),
            children: [_buildCarpetDimensionsCard(state, currentPrice)],
          ),
        ],
        const SizedBox(height: 16),

        // 3. Merged Customer Details Card (Name/Car Type, Phone Optional, Plate/Tag)
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nameController,
                label: state.tr('fullNameOrCarType'),
                hint: 'e.g. Girma Tadesse / Toyota Vitz',
                prefixIcon: Icons.person_outline,
                validator: (val) => val == null || val.trim().isEmpty ? state.tr('enterNameOrCarType') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                label: '${state.tr('customerPhone')} (${state.tr('optional')})',
                hint: '+251 91 234 5678',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (val) {
                  if (val == null || val.trim().isEmpty || val.trim() == '+251 9' || val.trim() == '+251') {
                    return null;
                  }
                  return val.length < 9 ? state.tr('enterValidPhone') : null;
                },
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

        // 4. Order Summary Card + Book Now CTA (mirrors Cashier minus Assign Bay, Negotiated Price edit & Tip)
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
              if (deliveryFee > 0) ...[
                const SizedBox(height: 4),
                Text(
                  '${state.tr("deliveryAddonIncluded")}: +${CurrencyFormatter.format(deliveryFee)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.liquidCyanNeon),
                ),
              ],
              const SizedBox(height: 10),
              const NegotiablePriceBadge(onDark: true),
              const Divider(color: Colors.white24, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${state.tr("total")}:',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
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
        const SizedBox(height: 16),

        CustomButton(
          text: '${_isCarpet ? state.tr('bookCarpetCleaning') : state.tr('bookNow')} • ${CurrencyFormatter.format(grandTotal)}',
          icon: Icons.bookmark_added_rounded,
          isLoading: _isSubmitting,
          onPressed: _handleBookingSubmit,
        ),
      ],
    );
  }

  Widget _buildServiceModeRow(dynamic state) {
    final modes = [
      (
        ServiceType.walkInStation,
        _isCarpet ? state.tr('carpetStationService') : state.tr('driveInStation'),
        Icons.storefront_rounded,
        _isCarpet ? const Color(0xFF4F46E5) : AppColors.bay1Color,
      ),
      (
        ServiceType.valetPickUp,
        _isCarpet ? state.tr('carpetValetTitle') : state.tr('serviceValetPickUp'),
        Icons.directions_car_rounded,
        const Color(0xFF7C3AED),
      ),
      (
        ServiceType.atHomeMobile,
        _isCarpet ? state.tr('carpetHomeTitle') : state.tr('atHomeMobile'),
        Icons.home_repair_service_rounded,
        _isCarpet ? const Color(0xFF0D9488) : AppColors.mobileVanColor,
      ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: modes.map((entry) {
        final mode = entry.$1;
        final label = entry.$2 as String;
        final icon = entry.$3;
        final color = entry.$4;
        final isSelected = _selectedServiceType == mode;
        final addon = state.getDeliveryAddonFee(mode, isCarpet: _isCarpet) as double;

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedServiceType = mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: mode != ServiceType.atHomeMobile ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? color.withValues(alpha: 0.20) : const Color(0xFF111827),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? color : AppColors.cardBorder,
                  width: isSelected ? 2 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.28),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: isSelected ? color : AppColors.textSecondary),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? color : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    addon > 0 ? '+${addon.toStringAsFixed(0)} ETB' : state.tr('availableNow'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: addon > 0 ? color : AppColors.statusReady,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpandableWashSection({
    required IconData icon,
    required String title,
    required String summary,
    required bool isActiveMode,
    required bool isExpanded,
    required VoidCallback onToggle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isActiveMode ? AppColors.primary.withOpacity(0.12) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActiveMode ? AppColors.liquidCyanNeon : AppColors.cardBorder,
          width: isActiveMode ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isActiveMode ? AppColors.liquidCyanNeon : AppColors.primary).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18, color: isActiveMode ? AppColors.liquidCyanNeon : AppColors.textSecondary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: isActiveMode ? AppColors.liquidCyanNeon : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isActiveMode ? AppColors.liquidCyanNeon : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(color: Color(0xFF1E293B), height: 12),
                        ...children,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomServiceCheckbox(dynamic state, CarWashServiceItem item) {
    final isChecked = _selectedServiceIds.contains(item.id);
    final itemPrice = item.getPriceFor(_selectedCarType);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isChecked ? AppColors.primary.withOpacity(0.18) : const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isChecked ? AppColors.liquidCyanNeon : AppColors.cardBorder,
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
                    color: isChecked ? AppColors.liquidCyanNeon : Colors.white,
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
          color: isSelected ? AppColors.primary.withOpacity(0.18) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.liquidCyanNeon : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Radio<String>(
              value: pkg.id,
              groupValue: activePkg?.id,
              activeColor: AppColors.liquidCyanNeon,
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
                      color: isSelected ? AppColors.liquidCyanNeon : Colors.white,
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
            color: selected ? accent.withOpacity(0.20) : const Color(0xFF111827),
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
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: selected ? accent : Colors.white),
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
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
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
                Expanded(
                  child: Text(
                    '${state.tr("carpetTotalArea")}: ${_carpetArea.toStringAsFixed(1)} m²',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                  ),
                ),
                const SizedBox(width: 8),
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

  Future<void> _handleBookingSubmit() async {
    final state = AppStateProvider.read(context);
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
    if (!_isCarpet && _useCustomChecklist && _selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          content: Text(state.tr('selectAtLeastOneService')),
        ),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

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

      final phoneText = _phoneController.text.trim();
      final cleanPhone = (phoneText.isEmpty || phoneText == '+251 9' || phoneText == '+251') ? '' : phoneText;

      final booking = await state.bookNewWash(
        customerName: _nameController.text.trim(),
        customerPhone: cleanPhone,
        serviceType: _selectedServiceType,
        carType: _isCarpet ? CarType.automobile : _selectedCarType,
        licensePlate: _plateController.text.trim().toUpperCase(),
        package: activePackage ??
            (state.packages.isNotEmpty
                ? state.packages.first
                : const WashPackage(
                    id: 'pkg-standard',
                    name: 'Standard Wash',
                    description: 'Standard exterior body wash',
                    durationMinutes: 30,
                    pricingByCarType: {
                      CarType.automobile: 350.0,
                      CarType.minibus: 450.0,
                      CarType.truck: 650.0,
                    },
                    features: ['Foam wash', 'Rinse', 'Tire shine'],
                  )),
        deliveryLocation: fullAddress,
        paymentMethod: PaymentMethod.cash,
        gpsCoordinates: gpsCoords,
        isCarpet: _isCarpet,
        carpetType: _isCarpet ? _carpetType : null,
        carpetAreaSqMeters: _isCarpet ? _carpetArea : null,
        carpetDimensions: _isCarpet ? '${_lengthController.text.trim()}m x ${_widthController.text.trim()}m' : null,
        customTotalPrice: totalPrice,
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
        final errStr = e.toString().toLowerCase();
        final isNetworkErr = errStr.contains('socket') ||
            errStr.contains('clientexception') ||
            errStr.contains('network') ||
            errStr.contains('failed host lookup') ||
            errStr.contains('connection');

        if (isNetworkErr) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, color: Colors.amber, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.tr('offlineNotice'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.tr('offlineOrderHelp'),
                    style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.tr('callStationDirect'),
                    style: const TextStyle(fontSize: 12, color: AppColors.liquidCyanNeon, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(state.tr('close'), style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    UrlLauncherHelper.openUrl('tel:0910046553');
                  },
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(state.tr('callStationNow')),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.redAccent, content: Text('${state.tr("bookingFailedPrefix")}: $e')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
