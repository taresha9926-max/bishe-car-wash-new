import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
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
      appBar: const AppRoleHeader(
        title: 'Cashier Station Operations',
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('New Walk-In Entry', style: TextStyle(fontWeight: FontWeight.w800)),
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
              const SizedBox(height: 20),

              // 2. Physical Station Bays & Mobile Van Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Active Washing Bays',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${state.availableBaysCount}/2 Bays Available',
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
                        Expanded(child: _buildBayCard(context, bay1, allBookings)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBayCard(context, bay2, allBookings)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildBayCard(context, van, allBookings)),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      _buildBayCard(context, bay1, allBookings),
                      const SizedBox(height: 10),
                      _buildBayCard(context, bay2, allBookings),
                      const SizedBox(height: 10),
                      _buildBayCard(context, van, allBookings),
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
                    'Queue & Vehicles (${filteredBookings.length})',
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
              _buildFilterChips(),
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
                ...filteredBookings.map((b) => _buildCleanQueueRow(context, b)),

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
              'Today Revenue',
              CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
              '${state.totalCompletedCarsToday} cars washed',
              AppColors.primary,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              'Telebirr / CBE',
              CurrencyFormatter.formatShort(state.digitalRevenueETB),
              'Digital payments',
              AppColors.telebirrBlue,
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              'Cash Collected',
              CurrencyFormatter.formatShort(state.cashRevenueETB),
              'At front desk',
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

  Widget _buildBayCard(BuildContext context, StationBay bay, List<WashBooking> bookings) {
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
                  isOccupied ? (currentStatus?.displayName ?? 'In Service') : 'Available',
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
                    label: Text(_getAdvanceLabel(currentStatus), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    onPressed: () => _advanceBayStatus(context, bay, bookings),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                    label: const Text('Assign Vehicle', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.primary)),
                    onPressed: () => _openAssignModalForBay(context, bay.type, bookings),
                  ),
          ),
        ],
      ),
    );
  }

  String _getAdvanceLabel(WashStatus? status) {
    if (status == null) return 'Advance Wash';
    switch (status) {
      case WashStatus.pending:
      case WashStatus.confirmed:
        return 'Start Washing';
      case WashStatus.assignedToBay:
      case WashStatus.washing:
        return 'Set to Drying';
      case WashStatus.drying:
        return 'Mark Ready for Pickup';
      case WashStatus.readyForPickup:
        return 'Complete & Archive';
      default:
        return 'Advance Status';
    }
  }

  Widget _buildCleanQueueRow(BuildContext context, WashBooking b) {
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
              child: const Text('Pay', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
            ),
            const SizedBox(width: 6),
          ],

          // Quick advance
          IconButton(
            icon: const Icon(Icons.arrow_circle_right_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Advance Status',
            onPressed: () => _advanceBookingStatus(context, b),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All Active', 'Pending Bay', 'In Service', 'Unpaid Only'];

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
    if (bay.activeBookingId == null) return null;
    try {
      return bookings.firstWhere((b) => b.id == bay.activeBookingId).status;
    } catch (_) {
      return null;
    }
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
    if (bay.activeBookingId == null) return;
    try {
      final booking = bookings.firstWhere((b) => b.id == bay.activeBookingId);
      await _advanceBookingStatus(context, booking);
    } catch (_) {}
  }

  Future<void> _advanceBookingStatus(BuildContext context, WashBooking booking) async {
    final state = AppStateProvider.read(context);
    final current = booking.status;
    WashStatus next;

    switch (current) {
      case WashStatus.pending:
      case WashStatus.confirmed:
        next = WashStatus.washing;
        break;
      case WashStatus.assignedToBay:
        next = WashStatus.washing;
        break;
      case WashStatus.washing:
        next = WashStatus.drying;
        break;
      case WashStatus.drying:
        next = WashStatus.readyForPickup;
        break;
      case WashStatus.readyForPickup:
        next = WashStatus.completed;
        break;
      case WashStatus.completed:
        return;
      default:
        next = WashStatus.washing;
    }

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
