import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/auto_care_assets.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/core/utils/url_launcher_helper.dart';
import 'package:bishe_car_wash/core/widgets/app_role_header.dart';
import 'package:bishe_car_wash/core/widgets/responsive_layout.dart';
import 'package:bishe_car_wash/core/widgets/service_promo_banner.dart';
import 'package:bishe_car_wash/core/widgets/status_badge.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_dispatcher.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  CarType _previewCarType = CarType.automobile;
  String? _selectedPackageId;
  final TextEditingController _trackController = TextEditingController();
  bool _isCarpetTabActive = false;
  String _customerCarpetType = 'type_a';
  final _carpetLengthCalc = TextEditingController(text: '3.0');
  final _carpetWidthCalc = TextEditingController(text: '2.0');

  @override
  void dispose() {
    _trackController.dispose();
    _carpetLengthCalc.dispose();
    _carpetWidthCalc.dispose();
    super.dispose();
  }

  double get _customerCarpetArea {
    final l = double.tryParse(_carpetLengthCalc.text.trim()) ?? 0.0;
    final w = double.tryParse(_carpetWidthCalc.text.trim()) ?? 0.0;
    return l * w;
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final activeWash = state.activeTrackingBooking;
    final bays = state.bays;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    // Filter all bookings that are currently queued ahead or in-progress
    final queueAhead = state.bookings
        .where((b) => b.status != WashStatus.completed && b.status != WashStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('appName'),
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Promotional Rotating Banner
              ServicePromoBanner(
                onBookTap: () => _openBookingFlow(context, ServiceType.walkInStation),
              ),
              const SizedBox(height: 14),

              // 2. Privacy-Safe Queue Summary & Estimated Wait Time (No private vehicle details)
              _buildPrivacySafeQueueCard(context, state, queueAhead, bay1, bay2, van),
              const SizedBox(height: 14),

              // 3. Vehicle Owner Status / Privacy Search Lookup Card
              if (activeWash != null && activeWash.status.isOngoing)
                _buildActiveWashCard(context, state, activeWash)
              else
                _buildVehicleLookupCard(context, state),
              const SizedBox(height: 18),

              // 4. Primary Call to Action Cards (Drive-in vs At-Home Mobile)
              Text(
                state.tr('selectServiceMode'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 780;
                  final cards = [
                    _buildServiceActionCard(
                      context,
                      title: state.tr('driveInStation'),
                      subtitle: state.tr('driveInSub'),
                      badge: '${state.availableBaysCount} ${state.tr('availableNow')}',
                      isAvailable: state.availableBaysCount > 0,
                      imageUrl: AutoCareAssets.stationBayUrl,
                      fallbackIcon: Icons.local_car_wash_rounded,
                      color: AppColors.bay1Color,
                      actionLabel: state.tr('bookNow'),
                      onTap: () => _openBookingFlow(context, ServiceType.walkInStation),
                    ),
                    _buildServiceActionCard(
                      context,
                      title: state.tr('serviceValetPickUp'),
                      subtitle: state.tr('serviceValetPickUpSub'),
                      badge: state.tr('valetServiceAvailable'),
                      isAvailable: true,
                      imageUrl: AutoCareAssets.valetDriverUrl,
                      fallbackIcon: Icons.car_rental_rounded,
                      color: const Color(0xFF7C3AED),
                      actionLabel: state.tr('bookNow'),
                      onTap: () => _openBookingFlow(context, ServiceType.valetPickUp),
                    ),
                    _buildServiceActionCard(
                      context,
                      title: state.tr('atHomeMobile'),
                      subtitle: state.tr('atHomeSub'),
                      badge: state.isMobileVanAvailable ? state.tr('availableNow') : state.tr('busyWashing'),
                      isAvailable: state.isMobileVanAvailable,
                      imageUrl: AutoCareAssets.mobileVanUrl,
                      fallbackIcon: Icons.rv_hookup_rounded,
                      color: AppColors.mobileVanColor,
                      actionLabel: state.tr('bookNow'),
                      onTap: () => _openBookingFlow(context, ServiceType.atHomeMobile),
                    ),
                  ];

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: cards
                          .map((c) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: c,
                                ),
                              ))
                          .toList(),
                    );
                  } else {
                    return Column(
                      children: cards
                          .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: c,
                              ))
                          .toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              _buildPhoneBookingCard(context, state),
              const SizedBox(height: 12),
              _buildStationGpsTrackerCard(context, state),
              const SizedBox(height: 24),

              // Service Category Selector Toggle (Vehicle Wash vs Carpet Cleaning)
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
                          if (_isCarpetTabActive) {
                            setState(() => _isCarpetTabActive = false);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isCarpetTabActive ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_car_wash_rounded, size: 16, color: !_isCarpetTabActive ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  state.tr('servicePackages'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: !_isCarpetTabActive ? Colors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                          if (!_isCarpetTabActive) {
                            setState(() => _isCarpetTabActive = true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isCarpetTabActive ? const Color(0xFF6366F1) : Colors.transparent,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.texture_rounded, size: 16, color: _isCarpetTabActive ? Colors.white : AppColors.textPrimary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  state.tr('carpetService'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _isCarpetTabActive ? Colors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
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
              ),
              const SizedBox(height: 18),

              if (!_isCarpetTabActive) ...[
                // Vehicle Category Selector Segment
                _buildVehicleSelector(state),
                const SizedBox(height: 14),

                // Packages List with Itemized Services
                Column(
                  children: state.packages.map((pkg) => _buildPackageCard(context, state, pkg)).toList(),
                ),
              ] else ...[
                _buildCustomerCarpetCleaningSection(context, state),
              ],
              const SizedBox(height: 24),

              // Footer: Bishoftu Location
              _buildBishoftuLocationFooter(state),
            ],
          ),
        ),
      ),
    );
  }

  void _openBookingFlow(BuildContext context, ServiceType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NewBookingScreen(initialServiceType: type),
      ),
    );
  }

  Widget _buildCustomerCarpetCleaningSection(BuildContext context, dynamic state) {
    final rate = _customerCarpetType == 'type_b' ? state.carpetTypeBPricePerSqM as double : state.carpetTypeAPricePerSqM as double;
    final estimatedPrice = _customerCarpetArea * rate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF4338CA)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.texture_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr('carpetCleaningService'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      Text(
                        'Deep carpet shampooing, dust extraction, sanitization & quick drying',
                        style: const TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Two Types Selection
          Text(
            state.tr('carpetCleaningOptions'),
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _customerCarpetType = 'type_a'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _customerCarpetType == 'type_a' ? const Color(0xFF6366F1).withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _customerCarpetType == 'type_a' ? const Color(0xFF6366F1) : AppColors.cardBorder,
                        width: _customerCarpetType == 'type_a' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.cleaning_services_rounded, size: 18, color: _customerCarpetType == 'type_a' ? const Color(0xFF6366F1) : AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                state.tr('carpetTypeA'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _customerCarpetType == 'type_a' ? const Color(0xFF6366F1) : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.carpetTypeAPricePerSqM.toStringAsFixed(0)} ETB / m²',
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
                  onTap: () => setState(() => _customerCarpetType = 'type_b'),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _customerCarpetType == 'type_b' ? const Color(0xFFDC2626).withOpacity(0.08) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _customerCarpetType == 'type_b' ? const Color(0xFFDC2626) : AppColors.cardBorder,
                        width: _customerCarpetType == 'type_b' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 18, color: _customerCarpetType == 'type_b' ? const Color(0xFFDC2626) : AppColors.textPrimary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                state.tr('carpetTypeB'),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _customerCarpetType == 'type_b' ? const Color(0xFFDC2626) : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${state.carpetTypeBPricePerSqM.toStringAsFixed(0)} ETB / m²',
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

          // Area Calculator
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
                Text(
                  state.tr('carpetDimensionsTitle'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _carpetLengthCalc,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: '${state.tr("carpetLength")} (m)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          fillColor: Colors.white,
                          filled: true,
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
                        controller: _carpetWidthCalc,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: '${state.tr("carpetWidth")} (m)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          fillColor: Colors.white,
                          filled: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${state.tr("carpetTotalArea")}: ${_customerCarpetArea.toStringAsFixed(1)} m²',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF4338CA)),
                      ),
                      Text(
                        'ETB ${estimatedPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Color(0xFF312E81)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3 Provision options note
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Chip(
                avatar: const Icon(Icons.storefront_rounded, size: 14, color: AppColors.primary),
                label: Text(state.tr('atStationService'), style: const TextStyle(fontSize: 11)),
                backgroundColor: AppColors.surfaceVariant,
              ),
              Chip(
                avatar: const Icon(Icons.home_repair_service_rounded, size: 14, color: AppColors.primary),
                label: Text(state.tr('atHomeService'), style: const TextStyle(fontSize: 11)),
                backgroundColor: AppColors.surfaceVariant,
              ),
              Chip(
                avatar: const Icon(Icons.delivery_dining_rounded, size: 14, color: Color(0xFF7C3AED)),
                label: Text(state.tr('valetPickupReturn'), style: const TextStyle(fontSize: 11)),
                backgroundColor: AppColors.surfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Action button to book carpet cleaning
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NewBookingScreen(
                      isCarpet: true,
                      initialCarpetType: _customerCarpetType,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.bookmark_add_rounded, size: 20),
              label: Text(
                '${state.tr("bookCarpetCleaning")} • ${CurrencyFormatter.format(estimatedPrice)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Privacy-Safe Queue & Total Estimated Start Time Card
  /// Does NOT expose other customers' license plates, names, or phone numbers.
  Widget _buildPrivacySafeQueueCard(
    BuildContext context,
    dynamic state,
    List<WashBooking> queueAhead,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
  ) {
    final stationBookings = queueAhead.where((b) => b.serviceType == ServiceType.walkInStation).toList();
    final mobileBookings = queueAhead.where((b) => b.serviceType == ServiceType.atHomeMobile).toList();

    final stationWaitMins = WashDispatcher.estimateStationWaitMinutes(
      availableBaysCount: state.availableBaysCount,
      queue: stationBookings,
    );
    final mobileWaitMins = WashDispatcher.estimateMobileVanWaitMinutes(
      isVanAvailable: state.isMobileVanAvailable,
      queue: mobileBookings,
    );

    final totalCarsAhead = queueAhead.length;
    final totalStationCarsAhead = stationBookings.length;
    final totalMobileCarsAhead = mobileBookings.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Live Turnaround & Queue Status',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            totalCarsAhead == 0
                                ? state.tr('noQueueImmediate')
                                : '$totalCarsAhead ${state.tr("vehiclesAhead")}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_outlined, size: 11, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text(
                      state.tr('liveQueue'),
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Two Service ETA Cards (Station 2-Bays & Mobile 1-Van)
          Row(
            children: [
              // Drive-In Station (2 Bays)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: stationWaitMins == 0
                        ? AppColors.statusReady.withOpacity(0.06)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: stationWaitMins == 0
                          ? AppColors.statusReady.withOpacity(0.4)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              state.tr('stationBaysTitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          Icon(
                            Icons.local_car_wash_rounded,
                            size: 14,
                            color: stationWaitMins == 0 ? AppColors.statusReady : AppColors.bay1Color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stationWaitMins == 0 ? state.tr('readyNow') : '~$stationWaitMins ${state.tr('minWait')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: stationWaitMins == 0 ? AppColors.statusReady : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$totalStationCarsAhead ${state.tr('carsAhead')} • ${state.availableBaysCount}/2 ${state.tr('baysOpen')}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Mobile Van (1 Van)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: mobileWaitMins == 0
                        ? AppColors.statusReady.withOpacity(0.06)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: mobileWaitMins == 0
                          ? AppColors.statusReady.withOpacity(0.4)
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              state.tr('mobileVanTitle'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                          Icon(
                            Icons.rv_hookup_rounded,
                            size: 14,
                            color: mobileWaitMins == 0 ? AppColors.statusReady : AppColors.mobileVanColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mobileWaitMins == 0 ? state.tr('vanReady') : '~$mobileWaitMins ${state.tr('minWait')}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: mobileWaitMins == 0 ? AppColors.statusReady : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$totalMobileCarsAhead ${state.tr('carsAhead')} • ${state.tr('doorstepService')}',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleLookupCard(BuildContext context, dynamic state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr('trackMyCar'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('trackVehiclePrompt'),
                      style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _trackController,
                    textCapitalization: TextCapitalization.characters,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: state.tr('plateOrPhoneHint'),
                      hintStyle: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.directions_car_outlined, size: 18, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.cardBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                      fillColor: AppColors.surfaceVariant,
                      filled: true,
                    ),
                    onSubmitted: (_) => _handleTrackVehicle(context, state),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 42,
                child: ElevatedButton.icon(
                  onPressed: () => _handleTrackVehicle(context, state),
                  icon: const Icon(Icons.radar_rounded, size: 16),
                  label: Text(state.tr('trackNow'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleTrackVehicle(BuildContext context, dynamic state) {
    final query = _trackController.text.trim();
    if (query.isEmpty) return;
    final found = state.findBookingByPhoneOrPlate(query);
    if (found != null) {
      state.setActiveTrackingBooking(found.id);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: found.id)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.primaryDark,
          content: Text(state.tr('noActiveWashFound')),
        ),
      );
    }
  }

  String _getPackageImageUrl(WashPackage pkg) => AutoCareAssets.getPackageImage(pkg);

  String _getCarTypeImageUrl(CarType type) => AutoCareAssets.getCarTypeImage(type);

  Widget _buildServiceActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required bool isAvailable,
    required String imageUrl,
    required IconData fallbackIcon,
    required Color color,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAvailable ? color.withOpacity(0.35) : AppColors.cardBorder, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Stack(
                children: [
                  Image.network(
                    imageUrl,
                    height: 80,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: color.withOpacity(0.12),
                      child: Center(child: Icon(fallbackIcon, color: color, size: 28)),
                    ),
                  ),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.1), Colors.black.withOpacity(0.65)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isAvailable ? AppColors.statusReady : AppColors.statusWashing,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        actionLabel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: color),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelector(dynamic state) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: CarType.values.map((type) {
          final isSelected = type == _previewCarType;

          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _previewCarType = type),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoCareAssets.buildPhotoThumbnail(
                      imageUrl: _getCarTypeImageUrl(type),
                      width: 48,
                      height: 32,
                      borderRadius: 12,
                      fallbackIcon: type.icon,
                      fallbackColor: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.localizedName(state.currentLang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPackageCard(BuildContext context, dynamic state, WashPackage pkg) {
    final packages = state.packages as List<WashPackage>;
    final activeId = _selectedPackageId ?? (packages.isNotEmpty ? packages.first.id : null);
    final isSelected = pkg.id == activeId;
    final price = pkg.getPriceFor(_previewCarType);
    final photoUrl = _getPackageImageUrl(pkg);

    return GestureDetector(
      onTap: () => setState(() => _selectedPackageId = pkg.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.primary.withOpacity(0.08) : Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: photoUrl,
                  width: 58,
                  height: 58,
                  borderRadius: 12,
                  fallbackIcon: Icons.local_car_wash_rounded,
                  durationBadge: '${pkg.durationMinutes}m',
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pkg.localizedName(state.currentLang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Text(
                                '~${pkg.durationMinutes} ${state.tr("minWait")}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(price),
                      style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                    ),
                    Icon(
                      isSelected ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                    ),
                  ],
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 10),
              Text(
                pkg.localizedDescription(state.currentLang),
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
              if (pkg.features.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: pkg.localizedFeatures(state.currentLang).map((feature) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.statusCompleted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                feature,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.25),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 38,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(state.tr('bookThisWash'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NewBookingScreen(
                          initialPackage: pkg,
                          initialCarType: _previewCarType,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWashCard(BuildContext context, dynamic state, WashBooking wash) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: wash.status.color.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: wash.status.color.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: wash.status.color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.radar_rounded, size: 16, color: wash.status.color),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${state.tr("activeWashTitle")}: ${wash.licensePlate}',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                ],
              ),
              StatusBadge(
                label: wash.status.localizedName(state.currentLang),
                color: wash.status.color,
                isSmall: true,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${wash.package.localizedName(state.currentLang)} • ${wash.carType.localizedName(state.currentLang)} • ${wash.assignedWasherName != null ? "${state.tr('washer')}: ${wash.assignedWasherName}" : state.tr("pending")}',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          // Animated Wash Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: wash.status == WashStatus.completed || wash.status == WashStatus.readyForPickup
                  ? 1.0
                  : (wash.status == WashStatus.drying
                      ? 0.85
                      : (wash.status == WashStatus.washing ? 0.60 : 0.25)),
              backgroundColor: AppColors.background,
              valueColor: AlwaysStoppedAnimation<Color>(wash.status.color),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  _trackController.clear();
                  state.clearActiveTrackingBooking();
                },
                child: Text(
                  state.tr('trackAnother'),
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: wash.id)),
                  );
                },
                child: Row(
                  children: [
                    Text(
                      state.tr('openFullTracker'),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: wash.status.color),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 13, color: wash.status.color),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneBookingCard(BuildContext context, dynamic state) {
    final phone = state.customerPhoneBookingNumber as String;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_forwarded_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr('phoneCallBooking'),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.tr('bookByPhoneSub')} ($phone)',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.call, size: 15),
            label: Text(phone, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling BISHE Gate Station: $phone...'),
                  duration: const Duration(seconds: 3),
                ),
              );
              UrlLauncherHelper.openUrl('tel:$phone');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStationGpsTrackerCard(BuildContext context, dynamic state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusPending.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          final infoRow = Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, color: AppColors.statusPending, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            state.tr('locateBisheStation'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                          child: const Text('GPS', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.green)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Bishoftu (Debre Zeyit) • Auto Care Station',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          );

          final mapsButton = ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.navigation_rounded, size: 14),
            label: Text(state.tr('openGoogleMaps'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
            onPressed: () => UrlLauncherHelper.openUrl(AppConstants.googleMapsLocationUrl),
          );

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoRow,
                const SizedBox(height: 10),
                mapsButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: infoRow),
              const SizedBox(width: 8),
              mapsButton,
            ],
          );
        },
      ),
    );
  }

  Widget _buildBishoftuLocationFooter(dynamic state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                state.tr('appName'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Location: ${state.tr("bishoftu")}\n'
            'Mobile Coverage: Lake Babogaya, Kuriftu, Kebele 01-05\n'
            'Phone: ${state.customerPhoneBookingNumber} • Working Hours: 7:00 AM - 8:00 PM',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
