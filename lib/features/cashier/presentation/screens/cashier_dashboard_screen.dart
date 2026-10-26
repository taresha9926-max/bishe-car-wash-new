import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_dispatcher.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'bay_assignment_modal.dart';
import 'payment_process_dialog.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road_rounded),
        label: Text(state.tr('newWalkIn'), style: const TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const WalkInRegistrationScreen(),
            ),
          );
        },
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

              // 2. Real-Time Capacity Quick Status Bar
              _buildCleanStationCapacityBar(context, state, bay1, bay2, van),
              const SizedBox(height: 20),

              // 3. Physical Station Bays & Mobile Van Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.tr('activeWashingBays'),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${state.availableBaysCount}/2 ${state.tr("availableNow")}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Responsive Bay Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 750;
                  if (isWide) {
                    return Row(
                      children: [
                        Expanded(child: _buildBayCard(context, state, bay1, allBookings)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBayCard(context, state, bay2, allBookings)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBayCard(context, state, van, allBookings)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildBayCard(context, state, bay1, allBookings),
                      const SizedBox(height: 10),
                      _buildBayCard(context, state, bay2, allBookings),
                      const SizedBox(height: 10),
                      _buildBayCard(context, state, van, allBookings),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // 3. Queue Management Section
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

  Widget _buildBayCard(BuildContext context, dynamic state, StationBay bay, List<WashBooking> bookings) {
    final isOccupied = bay.status == BayStatus.occupied;
    final currentStatus = _getBayWashStatus(bay, bookings);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOccupied ? AppColors.bay1Color.withOpacity(0.4) : AppColors.cardBorder,
          width: isOccupied ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bay.type.displayName,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOccupied ? AppColors.statusWashing.withOpacity(0.12) : AppColors.statusReady.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOccupied ? (currentStatus?.displayName ?? state.tr('filterInService')) : state.tr('availableNow'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isOccupied ? AppColors.statusWashing : AppColors.statusReady,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isOccupied ? 'Vehicle: ${bay.activeLicensePlate ?? "Ongoing"}' : 'Open for next drive-in car',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isOccupied ? FontWeight.w800 : FontWeight.w500,
              color: isOccupied ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
          if (isOccupied && bay.assignedWasherName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Washers: ${bay.assignedWasherName}',
              style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 14),

          // Direct Contextual Action Button
          SizedBox(
            width: double.infinity,
            height: 38,
            child: isOccupied
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                    label: Text(_getAdvanceLabel(state, currentStatus), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    onPressed: () => _advanceBayStatus(context, bay, bookings),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    label: Text(state.tr('assignVehicle'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                    onPressed: () => _openAssignModalForBay(context, bay.type, bookings),
                  ),
          ),
        ],
      ),
    );
  }

  String _getAdvanceLabel(dynamic state, WashStatus? status) {
    if (status == null) return 'Advance Wash';
    switch (status) {
      case WashStatus.pending:
      case WashStatus.confirmed:
        return state.tr('startWashing');
      case WashStatus.assignedToBay:
      case WashStatus.washing:
        return state.tr('setToDrying');
      case WashStatus.drying:
        return state.tr('markReady');
      case WashStatus.readyForPickup:
        return state.tr('completeArchive');
      default:
        return 'Advance Status';
    }
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
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${b.package.name} • ${CurrencyFormatter.format(b.totalPrice)} • ${b.assignedWasherName ?? "Unassigned"}',
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Payment button if unpaid
          if (!b.payment.isPaid) ...[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () => PaymentProcessDialog.show(context, b),
              child: Text(state.tr('payButton'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            ),
            const SizedBox(width: 6),
          ],

          // Quick advance
          IconButton(
            icon: const Icon(Icons.arrow_circle_right_rounded, color: AppColors.primary, size: 28),
            tooltip: state.tr('advanceStatus'),
            onPressed: () => _advanceBookingStatus(context, b),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(dynamic state) {
    final filters = [
      state.tr('filterAll'),
      state.tr('filterPending'),
      state.tr('filterInService'),
      state.tr('filterUnpaid'),
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
      default:
        return bookings.where((b) => b.status != WashStatus.cancelled).toList();
    }
  }

  WashStatus? _getBayWashStatus(StationBay bay, List<WashBooking> bookings) {
    return WashDispatcher.getBayWashStatus(bay, bookings);
  }

  void _openAssignModalForBay(BuildContext context, BayType bayType, List<WashBooking> bookings) {
    try {
      final unassigned = bookings.firstWhere(
        (b) => b.assignedBay == null || b.status == WashStatus.pending,
      );
      BayAssignmentModal.show(context, unassigned);
    } catch (_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WalkInRegistrationScreen(preselectedBay: bayType),
        ),
      );
    }
  }

  Future<void> _advanceBayStatus(BuildContext context, StationBay bay, List<WashBooking> bookings) async {
    final booking = WashDispatcher.findBookingForBay(bay, bookings);
    if (booking != null) {
      await _advanceBookingStatus(context, booking);
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
