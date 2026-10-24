import 'dart:math';
import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/constants/app_constants.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/core/widgets/app_role_header.dart';
import 'package:bishe_car_wash/core/widgets/responsive_layout.dart';
import 'package:bishe_car_wash/core/widgets/service_promo_banner.dart';
import 'package:bishe_car_wash/core/widgets/status_badge.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_booking.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/booking_history_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/live_tracking_screen.dart';
import 'package:bishe_car_wash/features/customer/presentation/screens/new_booking_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  CarType _previewCarType = CarType.automobile;

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
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Promotional Rotating Banner
              ServicePromoBanner(
                onBookTap: () => _openBookingFlow(context, ServiceType.walkInStation),
              ),
              const SizedBox(height: 18),

              // 2. Real-Time Capacity (Bay 1, Bay 2, Mobile Van 1)
              _buildCleanStationCapacityBar(context, state, bay1, bay2, van),
              const SizedBox(height: 18),

              // 3. Privacy-Safe Queue Summary & Estimated Wait Time (No private vehicle details)
              _buildPrivacySafeQueueCard(context, state, queueAhead, bay1, bay2, van),
              const SizedBox(height: 20),

              // 4. Prominent Active Tracking Card (only for user's own active booking)
              if (activeWash != null && activeWash.status.isOngoing) ...[
                _buildActiveWashCard(context, state, activeWash),
                const SizedBox(height: 20),
              ],

              // 5. Primary Call to Action Cards (Drive-in vs At-Home Mobile)
              Text(
                state.tr('selectServiceMode'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildServiceActionCard(
                      context,
                      title: state.tr('driveInStation'),
                      subtitle: state.tr('driveInSub'),
                      badge: '${state.availableBaysCount} ${state.tr('availableNow')}',
                      isAvailable: state.availableBaysCount > 0,
                      icon: Icons.local_car_wash_rounded,
                      color: AppColors.bay1Color,
                      actionLabel: state.tr('bookNow'),
                      onTap: () => _openBookingFlow(context, ServiceType.walkInStation),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildServiceActionCard(
                      context,
                      title: state.tr('atHomeMobile'),
                      subtitle: state.tr('atHomeSub'),
                      badge: state.isMobileVanAvailable ? state.tr('availableNow') : state.tr('busyWashing'),
                      isAvailable: state.isMobileVanAvailable,
                      icon: Icons.rv_hookup_rounded,
                      color: AppColors.mobileVanColor,
                      actionLabel: state.tr('bookNow'),
                      onTap: () => _openBookingFlow(context, ServiceType.atHomeMobile),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 6. Vehicle Type Pricing Matrix Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('servicePackages'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingHistoryScreen()),
                      );
                    },
                    icon: const Icon(Icons.receipt_long_rounded, size: 16),
                    label: Text(state.tr('myHistory'), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Vehicle Category Selector Segment
              _buildVehicleSelector(state),
              const SizedBox(height: 14),

              // Packages Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final useGrid = constraints.maxWidth >= 720;
                  if (useGrid) {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.55,
                      ),
                      itemCount: state.packages.length,
                      itemBuilder: (ctx, i) => _buildPackageCard(context, state, state.packages[i]),
                    );
                  }
                  return Column(
                    children: state.packages.map((pkg) => _buildPackageCard(context, state, pkg)).toList(),
                  );
                },
              ),
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

  /// Calculates estimated start time for a newly booked car based on ongoing washes and available 2 station bays
  int _calculateStationWaitMinutes(dynamic state, List<WashBooking> stationQueue) {
    final freeStationBays = state.availableBaysCount;
    if (freeStationBays > 0 && stationQueue.isEmpty) {
      return 0; // Immediate entry
    }

    if (stationQueue.isEmpty) {
      return 0;
    }

    int totalRemainingMinutes = 0;
    for (final b in stationQueue) {
      final elapsed = DateTime.now().difference(b.createdAt).inMinutes;
      final pkgDuration = b.package.durationMinutes > 0 ? b.package.durationMinutes : 25;
      final remaining = max(5, pkgDuration - elapsed);
      totalRemainingMinutes += remaining;
    }

    // 2 Physical bays handle cars concurrently in parallel
    final effectiveWait = (totalRemainingMinutes / 2).ceil();
    return max(5, effectiveWait);
  }

  /// Calculates estimated start time for a newly booked at-home mobile van wash (1 mobile van unit)
  int _calculateMobileVanWaitMinutes(dynamic state, List<WashBooking> mobileQueue) {
    if (state.isMobileVanAvailable && mobileQueue.isEmpty) {
      return 0; // Mobile van is available immediately
    }

    if (mobileQueue.isEmpty) {
      return 0;
    }

    int totalMinutes = 0;
    for (final b in mobileQueue) {
      final elapsed = DateTime.now().difference(b.createdAt).inMinutes;
      final pkgDuration = b.package.durationMinutes > 0 ? b.package.durationMinutes : 40;
      final remaining = max(10, pkgDuration - elapsed);
      totalMinutes += remaining;
    }

    return max(15, totalMinutes);
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

    final stationWaitMins = _calculateStationWaitMinutes(state, stationBookings);
    final mobileWaitMins = _calculateMobileVanWaitMinutes(state, mobileBookings);

    final totalCarsAhead = queueAhead.length;
    final totalStationCarsAhead = stationBookings.length;
    final totalMobileCarsAhead = mobileBookings.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.speed_rounded, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Live Turnaround & Queue Status',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        totalCarsAhead == 0
                            ? 'No queue • Immediate service available'
                            : '$totalCarsAhead vehicle(s) currently ahead of you',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    const Text(
                      'Live Queue',
                      style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Two Service ETA Cards (Station 2-Bays & Mobile 1-Van)
          Row(
            children: [
              // Drive-In Station (2 Bays)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: stationWaitMins == 0
                        ? AppColors.statusReady.withOpacity(0.06)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
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
                          const Text(
                            'Station (2 Bays)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Icon(
                            Icons.local_car_wash_rounded,
                            size: 15,
                            color: stationWaitMins == 0 ? AppColors.statusReady : AppColors.bay1Color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stationWaitMins == 0 ? 'Ready Now' : '~$stationWaitMins min wait',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: stationWaitMins == 0 ? AppColors.statusReady : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalStationCarsAhead ahead • ${state.availableBaysCount}/2 bays open',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Mobile Van (1 Van)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: mobileWaitMins == 0
                        ? AppColors.statusReady.withOpacity(0.06)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
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
                          const Text(
                            'Mobile Van (1 Van)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          Icon(
                            Icons.rv_hookup_rounded,
                            size: 15,
                            color: mobileWaitMins == 0 ? AppColors.statusReady : AppColors.mobileVanColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mobileWaitMins == 0 ? 'Van Ready' : '~$mobileWaitMins min wait',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: mobileWaitMins == 0 ? AppColors.statusReady : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalMobileCarsAhead ahead • Doorstep service',
                        style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
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

  Widget _buildCleanStationCapacityBar(
    BuildContext context,
    dynamic state,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBayMiniIndicator('Bay 1', bay1.isVacant, state),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator('Bay 2', bay2.isVacant, state),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator('Mobile Van', van.isVacant, state),
          ),
        ],
      ),
    );
  }

  Widget _buildBayMiniIndicator(String title, bool isFree, dynamic state) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11.5, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            isFree ? state.tr('availableNow') : state.tr('busyWashing'),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String badge,
    required bool isAvailable,
    required IconData icon,
    required Color color,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isAvailable ? color.withOpacity(0.3) : AppColors.cardBorder, width: 1.5),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isAvailable ? AppColors.statusReady.withOpacity(0.12) : AppColors.statusWashing.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: isAvailable ? AppColors.statusReady : AppColors.statusWashing,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  actionLabel,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: color),
              ],
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
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      type.icon,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      type.localizedName(state.currentLang),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
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
    final price = pkg.getPriceFor(_previewCarType);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.localizedName(state.currentLang),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      pkg.localizedDescription(state.currentLang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(price),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                  ),
                  Text(
                    '~${pkg.durationMinutes} mins',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
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
              child: Text(state.tr('bookThisWash'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWashCard(BuildContext context, dynamic state, WashBooking wash) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
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
          const SizedBox(height: 12),
          Text(
            '${wash.package.localizedName(state.currentLang)} • ${wash.carType.localizedName(state.currentLang)} • Assigned: ${wash.assignedWasherName ?? "Queued"}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LiveTrackingScreen(bookingId: wash.id)),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  state.tr('openFullTracker'),
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: wash.status.color),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 14, color: wash.status.color),
              ],
            ),
          ),
        ],
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
            'Phone: +251 91 123 4567 • Working Hours: 7:00 AM - 8:00 PM',
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}
