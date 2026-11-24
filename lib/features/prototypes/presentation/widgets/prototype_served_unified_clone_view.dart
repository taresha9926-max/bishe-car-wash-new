import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/ad_video_showcase_card.dart';
import 'package:bishe_car_wash/features/welcome/presentation/widgets/welcome_service_carousel_banner.dart';
import 'prototype_live_ticket_view.dart';

/// Flagship Prototype: Unified Served Clone
/// Clones the served web application into a streamlined single-page experience.
/// Designed with Apple Design standards via /awesome-design-md:
/// - Photography-first cards reusing AutoCareAssets
/// - Zero clutter: multi-page wizard reduced to a 1-screen booking flow
/// - Collapsible modules for TikTok Reels, Lounge Amenities, Location & Tracking
/// - Studio White & Action Blue (#0071E3) on Canvas Parchment (#F5F5F7)
class PrototypeServedUnifiedCloneView extends StatefulWidget {
  final ValueChanged<WashBooking>? onBookingComplete;
  final VoidCallback onOpenLounge;

  const PrototypeServedUnifiedCloneView({
    super.key,
    this.onBookingComplete,
    required this.onOpenLounge,
  });

  @override
  State<PrototypeServedUnifiedCloneView> createState() => _PrototypeServedUnifiedCloneViewState();
}

class _PrototypeServedUnifiedCloneViewState extends State<PrototypeServedUnifiedCloneView> {
  // Service Division Toggle (Car vs Carpet)
  bool _isCarpet = false;

  // Car Wash state
  CarType _selectedCarType = CarType.automobile;

  // Carpet Wash state
  String _carpetFabric = 'type_a'; // 'type_a' (standard) or 'type_b' (luxury silk/wool)
  final _carpetLengthController = TextEditingController(text: '3.0');
  final _carpetWidthController = TextEditingController(text: '2.0');

  // Package & Delivery
  WashPackage? _selectedPackage;
  ServiceType _selectedDelivery = ServiceType.walkInStation;

  // Customer Inputs
  final _plateController = TextEditingController(text: 'ET-44321');
  final _phoneController = TextEditingController(text: '0912345678');
  final _nameController = TextEditingController(text: 'Customer Driver');

  // Collapsible Module Accordion States
  bool _isReelsExpanded = false;
  bool _isLoungeExpanded = false;
  bool _isLocationExpanded = false;
  bool _isTrackingExpanded = false;

  // Tracking query
  final _trackQueryController = TextEditingController();

  // Submission State
  WashBooking? _submittedBooking;

  @override
  void dispose() {
    _carpetLengthController.dispose();
    _carpetWidthController.dispose();
    _plateController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _trackQueryController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice(List<WashPackage> packages) {
    final activePkg = _selectedPackage ?? (packages.isNotEmpty ? packages.first : null);
    if (activePkg == null) return 250.0;

    double basePrice = 250.0;
    if (_isCarpet) {
      final length = double.tryParse(_carpetLengthController.text.trim()) ?? 3.0;
      final width = double.tryParse(_carpetWidthController.text.trim()) ?? 2.0;
      final area = (length * width).clamp(1.0, 100.0);
      final ratePerSqm = _carpetFabric == 'type_b' ? 70.0 : 50.0;
      basePrice = area * ratePerSqm;
    } else {
      basePrice = activePkg.pricingByCarType[_selectedCarType] ?? 250.0;
    }

    // Delivery surcharge
    double deliveryFee = 0.0;
    if (_selectedDelivery == ServiceType.valetPickUp) {
      deliveryFee = 150.0;
    } else if (_selectedDelivery == ServiceType.atHomeMobile) {
      deliveryFee = 250.0;
    }

    return basePrice + deliveryFee;
  }

  void _submit() {
    final state = AppStateProvider.read(context);
    final packages = state.packages;
    final pkg = _selectedPackage ?? (packages.isNotEmpty ? packages.first : null);
    if (pkg == null) return;

    final totalPrice = _calculateTotalPrice(packages);
    final booking = WashBooking(
      id: 'proto-served-${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim().isEmpty ? 'Customer Driver' : _nameController.text.trim(),
      customerPhone: _phoneController.text.trim(),
      serviceType: _selectedDelivery,
      carType: _selectedCarType,
      licensePlate: _isCarpet
          ? 'CPT-${DateTime.now().millisecondsSinceEpoch % 10000}'
          : _plateController.text.trim().toUpperCase(),
      package: pkg,
      status: WashStatus.assignedToBay,
      payment: PaymentInfo(
        method: PaymentMethod.cash,
        amount: totalPrice,
      ),
      createdAt: DateTime.now(),
    );

    setState(() {
      _submittedBooking = booking;
    });

    widget.onBookingComplete?.call(booking);
  }

  @override
  Widget build(BuildContext context) {
    if (_submittedBooking != null) {
      return PrototypeLiveTicketView(
        booking: _submittedBooking!,
        onReset: () => setState(() => _submittedBooking = null),
        onOpenLounge: widget.onOpenLounge,
      );
    }

    final state = AppStateProvider.of(context);
    final lang = state.currentLang;
    final packages = state.packages;
    final activePkg = _selectedPackage ?? (packages.isNotEmpty ? packages.first : null);
    final calculatedTotal = _calculateTotalPrice(packages);

    // Apple Design Tokens
    const appleCanvas = Color(0xFFF5F5F7);
    const appleInk = Color(0xFF1D1D1F);
    const appleMuted = Color(0xFF86868B);
    const appleHairline = Color(0xFFE5E5EA);
    const appleActionBlue = Color(0xFF0071E3);
    const appleLightBlue = Color(0xFFF0F7FF);

    return Container(
      color: appleCanvas,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Top Brand & Telemetry Bar
                _buildStationHeader(context, state, appleInk, appleMuted, appleHairline, appleActionBlue),
                const SizedBox(height: 16),

                // 2. Main Booking Engine Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: appleHairline),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Car Wash vs Carpet Wash Segmented Slider (Replaces 2 entire pages!)
                      _buildDivisionSlider(lang, state, appleActionBlue, appleInk, appleHairline),
                      const SizedBox(height: 20),

                      // Vehicle Selection or Carpet Dimensions
                      if (!_isCarpet) ...[
                        _buildVehicleSelector(lang, state, appleActionBlue, appleInk, appleMuted, appleHairline, appleLightBlue),
                      ] else ...[
                        _buildCarpetConfiguration(lang, state, appleActionBlue, appleInk, appleMuted, appleHairline, appleLightBlue),
                      ],
                      const SizedBox(height: 20),

                      // Service Package Cards
                      _buildPackageSelector(packages, activePkg, lang, state, appleActionBlue, appleInk, appleMuted, appleHairline, appleLightBlue),
                      const SizedBox(height: 20),

                      // Delivery Mode Segmented Pills
                      _buildDeliverySelector(state, appleActionBlue, appleInk, appleMuted, appleHairline, appleLightBlue),
                      const SizedBox(height: 20),

                      // Plate & Phone Fields (Responsive Layout: Stacks on <360px)
                      _buildContactInputs(state, appleActionBlue, appleInk, appleMuted, appleHairline),
                      const SizedBox(height: 20),

                      // Live Total & Instant Drive-In Button
                      _buildSummaryAndCTA(calculatedTotal, state, appleActionBlue, appleInk, appleMuted, appleHairline),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Collapsible Modules (Decluttering all media, lounge, location & tracking into accordions)
                _buildCollapsibleSection(
                  title: state.tr('carCareReelsTitle'),
                  subtitle: '@bishecarwash • 4 Reels',
                  icon: Icons.play_circle_fill_rounded,
                  isExpanded: _isReelsExpanded,
                  appleInk: appleInk,
                  appleMuted: appleMuted,
                  appleHairline: appleHairline,
                  appleActionBlue: appleActionBlue,
                  onToggle: () => setState(() => _isReelsExpanded = !_isReelsExpanded),
                  child: const ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    child: AdVideoShowcaseCard(),
                  ),
                ),
                const SizedBox(height: 12),

                _buildCollapsibleSection(
                  title: state.tr('stationAmenitiesTitle'),
                  subtitle: 'High-speed Wi-Fi, Lounge & Coffee',
                  icon: Icons.coffee_rounded,
                  isExpanded: _isLoungeExpanded,
                  appleInk: appleInk,
                  appleMuted: appleMuted,
                  appleHairline: appleHairline,
                  appleActionBlue: appleActionBlue,
                  onToggle: () => setState(() => _isLoungeExpanded = !_isLoungeExpanded),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    child: WelcomeServiceCarouselBanner(isMobile: MediaQuery.of(context).size.width < 600),
                  ),
                ),
                const SizedBox(height: 12),

                _buildCollapsibleSection(
                  title: state.tr('stationLocationAndHours'),
                  subtitle: 'Bishoftu Expressway Exit • 24/7 Service',
                  icon: Icons.location_on_rounded,
                  isExpanded: _isLocationExpanded,
                  appleInk: appleInk,
                  appleMuted: appleMuted,
                  appleHairline: appleHairline,
                  appleActionBlue: appleActionBlue,
                  onToggle: () => setState(() => _isLocationExpanded = !_isLocationExpanded),
                  child: _buildLocationExpandedContent(appleInk, appleMuted, appleActionBlue, appleHairline),
                ),
                const SizedBox(height: 12),

                _buildCollapsibleSection(
                  title: state.tr('trackExistingBooking'),
                  subtitle: 'Lookup wash progress by plate or phone',
                  icon: Icons.search_rounded,
                  isExpanded: _isTrackingExpanded,
                  appleInk: appleInk,
                  appleMuted: appleMuted,
                  appleHairline: appleHairline,
                  appleActionBlue: appleActionBlue,
                  onToggle: () => setState(() => _isTrackingExpanded = !_isTrackingExpanded),
                  child: _buildTrackingLookupContent(state, appleInk, appleMuted, appleActionBlue, appleHairline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Station Header Bar
  Widget _buildStationHeader(
    BuildContext context,
    dynamic state,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
    Color appleActionBlue,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appleHairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            AutoCareAssets.welcomeHeroUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.local_car_wash_rounded, color: Color(0xFF0071E3)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.tr('appName'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.3,
                  color: appleInk,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.tr('bishoftu'),
                style: TextStyle(fontSize: 12, color: appleMuted, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF7EE),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: const Color(0xFFB7E4C7)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF2D6A4F)),
              SizedBox(width: 5),
              Text(
                '2 Bays Open',
                style: TextStyle(
                  color: Color(0xFF2D6A4F),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Division Slider (Car Wash vs Carpet Wash)
  Widget _buildDivisionSlider(
    String lang,
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleHairline,
  ) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE5E5EA),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isCarpet = false),
              borderRadius: BorderRadius.circular(9999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_isCarpet ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: !_isCarpet
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.directions_car_rounded,
                      size: 18,
                      color: !_isCarpet ? appleActionBlue : const Color(0xFF86868B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.tr('carWashingService'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: !_isCarpet ? FontWeight.w600 : FontWeight.w500,
                            color: !_isCarpet ? appleInk : const Color(0xFF86868B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _isCarpet = true),
              borderRadius: BorderRadius.circular(9999),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: _isCarpet ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: _isCarpet
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.texture_rounded,
                      size: 18,
                      color: _isCarpet ? appleActionBlue : const Color(0xFF86868B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          state.tr('carpetWashingService'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: _isCarpet ? FontWeight.w600 : FontWeight.w500,
                            color: _isCarpet ? appleInk : const Color(0xFF86868B),
                          ),
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
    );
  }

  // 3. Vehicle Selector (Reusing AutoCareAssets photography)
  Widget _buildVehicleSelector(
    String lang,
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
    Color appleLightBlue,
  ) {
    final vehicleAssets = [
      {'type': CarType.automobile, 'img': AutoCareAssets.carSedanUrl},
      {'type': CarType.minibus, 'img': AutoCareAssets.carMinibusUrl},
      {'type': CarType.truck, 'img': AutoCareAssets.carTruckUrl},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.tr('vehicleCategory'),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: appleInk, letterSpacing: -0.2),
        ),
        const SizedBox(height: 10),
        Row(
          children: vehicleAssets.map((item) {
            final type = item['type'] as CarType;
            final img = item['img'] as String;
            final isSel = type == _selectedCarType;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  onTap: () => setState(() => _selectedCarType = type),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSel ? appleLightBlue : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel ? appleActionBlue : appleHairline,
                        width: isSel ? 1.8 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            img,
                            width: double.infinity,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => SizedBox(
                              height: 48,
                              child: Center(child: Icon(type.icon, color: appleMuted)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            type.localizedName(lang),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                              color: appleInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 4. Carpet Configuration (Fabric Tier & Dimensions)
  Widget _buildCarpetConfiguration(
    String lang,
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
    Color appleLightBlue,
  ) {
    final length = double.tryParse(_carpetLengthController.text.trim()) ?? 3.0;
    final width = double.tryParse(_carpetWidthController.text.trim()) ?? 2.0;
    final area = length * width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          state.tr('carpetDimensions'),
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: appleInk, letterSpacing: -0.2),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCarpetTierCard(
                title: state.tr('carpetTypeAStation'),
                subtitle: '50 ETB / m²',
                imageUrl: AutoCareAssets.carpetTypeAUrl,
                isSelected: _carpetFabric == 'type_a',
                appleActionBlue: appleActionBlue,
                appleInk: appleInk,
                appleMuted: appleMuted,
                appleHairline: appleHairline,
                appleLightBlue: appleLightBlue,
                onTap: () => setState(() => _carpetFabric = 'type_a'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCarpetTierCard(
                title: state.tr('carpetTypeBStation'),
                subtitle: '70 ETB / m²',
                imageUrl: AutoCareAssets.carpetTypeBUrl,
                isSelected: _carpetFabric == 'type_b',
                appleActionBlue: appleActionBlue,
                appleInk: appleInk,
                appleMuted: appleMuted,
                appleHairline: appleHairline,
                appleLightBlue: appleLightBlue,
                onTap: () => setState(() => _carpetFabric = 'type_b'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _carpetLengthController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: state.tr('carpetLengthMeters'),
                  labelStyle: TextStyle(color: appleMuted, fontSize: 13),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: appleHairline)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: appleHairline)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _carpetWidthController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: state.tr('carpetWidthMeters'),
                  labelStyle: TextStyle(color: appleMuted, fontSize: 13),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: appleHairline)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: appleHairline)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: appleHairline),
              ),
              child: Text(
                '${area.toStringAsFixed(1)} m²',
                style: TextStyle(fontWeight: FontWeight.w600, color: appleInk, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarpetTierCard({
    required String title,
    required String subtitle,
    required String imageUrl,
    required bool isSelected,
    required Color appleActionBlue,
    required Color appleInk,
    required Color appleMuted,
    required Color appleHairline,
    required Color appleLightBlue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? appleLightBlue : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? appleActionBlue : appleHairline,
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(imageUrl, width: 42, height: 42, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: appleInk),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: isSelected ? appleActionBlue : appleMuted, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. Wash Package Selector (with AutoCareAssets photography)
  Widget _buildPackageSelector(
    List<WashPackage> packages,
    WashPackage? activePkg,
    String lang,
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
    Color appleLightBlue,
  ) {
    final packagePhotos = [
      AutoCareAssets.packageFoamUrl,
      AutoCareAssets.packageVacuumUrl,
      AutoCareAssets.packageSteamEngineUrl,
      AutoCareAssets.packageDeluxeSpaUrl,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.tr('servicePackage'),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: appleInk, letterSpacing: -0.2),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.tr('pricesNegotiableNote'),
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: appleMuted, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Column(
          children: List.generate(packages.length, (index) {
            final pkg = packages[index];
            final isSel = pkg.id == (activePkg?.id ?? packages.first.id);
            final photo = packagePhotos[index % packagePhotos.length];
            final price = pkg.pricingByCarType[_selectedCarType] ?? 250.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedPackage = pkg),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSel ? appleLightBlue : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSel ? appleActionBlue : appleHairline,
                      width: isSel ? 1.8 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          photo,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.cleaning_services_rounded, color: Color(0xFF0071E3)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pkg.localizedName(lang),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                                color: appleInk,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              pkg.localizedDescription(lang),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 12, color: appleMuted),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${price.toStringAsFixed(0)} ETB',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSel ? appleActionBlue : appleInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 6. Delivery Mode Pills
  Widget _buildDeliverySelector(
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
    Color appleLightBlue,
  ) {
    final modes = [
      {'type': ServiceType.walkInStation, 'label': state.tr('deliveryModeStation'), 'icon': Icons.storefront_rounded},
      {'type': ServiceType.valetPickUp, 'label': state.tr('deliveryModeValet'), 'icon': Icons.swap_calls_rounded},
      {'type': ServiceType.atHomeMobile, 'label': state.tr('deliveryModeMobile'), 'icon': Icons.airport_shuttle_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Service Delivery Option',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: appleInk, letterSpacing: -0.2),
        ),
        const SizedBox(height: 8),
        Row(
          children: modes.map((mode) {
            final type = mode['type'] as ServiceType;
            final label = mode['label'] as String;
            final icon = mode['icon'] as IconData;
            final isSel = type == _selectedDelivery;

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: InkWell(
                  onTap: () => setState(() => _selectedDelivery = type),
                  borderRadius: BorderRadius.circular(9999),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? appleLightBlue : const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                        color: isSel ? appleActionBlue : appleHairline,
                        width: isSel ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: isSel ? appleActionBlue : appleMuted),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
                              color: isSel ? appleActionBlue : appleInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 7. Contact Details Inputs (Plate & Phone)
  Widget _buildContactInputs(
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 360;

        final plateField = TextField(
          key: const Key('unified_plate_input'),
          controller: _plateController,
          style: TextStyle(color: appleInk, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: _isCarpet ? 'Carpet Tag' : state.tr('licensePlate'),
            labelStyle: TextStyle(color: appleMuted, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: appleHairline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: appleHairline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: appleActionBlue, width: 1.5)),
            prefixIcon: Icon(Icons.pin_rounded, color: appleMuted, size: 20),
          ),
        );

        final phoneField = TextField(
          key: const Key('unified_phone_input'),
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: TextStyle(color: appleInk, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            labelText: state.tr('customerPhone'),
            labelStyle: TextStyle(color: appleMuted, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF5F5F7),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: appleHairline)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: appleHairline)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: appleActionBlue, width: 1.5)),
            prefixIcon: Icon(Icons.phone_rounded, color: appleMuted, size: 20),
          ),
        );

        if (stack) {
          return Column(
            children: [
              plateField,
              const SizedBox(height: 12),
              phoneField,
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(child: plateField),
              const SizedBox(width: 12),
              Expanded(child: phoneField),
            ],
          );
        }
      },
    );
  }

  // 8. Summary & Full-Width Stadium Action Button
  Widget _buildSummaryAndCTA(
    double total,
    dynamic state,
    Color appleActionBlue,
    Color appleInk,
    Color appleMuted,
    Color appleHairline,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: appleHairline),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.tr('calculatedTotal'),
                style: TextStyle(color: appleMuted, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Text(
                '${total.toStringAsFixed(0)} ETB',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: appleActionBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: appleActionBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_car_wash_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${state.tr('confirmAndDriveInBtn')} (${total.toStringAsFixed(0)} ETB)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 9. Reusable Collapsible Module Accordion
  Widget _buildCollapsibleSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isExpanded,
    required Color appleInk,
    required Color appleMuted,
    required Color appleHairline,
    required Color appleActionBlue,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appleHairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: appleActionBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: appleInk, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(fontSize: 12, color: appleMuted),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down_rounded, color: appleMuted, size: 22),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFE5E5EA)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  // 10. Location Expanded Content
  Widget _buildLocationExpandedContent(Color appleInk, Color appleMuted, Color appleActionBlue, Color appleHairline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.network(
            AutoCareAssets.stationBayUrl,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 120, color: const Color(0xFFF5F5F7)),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BISHE Car Wash Station, Bishoftu',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: appleInk),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Near Babogaya & Hora Crater Lakes • Open 24/7',
                    style: TextStyle(color: appleMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => UrlLauncherHelper.openUrl('https://maps.google.com/?q=8.7523,38.9881'),
              style: ElevatedButton.styleFrom(
                backgroundColor: appleActionBlue,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                elevation: 0,
              ),
              icon: const Icon(Icons.directions_rounded, size: 16),
              label: const Text('Directions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ],
    );
  }

  // 11. Tracking Lookup Expanded Content
  Widget _buildTrackingLookupContent(dynamic state, Color appleInk, Color appleMuted, Color appleActionBlue, Color appleHairline) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _trackQueryController,
            decoration: InputDecoration(
              hintText: 'Enter Plate or Phone...',
              hintStyle: TextStyle(color: appleMuted, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF5F5F7),
              isDense: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: appleHairline)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: appleHairline)),
              prefixIcon: Icon(Icons.search_rounded, color: appleMuted, size: 20),
            ),
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Checking active wash queue...'), duration: Duration(seconds: 2)),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: appleActionBlue,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text('Track', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
