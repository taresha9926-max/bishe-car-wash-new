import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/core/widgets/custom_button.dart';
import 'package:bishe_car_wash/core/widgets/custom_text_field.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/car_type_selector.dart';
import 'package:bishe_car_wash/features/customer/presentation/widgets/station_type_card.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';

class NewBookingScreen extends StatefulWidget {
  final ServiceType? initialServiceType;
  final CarType? initialCarType;
  final WashPackage? initialPackage;
  final bool isCarpet;
  final String? initialCarpetType;

  const NewBookingScreen({
    super.key,
    this.initialServiceType,
    this.initialCarType,
    this.initialPackage,
    this.isCarpet = false,
    this.initialCarpetType,
  });

  @override
  State<NewBookingScreen> createState() => _NewBookingScreenState();
}

class _NewBookingScreenState extends State<NewBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  late ServiceType _selectedServiceType;
  late CarType _selectedCarType;
  WashPackage? _selectedPackage;

  late bool _isCarpet;
  String _carpetType = 'type_a';
  final _lengthController = TextEditingController(text: '3.0');
  final _widthController = TextEditingController(text: '2.0');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+251 9');
  final _plateController = TextEditingController();
  final _addressController = TextEditingController();
  final _tipController = TextEditingController();
  double _tipAmount = 0.0;
  String _selectedBishoftuArea = AppConstants.bishoftuAreas.first;
  String? _pinnedGpsCoordinates;
  bool _isPinningGps = false;

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
    _selectedPackage = widget.initialPackage;
    if (_isCarpet) {
      _plateController.text = 'CPT-${(DateTime.now().millisecondsSinceEpoch % 10000)}';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _plateController.dispose();
    _addressController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final packages = state.packages;

    if (_selectedPackage == null && packages.isNotEmpty) {
      _selectedPackage = packages.first;
    }

    final carpetPrice = _carpetArea * state.getCarpetPricePerSqM(_carpetType, _selectedServiceType);
    final currentPrice = _isCarpet ? carpetPrice : (_selectedPackage?.getPriceFor(_selectedCarType) ?? 0.0);
    final grandTotal = currentPrice + _tipAmount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCarpet ? state.tr('carpetCleaningService') : state.tr('bookWashTitle')),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Choose Service Mode (Walk-in Station vs At-Home Mobile)
              Text(
                state.tr('selectServiceMode'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              StationTypeCard(
                serviceType: ServiceType.walkInStation,
                isSelected: _selectedServiceType == ServiceType.walkInStation,
                availableCapacity: state.availableBaysCount,
                onTap: () {
                  setState(() {
                    _selectedServiceType = ServiceType.walkInStation;
                  });
                },
              ),
              const SizedBox(height: 10),
              StationTypeCard(
                serviceType: ServiceType.valetPickUp,
                isSelected: _selectedServiceType == ServiceType.valetPickUp,
                availableCapacity: 1,
                onTap: () {
                  setState(() {
                    _selectedServiceType = ServiceType.valetPickUp;
                  });
                },
              ),
              const SizedBox(height: 10),
              StationTypeCard(
                serviceType: ServiceType.atHomeMobile,
                isSelected: _selectedServiceType == ServiceType.atHomeMobile,
                availableCapacity: state.isMobileVanAvailable ? 1 : 0,
                onTap: () {
                  setState(() {
                    _selectedServiceType = ServiceType.atHomeMobile;
                  });
                },
              ),
              const SizedBox(height: 22),

              if (!_isCarpet) ...[
                // 2. Select Car Type (Automobile, Minibus, Truck)
                CarTypeSelector(
                  selectedType: _selectedCarType,
                  onSelected: (type) {
                    setState(() {
                      _selectedCarType = type;
                    });
                  },
                ),
                const SizedBox(height: 22),

              // 3. Wash Package
              Text(
                state.tr('servicePackages'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              ...packages.map((pkg) {
                final isSelected = pkg.id == _selectedPackage?.id;
                final price = pkg.getPriceFor(_selectedCarType);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPackage = pkg;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.cardBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: pkg.id,
                          groupValue: _selectedPackage?.id,
                          activeColor: AppColors.primary,
                          onChanged: (_) {
                            setState(() {
                              _selectedPackage = pkg;
                            });
                          },
                        ),
                        AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: AutoCareAssets.getPackageImage(pkg),
                          width: 52,
                          height: 52,
                          borderRadius: 10,
                          durationBadge: '${pkg.durationMinutes}m',
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pkg.localizedName(state.currentLang),
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pkg.durationMinutes} mins • ${pkg.localizedDescription(state.currentLang)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
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
                          CurrencyFormatter.format(price),
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              ] else ...[
                // Carpet Cleaning Options
                Text(
                  state.tr('carpetCleaningOptions'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
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
                                '${state.getCarpetPricePerSqM("type_a", _selectedServiceType).toStringAsFixed(0)} ETB / m²',
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
                                '${state.getCarpetPricePerSqM("type_b", _selectedServiceType).toStringAsFixed(0)} ETB / m²',
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
                              'ETB ${carpetPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF312E81)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 4. Vehicle & Customer Details
              Text(
                state.tr('customerRole'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
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
                validator: (val) => val == null || val.trim().isEmpty ? (_isCarpet ? 'Enter tracking code' : state.tr('enterPlate')) : null,
              ),
              const SizedBox(height: 12),

              // Address field if At-Home Mobile Van or Valet Driver Pick-up
              if (_selectedServiceType.requiresLocation) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_selectedServiceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor).withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: (_selectedServiceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor).withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: _selectedServiceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _selectedServiceType == ServiceType.valetPickUp ? state.tr('driverPickUpLocation') : state.tr('locationArea'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedBishoftuArea,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        items: AppConstants.bishoftuAreas.map((area) {
                          return DropdownMenuItem(value: area, child: Text(area));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedBishoftuArea = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _addressController,
                        label: state.tr('streetLandmark'),
                        hint: state.tr('streetLandmarkHint'),
                        prefixIcon: Icons.home,
                        validator: (val) {
                          if (_selectedServiceType.requiresLocation && (val == null || val.trim().isEmpty)) {
                            return state.tr('streetLandmarkRequired');
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _pinnedGpsCoordinates != null ? AppColors.statusCompleted : AppColors.primary,
                            ),
                            backgroundColor: _pinnedGpsCoordinates != null
                                ? AppColors.statusCompleted.withOpacity(0.08)
                                : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          icon: _isPinningGps
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Icon(
                                  _pinnedGpsCoordinates != null ? Icons.check_circle : Icons.my_location,
                                  color: _pinnedGpsCoordinates != null ? AppColors.statusCompleted : AppColors.primary,
                                  size: 18,
                                ),
                          label: Text(
                            _pinnedGpsCoordinates != null
                                ? '${state.tr("gpsLocationPinned")}: $_pinnedGpsCoordinates'
                                : state.tr('useGpsLocation'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: _pinnedGpsCoordinates != null ? AppColors.statusCompleted : AppColors.primary,
                            ),
                          ),
                          onPressed: _pinGpsLocation,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 5. Optional Washer Gratuity / Tip
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
                        Text(
                          state.tr('washersTip'),
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.amber.shade900),
                        ),
                        const Spacer(),
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
                        for (final tipVal in [50, 100, 200]) ...[
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
                        ],
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
                              onChanged: (val) {
                                setState(() {
                                  _tipAmount = double.tryParse(val) ?? 0.0;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // 6. Booking Order Summary Box (Payment collected at gate)
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
                            _isCarpet
                                ? '${state.tr("carpetService")}: ${_carpetType == "type_b" ? state.tr("carpetTypeB") : state.tr("carpetTypeA")}'
                                : (_selectedPackage?.localizedName(state.currentLang) ?? ''),
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
                          ? '${_carpetArea.toStringAsFixed(1)} m² (${_lengthController.text.trim()}m × ${_widthController.text.trim()}m)'
                          : _selectedCarType.localizedName(state.currentLang),
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    if (_tipAmount > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('  + ${state.tr("washersTip")}:', style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                          Text('+ ETB ${_tipAmount.toStringAsFixed(2)}', style: TextStyle(color: Colors.amber.shade300, fontWeight: FontWeight.w700, fontSize: 12)),
                        ],
                      ),
                    ],
                    const Divider(color: Colors.white24, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${state.tr("total")}:',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          CurrencyFormatter.format(grandTotal),
                          style: const TextStyle(color: AppColors.oromiaGold, fontWeight: FontWeight.w900, fontSize: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.oromiaGold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.tr('paymentAtGateNote'),
                              style: const TextStyle(color: Colors.white, fontSize: 11.5, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              CustomButton(
                text: _isCarpet ? state.tr('bookCarpetCleaning') : state.tr('bookNow'),
                isLoading: _isSubmitting,
                onPressed: _handleBookingSubmit,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleBookingSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final state = AppStateProvider.read(context);
    if (!_isCarpet && _selectedPackage == null && state.packages.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? fullAddress;
      if (_selectedServiceType.requiresLocation) {
        fullAddress = '$_selectedBishoftuArea - ${_addressController.text.trim()}';
      }

      final carpetPrice = _carpetArea * state.getCarpetPricePerSqM(_carpetType, _selectedServiceType);
      final booking = await state.bookNewWash(
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        serviceType: _selectedServiceType,
        carType: _isCarpet ? CarType.automobile : _selectedCarType,
        licensePlate: _plateController.text.trim().toUpperCase(),
        package: _selectedPackage ?? state.packages.first,
        deliveryLocation: fullAddress,
        paymentMethod: PaymentMethod.cash,
        gpsCoordinates: _pinnedGpsCoordinates,
        isCarpet: _isCarpet,
        carpetType: _isCarpet ? _carpetType : null,
        carpetAreaSqMeters: _isCarpet ? _carpetArea : null,
        carpetDimensions: _isCarpet ? '${_lengthController.text.trim()}m x ${_widthController.text.trim()}m' : null,
        customTotalPrice: _isCarpet ? carpetPrice : null,
        tipAmount: _tipAmount,
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
          MaterialPageRoute(
            builder: (_) => LiveTrackingScreen(bookingId: booking.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Failed to create booking: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _pinGpsLocation() async {
    setState(() => _isPinningGps = true);
    // Simulate high-precision Bishoftu GPS coordinate acquisition
    await Future.delayed(const Duration(milliseconds: 500));
    final randomOffset = (DateTime.now().millisecond % 50) / 10000.0;
    final lat = (8.7523 + randomOffset).toStringAsFixed(4);
    final lng = (38.9785 + randomOffset).toStringAsFixed(4);
    if (mounted) {
      setState(() {
        _pinnedGpsCoordinates = '$lat, $lng';
        _isPinningGps = false;
      });
    }
  }
}
