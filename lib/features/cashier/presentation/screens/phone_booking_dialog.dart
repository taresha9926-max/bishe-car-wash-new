import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/car_wash_service_item.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../customer/presentation/widgets/car_type_selector.dart';

class PhoneBookingDialog extends StatefulWidget {
  final bool? initialCarpetMode;

  const PhoneBookingDialog({super.key, this.initialCarpetMode});

  static Future<void> show(BuildContext context, {bool? initialCarpetMode}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => PhoneBookingDialog(initialCarpetMode: initialCarpetMode),
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
  final _lengthController = TextEditingController(text: '3.0');
  final _widthController = TextEditingController(text: '4.0');

  bool _isCarpetMode = false;
  String _carpetType = 'type_a'; // 'type_a' or 'type_b'
  CarType _carType = CarType.automobile;
  ServiceType _serviceType = ServiceType.walkInStation;
  WashPackage? _selectedPackage;

  // Custom Detailing Checklist & Negotiated Pricing
  bool _useCustomChecklist = true;
  final Set<String> _selectedServiceIds = {'srv_body_wash', 'srv_tire_clean'};
  final _negotiatedPriceController = TextEditingController();

  String _selectedBishoftuArea = AppConstants.bishoftuAreas.first;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _isCarpetMode = widget.initialCarpetMode ?? false;
    if (_isCarpetMode) {
      _plateController.text = 'CPT-${(DateTime.now().millisecondsSinceEpoch % 10000)}';
    }
  }

  @override
  void dispose() {
    _callerNameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _arrivalSlotController.dispose();
    _addressController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _negotiatedPriceController.dispose();
    super.dispose();
  }

  double _calculateSuggestedServicesTotal(dynamic state) {
    double total = 0.0;
    for (final item in state.activeServiceItems) {
      if (_selectedServiceIds.contains(item.id)) {
        total += item.getPriceFor(_carType);
      }
    }
    return total;
  }

  double get _carpetArea {
    final l = double.tryParse(_lengthController.text.trim()) ?? 0.0;
    final w = double.tryParse(_widthController.text.trim()) ?? 0.0;
    return l * w;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;
    if (_selectedPackage == null && packages.isNotEmpty) {
      _selectedPackage = packages.first;
    }

    final carpetRate = state.getCarpetPricePerSqM(_carpetType, _serviceType);
    final carpetPrice = _carpetArea * carpetRate;
    final suggestedServicesTotal = _calculateSuggestedServicesTotal(state);
    final enteredNegotiated = double.tryParse(_negotiatedPriceController.text.trim());
    final washPrice = _useCustomChecklist
        ? (enteredNegotiated ?? suggestedServicesTotal)
        : (_selectedPackage?.getPriceFor(_carType) ?? 0.0);
    final price = _isCarpetMode ? carpetPrice : washPrice;

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
                      color: (_isCarpetMode ? const Color(0xFF7C3AED) : AppColors.primary).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.phone_in_talk_rounded,
                      color: _isCarpetMode ? const Color(0xFF7C3AED) : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCarpetMode
                              ? '${state.tr("registerPhoneBooking")} • ${state.tr("carpetCleaningOptions")}'
                              : state.tr('registerPhoneBooking'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          _isCarpetMode
                              ? 'Phone intake for carpet cleaning (Station / Valet / Home)'
                              : 'Phone intake for vehicle wash (Drive-in / Mobile Van)',
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

              // Service Selector Toggle: Vehicle vs Carpet
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (_isCarpetMode) {
                            setState(() {
                              _isCarpetMode = false;
                              if (_plateController.text.startsWith('CPT-')) {
                                _plateController.clear();
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isCarpetMode ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_rounded, size: 16, color: !_isCarpetMode ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text(
                                state.tr('carWash'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: !_isCarpetMode ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!_isCarpetMode) {
                            setState(() {
                              _isCarpetMode = true;
                              if (!_plateController.text.startsWith('CPT-')) {
                                _plateController.text = 'CPT-${(DateTime.now().millisecondsSinceEpoch % 10000)}';
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isCarpetMode ? const Color(0xFF7C3AED) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.texture_rounded, size: 16, color: _isCarpetMode ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Text(
                                state.tr('carpetDropOff'),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: _isCarpetMode ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                        hint: state.tr('callerNameHint'),
                        prefixIcon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty ? state.tr('enterCallerName') : null,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: _phoneController,
                        label: state.tr('customerPhone'),
                        hint: '+251 91 234 5678',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_android,
                        validator: (v) => v == null || v.length < 9 ? state.tr('enterValidPhone') : null,
                      ),
                      const SizedBox(height: 12),

                      // 2. License Plate / Carpet Tag
                      CustomTextField(
                        controller: _plateController,
                        label: _isCarpetMode ? state.tr('carpetTagNumber') : state.tr('licensePlate'),
                        hint: _isCarpetMode ? 'e.g. CPT-8941' : 'e.g. 3-A12345 ET',
                        prefixIcon: _isCarpetMode ? Icons.tag_rounded : Icons.badge_outlined,
                        validator: (v) => v == null || v.trim().isEmpty ? (_isCarpetMode ? 'Enter tracking code' : 'Please enter license plate') : null,
                      ),
                      const SizedBox(height: 14),

                      // Carpet specifics vs Car wash specifics
                      if (_isCarpetMode) ...[
                        // Carpet Treatment Type
                        Text(
                          state.tr('carpetTypeSelection'),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _carpetType = 'type_a'),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _carpetType == 'type_a' ? const Color(0xFF7C3AED).withOpacity(0.08) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _carpetType == 'type_a' ? const Color(0xFF7C3AED) : AppColors.cardBorder,
                                      width: _carpetType == 'type_a' ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoCareAssets.buildPhotoThumbnail(
                                        imageUrl: AutoCareAssets.carpetTypeAUrl,
                                        width: double.infinity,
                                        height: 50,
                                        borderRadius: 6,
                                        fallbackIcon: Icons.texture_rounded,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(state.tr('carpetTypeA'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                                      Text('${state.carpetTypeAPricePerSqM.toStringAsFixed(0)} ETB/m²', style: const TextStyle(fontSize: 10.5, color: Color(0xFF7C3AED), fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _carpetType = 'type_b'),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _carpetType == 'type_b' ? const Color(0xFF7C3AED).withOpacity(0.08) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _carpetType == 'type_b' ? const Color(0xFF7C3AED) : AppColors.cardBorder,
                                      width: _carpetType == 'type_b' ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AutoCareAssets.buildPhotoThumbnail(
                                        imageUrl: AutoCareAssets.carpetTypeBUrl,
                                        width: double.infinity,
                                        height: 50,
                                        borderRadius: 6,
                                        fallbackIcon: Icons.texture_rounded,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(state.tr('carpetTypeB'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                                      Text('${state.carpetTypeBPricePerSqM.toStringAsFixed(0)} ETB/m²', style: const TextStyle(fontSize: 10.5, color: Color(0xFF7C3AED), fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Carpet Dimensions
                        Text(
                          '${state.tr("carpetDimensions")} & ${state.tr("carpetTotalArea")}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
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
                            color: const Color(0xFF7C3AED).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${state.tr("carpetTotalArea")}: ${_carpetArea.toStringAsFixed(1)} m²',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED)),
                              ),
                              Text(
                                'ETB ${carpetPrice.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ] else ...[
                        // Car Type Selector
                        CarTypeSelector(
                          selectedType: _carType,
                          onSelected: (t) => setState(() => _carType = t),
                        ),
                        const SizedBox(height: 14),

                        // Service Selection Mode & Checklist
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _useCustomChecklist = true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _useCustomChecklist ? AppColors.primary : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: _useCustomChecklist ? AppColors.primary : AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.checklist_rounded, size: 15, color: _useCustomChecklist ? Colors.white : AppColors.textPrimary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          state.tr('customServicesChecklist'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: _useCustomChecklist ? Colors.white : AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _useCustomChecklist = false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: !_useCustomChecklist ? AppColors.primary : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: !_useCustomChecklist ? AppColors.primary : AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 15, color: !_useCustomChecklist ? Colors.white : AppColors.textPrimary),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          state.tr('presetPackages'),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: !_useCustomChecklist ? Colors.white : AppColors.textPrimary,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        if (_useCustomChecklist) ...[
                          Container(
                            constraints: const BoxConstraints(maxHeight: 220),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: ListView(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              children: state.activeServiceItems.map((item) {
                                final isChecked = _selectedServiceIds.contains(item.id);
                                final itemPrice = item.getPriceFor(_carType);
                                return CheckboxListTile(
                                  value: isChecked,
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                  activeColor: AppColors.primary,
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isChecked ? FontWeight.w800 : FontWeight.w600,
                                            color: isChecked ? AppColors.primaryDark : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        CurrencyFormatter.format(itemPrice),
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                                      ),
                                    ],
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedServiceIds.add(item.id);
                                      } else {
                                        _selectedServiceIds.remove(item.id);
                                      }
                                      _negotiatedPriceController.text = _calculateSuggestedServicesTotal(state).toStringAsFixed(0);
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Negotiated Price Card
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: _negotiatedPriceController,
                                    label: state.tr('negotiatedTotalPrice'),
                                    hint: suggestedServicesTotal.toStringAsFixed(0),
                                    keyboardType: TextInputType.number,
                                    prefixIcon: Icons.handshake_outlined,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: AppColors.primaryDark,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: const BorderSide(color: AppColors.cardBorder),
                                    ),
                                  ),
                                  icon: const Icon(Icons.sync, size: 14),
                                  label: Text(
                                    state.tr('useSuggestedPrice'),
                                    style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _negotiatedPriceController.text = suggestedServicesTotal.toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ] else ...[
                          Text(
                            state.tr('selectedWashPackage'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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
                                        AutoCareAssets.buildPhotoThumbnail(
                                          imageUrl: AutoCareAssets.getPackageImage(pkg),
                                          width: 28,
                                          height: 28,
                                          borderRadius: 6,
                                        ),
                                        const SizedBox(width: 8),
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
                                      _selectedPackage = packages.firstWhere(
                                        (p) => p.id == id,
                                        orElse: () => packages.first,
                                      );
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      ],

                      // 3. Service Mode (Station vs Valet vs Mobile)
                      Text(
                        state.tr('serviceMode'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: Text(_isCarpetMode ? state.tr('atStationService') : state.tr('driveInStationBays')),
                            selected: _serviceType == ServiceType.walkInStation,
                            selectedColor: _isCarpetMode ? const Color(0xFF7C3AED) : AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _serviceType == ServiceType.walkInStation ? Colors.white : AppColors.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _serviceType = ServiceType.walkInStation),
                          ),
                          ChoiceChip(
                            label: Text(_isCarpetMode ? state.tr('valetPickupReturn') : state.tr('serviceValetPickUp')),
                            selected: _serviceType == ServiceType.valetPickUp,
                            selectedColor: const Color(0xFF7C3AED),
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _serviceType == ServiceType.valetPickUp ? Colors.white : AppColors.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _serviceType = ServiceType.valetPickUp),
                          ),
                          ChoiceChip(
                            label: Text(_isCarpetMode ? state.tr('atHomeService') : state.tr('atHomeMobileVan')),
                            selected: _serviceType == ServiceType.atHomeMobile,
                            selectedColor: AppColors.mobileVanColor,
                            labelStyle: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: _serviceType == ServiceType.atHomeMobile ? Colors.white : AppColors.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _serviceType = ServiceType.atHomeMobile),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Address if Mobile Van or Valet Pick-up
                      if (_serviceType.requiresLocation) ...[
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
                          label: state.tr('houseOrLandmark'),
                          hint: state.tr('landmarkHintExample'),
                          prefixIcon: Icons.home,
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Arrival Slot
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
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: _isCarpetMode ? const Color(0xFF7C3AED) : AppColors.primaryDark,
                              ),
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
                text: state.tr('confirmPhoneReservation'),
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
    if (!_isCarpetMode && !_useCustomChecklist && _selectedPackage == null) return;
    if (!_isCarpetMode && _useCustomChecklist && _selectedServiceIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.orange.shade800,
          content: Text(state.tr('selectAtLeastOneService')),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String? deliveryLoc;
      if (_serviceType.requiresLocation) {
        deliveryLoc = '$_selectedBishoftuArea - ${_addressController.text.trim()}';
      }

      final carpetRate = state.getCarpetPricePerSqM(_carpetType, _serviceType);
      final carpetPrice = _carpetArea * carpetRate;

      final suggestedServicesTotal = _calculateSuggestedServicesTotal(state);
      final negotiatedPrice = double.tryParse(_negotiatedPriceController.text.trim()) ?? suggestedServicesTotal;
      final selectedServiceNames = _useCustomChecklist
          ? state.activeServiceItems
              .where((s) => _selectedServiceIds.contains(s.id))
              .map((s) => s.name)
              .toList()
          : null;

      final booking = await state.bookNewWash(
        customerName: '${_callerNameController.text.trim()} [Phone]',
        customerPhone: _phoneController.text.trim(),
        serviceType: _serviceType,
        carType: _isCarpetMode ? CarType.automobile : _carType,
        licensePlate: _plateController.text.trim().toUpperCase(),
        package: _selectedPackage ?? (state.packages.isNotEmpty ? state.packages.first : null)!,
        deliveryLocation: deliveryLoc,
        paymentMethod: PaymentMethod.cash,
        gpsCoordinates: null,
        isPhoneBooking: true,
        isCarpet: _isCarpetMode,
        carpetType: _isCarpetMode ? _carpetType : null,
        carpetAreaSqMeters: _isCarpetMode ? _carpetArea : null,
        carpetDimensions: _isCarpetMode ? '${_lengthController.text.trim()}m x ${_widthController.text.trim()}m' : null,
        customTotalPrice: _isCarpetMode ? carpetPrice : (_useCustomChecklist ? negotiatedPrice : null),
        selectedServices: selectedServiceNames,
      );

      if (_isCarpetMode) {
        await state.sendCarpetRegistrationSms(booking);
      }

      if (context.mounted) {
        Navigator.pop(context);
        final tagLabel = _isCarpetMode ? 'Carpet order ${booking.licensePlate}' : 'Phone booking ${booking.licensePlate}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('$tagLabel recorded successfully!'),
            action: _isCarpetMode
                ? SnackBarAction(
                    label: 'Copy SMS',
                    textColor: Colors.amberAccent,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: state.getCarpetRegistrationSmsText(booking)));
                    },
                  )
                : null,
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
