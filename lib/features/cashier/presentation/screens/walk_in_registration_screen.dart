import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../admin/domain/models/staff_member.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/car_type.dart';
import '../../../booking_service/domain/models/car_wash_service_item.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_package.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/car_type_selector.dart';

class WalkInRegistrationScreen extends StatefulWidget {
  final BayType? preselectedBay;
  final bool? initialCarpetMode;

  const WalkInRegistrationScreen({
    super.key,
    this.preselectedBay,
    this.initialCarpetMode,
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

  // Carpet Cleaning Controllers
  final _lengthController = TextEditingController(text: '3.0');
  final _widthController = TextEditingController(text: '2.0');
  bool _isCarpetMode = false;
  String _carpetType = 'type_a'; // 'type_a' or 'type_b'
  ServiceType _carpetDeliveryMethod = ServiceType.walkInStation;

  CarType _carType = CarType.automobile;
  late BayType _bayType;
  WashPackage? _package;

  // Custom Detail Services Checklist & Negotiated Pricing
  bool _useCustomChecklist = true;
  final Set<String> _selectedServiceIds = {'srv_body_wash', 'srv_tire_clean'};
  final _negotiatedPriceController = TextEditingController();

  bool _isPaidNow = false;
  PaymentMethod _paymentMethod = PaymentMethod.cash;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _bayType = widget.preselectedBay ?? BayType.bay1;
    if (widget.initialCarpetMode == true) {
      _isCarpetMode = true;
      _plateController.text = 'CPT-${(DateTime.now().millisecondsSinceEpoch % 10000)}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _phoneController.dispose();
    _refCodeController.dispose();
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
    return (l * w);
  }

  double _calculateCarpetPrice(double ratePerSqM) {
    return _carpetArea * ratePerSqM;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;

    if (_package == null && packages.isNotEmpty) {
      _package = packages.first;
    }

    final suggestedServicesTotal = _calculateSuggestedServicesTotal(state);
    final enteredNegotiated = double.tryParse(_negotiatedPriceController.text.trim());
    final effectiveWashPrice = _useCustomChecklist
        ? (enteredNegotiated ?? suggestedServicesTotal)
        : (_package?.getPriceFor(_carType) ?? 0.0);
    final price = effectiveWashPrice;

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

              // Service Selector Toggle: Vehicle vs Carpet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
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
                              _plateController.text = '';
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isCarpetMode ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.directions_car_rounded, size: 18, color: !_isCarpetMode ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  state.tr('vehicleRegistration'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: !_isCarpetMode ? Colors.white : AppColors.textPrimary,
                                  ),
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
                              if (_plateController.text.trim().isEmpty) {
                                _plateController.text = 'CPT-${(DateTime.now().millisecondsSinceEpoch % 10000)}';
                              }
                            });
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isCarpetMode ? const Color(0xFF6366F1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.texture_rounded, size: 18, color: _isCarpetMode ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  state.tr('carpetDropOff'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _isCarpetMode ? Colors.white : AppColors.textPrimary,
                                  ),
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
              const SizedBox(height: 18),

              // 1. Customer Name & Phone
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
                controller: _phoneController,
                label: state.tr('customerPhone'),
                hint: '+251 91 123 4567',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_android,
                validator: (val) => val == null || val.length < 9 ? state.tr('enterValidPhone') : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _plateController,
                label: _isCarpetMode ? state.tr('carpetTrackingTag') : state.tr('licensePlate'),
                hint: _isCarpetMode ? 'e.g. CPT-8941' : 'e.g. ET-3-B98124 or 3-B98124',
                prefixIcon: _isCarpetMode ? Icons.tag_rounded : Icons.badge_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? (_isCarpetMode ? 'Enter tracking code' : state.tr('enterPlate')) : null,
              ),
              const SizedBox(height: 18),

              if (!_isCarpetMode) ...[
                // 2. Select Car Type
                CarTypeSelector(
                  selectedType: _carType,
                  onSelected: (type) => setState(() => _carType = type),
                ),
                const SizedBox(height: 18),

                // 3. Service Selection Mode & Checklist
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.tr('servicePackages'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _useCustomChecklist = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _useCustomChecklist ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _useCustomChecklist ? AppColors.primary : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.checklist_rounded, size: 16, color: _useCustomChecklist ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  state.tr('customServicesChecklist'),
                                  style: TextStyle(
                                    fontSize: 11.5,
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
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _useCustomChecklist = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: !_useCustomChecklist ? AppColors.primary : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !_useCustomChecklist ? AppColors.primary : AppColors.cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 16, color: !_useCustomChecklist ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  state.tr('presetPackages'),
                                  style: TextStyle(
                                    fontSize: 11.5,
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
                const SizedBox(height: 12),

                if (_useCustomChecklist) ...[
                  ...state.activeServiceItems.map((item) {
                    final isChecked = _selectedServiceIds.contains(item.id);
                    final itemPrice = item.getPriceFor(_carType);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: isChecked ? AppColors.primary.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isChecked ? AppColors.primary : AppColors.cardBorder,
                          width: isChecked ? 1.5 : 1,
                        ),
                      ),
                      child: CheckboxListTile(
                        value: isChecked,
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        activeColor: AppColors.primary,
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isChecked ? FontWeight.w800 : FontWeight.w600,
                                  color: isChecked ? AppColors.primaryDark : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                CurrencyFormatter.format(itemPrice),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                        subtitle: item.description != null && item.description!.isNotEmpty
                            ? Text(
                                item.description!,
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                              )
                            : null,
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
                      ),
                    );
                  }),
                  const SizedBox(height: 10),

                  // Negotiated Price Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${state.tr("suggestedTariffTotal")}:',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            Text(
                              CurrencyFormatter.format(suggestedServicesTotal),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
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
                              icon: const Icon(Icons.sync, size: 15),
                              label: Text(
                                state.tr('useSuggestedPrice'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                              onPressed: () {
                                setState(() {
                                  _negotiatedPriceController.text = suggestedServicesTotal.toStringAsFixed(0);
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ] else ...[
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
                ],
              ] else ...[
                // Carpet Specific Configuration
                Text(
                  state.tr('carpetCleaningOptions'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _carpetType = 'type_a'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _carpetType == 'type_a' ? const Color(0xFF6366F1).withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _carpetType == 'type_a' ? const Color(0xFF6366F1) : AppColors.cardBorder,
                              width: _carpetType == 'type_a' ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AutoCareAssets.buildPhotoThumbnail(
                                    imageUrl: AutoCareAssets.carpetTypeAUrl,
                                    width: 38,
                                    height: 38,
                                    borderRadius: 8,
                                    fallbackIcon: Icons.cleaning_services_rounded,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.tr('carpetTypeA'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _carpetType == 'type_a' ? const Color(0xFF6366F1) : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${state.getCarpetPricePerSqM("type_a", _carpetDeliveryMethod).toStringAsFixed(0)} ETB / m²',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF4338CA)),
                              ),
                              Text(state.tr('carpetTypeADesc'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _carpetType = 'type_b'),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _carpetType == 'type_b' ? const Color(0xFFDC2626).withOpacity(0.08) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _carpetType == 'type_b' ? const Color(0xFFDC2626) : AppColors.cardBorder,
                              width: _carpetType == 'type_b' ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  AutoCareAssets.buildPhotoThumbnail(
                                    imageUrl: AutoCareAssets.carpetTypeBUrl,
                                    width: 38,
                                    height: 38,
                                    borderRadius: 8,
                                    fallbackIcon: Icons.auto_awesome_rounded,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.tr('carpetTypeB'),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: _carpetType == 'type_b' ? const Color(0xFFDC2626) : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${state.getCarpetPricePerSqM("type_b", _carpetDeliveryMethod).toStringAsFixed(0)} ETB / m²',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFB91C1C)),
                              ),
                              Text(state.tr('carpetTypeBDesc'), style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dimension inputs
                Container(
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
                              'ETB ${(_calculateCarpetPrice(_carpetType == "type_b" ? state.carpetTypeBPricePerSqM : state.carpetTypeAPricePerSqM)).toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF312E81)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Delivery Provision Method
                Text(
                  state.tr('serviceProvisionMode'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(state.tr('atStationService')),
                      selected: _carpetDeliveryMethod == ServiceType.walkInStation,
                      onSelected: (val) {
                        if (val) setState(() => _carpetDeliveryMethod = ServiceType.walkInStation);
                      },
                    ),
                    ChoiceChip(
                      label: Text(state.tr('atHomeService')),
                      selected: _carpetDeliveryMethod == ServiceType.atHomeMobile,
                      onSelected: (val) {
                        if (val) setState(() => _carpetDeliveryMethod = ServiceType.atHomeMobile);
                      },
                    ),
                    ChoiceChip(
                      label: Text(state.tr('valetPickupReturn')),
                      selected: _carpetDeliveryMethod == ServiceType.valetPickUp,
                      onSelected: (val) {
                        if (val) setState(() => _carpetDeliveryMethod = ServiceType.valetPickUp);
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 18),

              // 4. Station Bay / Van Assignment (Only for vehicles, zero cross-contamination)
              if (!_isCarpetMode) ...[
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
              ],

              // Submit Action
              CustomButton(
                text: 'Book Now • ${CurrencyFormatter.format(_isCarpetMode ? _calculateCarpetPrice(_carpetType == "type_b" ? state.carpetTypeBPricePerSqM : state.carpetTypeAPricePerSqM) : price)}',
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
    final state = AppStateProvider.read(context);
    if (!_isCarpetMode && _package == null && state.packages.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final effectivePackage = _package ?? (state.packages.isNotEmpty ? state.packages.first : null);
      if (effectivePackage == null) return;
      final calculatedCarpetPrice = _calculateCarpetPrice(_carpetType == 'type_b' ? state.carpetTypeBPricePerSqM : state.carpetTypeAPricePerSqM);

      if (!_isCarpetMode && _useCustomChecklist && _selectedServiceIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orange.shade800,
            content: Text(state.tr('selectAtLeastOneService')),
          ),
        );
        return;
      }

      final suggestedServicesTotal = _calculateSuggestedServicesTotal(state);
      final negotiatedPrice = double.tryParse(_negotiatedPriceController.text.trim()) ?? suggestedServicesTotal;
      final selectedServiceNames = _useCustomChecklist
          ? state.activeServiceItems
              .where((s) => _selectedServiceIds.contains(s.id))
              .map((s) => s.name)
              .toList()
          : null;

      final booking = await state.registerWalkIn(
        customerName: _nameController.text.trim(),
        licensePlate: _plateController.text.trim().toUpperCase(),
        customerPhone: _phoneController.text.trim(),
        carType: _isCarpetMode ? CarType.automobile : _carType,
        package: effectivePackage,
        assignedBay: _isCarpetMode ? null : _bayType,
        paymentMethod: PaymentMethod.cash,
        markPaid: false,
        transactionRef: null,
        isCarpet: _isCarpetMode,
        carpetType: _isCarpetMode ? _carpetType : null,
        carpetAreaSqMeters: _isCarpetMode ? _carpetArea : null,
        carpetDimensions: _isCarpetMode ? '${_lengthController.text.trim()}m x ${_widthController.text.trim()}m' : null,
        customTotalPrice: _isCarpetMode ? calculatedCarpetPrice : (_useCustomChecklist ? negotiatedPrice : null),
        selectedServices: selectedServiceNames,
      );

      if (_isCarpetMode) {
        await state.sendCarpetRegistrationSms(booking);
      }

      if (mounted) {
        final label = _isCarpetMode ? 'Carpet order ${booking.licensePlate}' : 'Gate entry ${booking.licensePlate} stationed at ${_bayType.displayName}';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusCompleted,
            content: Text('$label registered successfully!'),
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
