import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_dispatcher.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'bay_assignment_modal.dart';
import 'payment_process_dialog.dart';
import 'phone_booking_dialog.dart';
import 'walk_in_registration_screen.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: In Service, 3: Unpaid

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final bays = state.bays;
    final allBookings = state.bookings;
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    final filteredBookings = _getFilteredBookings(allBookings);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('cashierTitle'),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'fab_phone_intake',
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
            label: Text(state.tr('registerPhoneBooking'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
            onPressed: () => PhoneBookingDialog.show(context),
          ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            heroTag: 'fab_walk_in',
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_road_rounded, size: 18),
            label: Text(state.tr('newWalkIn'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WalkInRegistrationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => state.loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 28 : 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Shift KPI Stats
              _buildShiftSummaryBanner(state),
              const SizedBox(height: 16),

              // 2. Real-Time Capacity Quick Status Bar (Bay 1, Bay 2, Mobile Van 1)
              _buildCleanStationCapacityBar(context, state, bay1, bay2, van),
              const SizedBox(height: 20),

              // 3. Queue Management Section (Bay cards removed for cleaner workflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.tr("queueAndVehicles")} (${filteredBookings.length})',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Queue Filter Tabs
              _buildFilterChips(state),
              const SizedBox(height: 12),

              // Queue Items
              if (filteredBookings.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: const Center(
                    child: Text(
                      'No vehicles in this queue filter.',
                      style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                ...filteredBookings.map((b) => _buildCleanQueueRow(context, state, b)),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftSummaryBanner(dynamic state) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            child: _buildKPIColumn(
              state.tr('todayRevenue'),
              CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
              '${state.totalCompletedCarsToday} ${state.tr("carsWashed")}',
              AppColors.primary,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('digitalPay'),
              CurrencyFormatter.formatShort(state.totalDigitalRevenueETB),
              state.tr('digitalPayments'),
              AppColors.telebirrBlue,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('cashCollected'),
              CurrencyFormatter.formatShort(state.totalCashRevenueETB),
              state.tr('atFrontDesk'),
              AppColors.cashGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIColumn(String title, String value, String sub, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildCleanQueueRow(BuildContext context, dynamic state, WashBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: b.status.color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.local_car_wash_rounded, color: b.status.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      b.licensePlate,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        b.carType.displayName,
                        style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                      ),
                    ),
                    if (b.isPhoneBooking) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone_in_talk, size: 11, color: AppColors.primary),
                            const SizedBox(width: 3),
                            Text(
                              state.tr('phoneCallBooking'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${b.package.name} • ${CurrencyFormatter.format(b.totalPrice)}${b.customerName != null && b.customerName!.isNotEmpty ? " • ${b.customerName}" : ""}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
                if (b.serviceType == ServiceType.atHomeMobile) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 13, color: AppColors.mobileVanColor),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          b.deliveryLocation ?? b.gpsCoordinates ?? "Bishoftu Mobile Van",
                          style: const TextStyle(fontSize: 11, color: AppColors.mobileVanColor, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () => _openMapLocation(context, b),
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map, size: 12, color: AppColors.primary),
                              const SizedBox(width: 3),
                              Text(
                                state.tr('openInMaps'),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // 1. Readable Status Advancement Action Button
          if (b.status == WashStatus.pending || b.status == WashStatus.assignedToBay) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 14),
              label: Text(state.tr('startWashAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
              onPressed: () => _advanceBookingStatus(context, b),
            ),
          ] else if (b.status == WashStatus.washing) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bay1Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.air_rounded, size: 14),
              label: Text(state.tr('moveToDryingAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
              onPressed: () => _advanceBookingStatus(context, b),
            ),
          ] else if (b.status == WashStatus.drying) ...[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.bay2Color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 14),
              label: Text(state.tr('markCompletedAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
              onPressed: () => _advanceBookingStatus(context, b),
            ),
          ],

          // 2. Strict Payment Lock: ONLY visible when status == completed AND unpaid!
          if (b.status == WashStatus.completed && !b.payment.isPaid) ...[
            const SizedBox(width: 6),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              icon: const Icon(Icons.payments_rounded, size: 14),
              label: Text(
                '${state.tr("collectPaymentAction")} (${CurrencyFormatter.formatShort(b.totalPrice)})',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
              ),
              onPressed: () => PaymentProcessDialog.show(context, b),
            ),
          ] else if (b.payment.isPaid) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusCompleted.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.statusCompleted.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 12, color: AppColors.statusCompleted),
                  const SizedBox(width: 4),
                  Text(
                    'PAID (${b.payment.method.displayName})',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openMapLocation(BuildContext context, WashBooking b) {
    final query = b.gpsCoordinates ?? b.deliveryLocation ?? "Bishoftu, Ethiopia";
    final mapUrl = "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}";
    if (kIsWeb) {
      try {
        html.window.open(mapUrl, '_blank');
        return;
      } catch (_) {}
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('GPS: $query'),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildFilterChips(dynamic state) {
    final filters = [
      state.tr('filterAll'),
      state.tr('filterPending'),
      state.tr('filterInService'),
      state.tr('filterUnpaid'),
      state.tr('phoneCallBooking'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = index == _selectedFilterIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filters[index],
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedFilterIndex = index),
            ),
          );
        }),
      ),
    );
  }

  List<WashBooking> _getFilteredBookings(List<WashBooking> bookings) {
    switch (_selectedFilterIndex) {
      case 1:
        return bookings.where((b) => b.status == WashStatus.pending || b.assignedBay == null).toList();
      case 2:
        return bookings.where((b) => b.status.isOngoing).toList();
      case 3:
        return bookings.where((b) => !b.payment.isPaid).toList();
      case 4:
        return bookings.where((b) => b.isPhoneBooking).toList();
      default:
        return bookings.where((b) => b.status != WashStatus.cancelled).toList();
    }
  }

  Widget _buildCleanStationCapacityBar(
    BuildContext context,
    dynamic state,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            child: _buildBayMiniIndicator(state.tr('bay1'), bay1.isVacant, state),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('bay2'), bay2.isVacant, state),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('mobileVan'), van.isVacant, state),
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

  Future<void> _advanceBookingStatus(BuildContext context, WashBooking booking) async {
    final state = AppStateProvider.read(context);
    final next = WashDispatcher.nextStatus(booking.status);
    if (next == null) return;

    await state.updateWashStatus(booking.id, next);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: next.color,
          content: Text('${booking.licensePlate} updated to ${next.displayName}!'),
        ),
      );
    }
  }
}
