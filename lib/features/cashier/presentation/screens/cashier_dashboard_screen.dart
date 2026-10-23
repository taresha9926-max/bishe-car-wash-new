import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/state/app_state_notifier.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../widgets/active_queue_tile.dart';
import '../widgets/bay_live_status_card.dart';
import 'bay_assignment_modal.dart';
import 'payment_process_dialog.dart';
import 'walk_in_registration_screen.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedFilterIndex = 0; // 0: All Active, 1: Pending Bay, 2: In Service, 3: Unpaid

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final bays = state.bays;
    final allBookings = state.bookings;

    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    // Filter bookings
    final filteredBookings = _getFilteredBookings(allBookings);

    return Scaffold(
      appBar: const AppRoleHeader(
        title: 'Cashier Gate Desk',
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('Gate Walk-In Entry', style: TextStyle(fontWeight: FontWeight.w700)),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shift & Revenue KPI Cards
              _buildKPICounterSection(state),
              const SizedBox(height: 18),

              // Live Bay & Mobile Van Status Cards
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Live Bay & Van Monitor',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${state.availableBaysCount}/2 Station Bays Free',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bay 1
              BayLiveStatusCard(
                bay: bay1,
                currentWashStatus: _getBayWashStatus(bay1, allBookings),
                onAssignTap: () => _openAssignModalForBay(context, bay1.type, allBookings),
                onQuickAdvanceStatus: () => _advanceBayStatus(context, bay1, allBookings),
              ),
              const SizedBox(height: 10),

              // Bay 2
              BayLiveStatusCard(
                bay: bay2,
                currentWashStatus: _getBayWashStatus(bay2, allBookings),
                onAssignTap: () => _openAssignModalForBay(context, bay2.type, allBookings),
                onQuickAdvanceStatus: () => _advanceBayStatus(context, bay2, allBookings),
              ),
              const SizedBox(height: 10),

              // Mobile Van 1
              BayLiveStatusCard(
                bay: van,
                currentWashStatus: _getBayWashStatus(van, allBookings),
                onAssignTap: () => _openAssignModalForBay(context, van.type, allBookings),
                onQuickAdvanceStatus: () => _advanceBayStatus(context, van, allBookings),
              ),
              const SizedBox(height: 24),

              // Active Queue & Management Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Queue & Gate Registrations',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${filteredBookings.length} Vehicles',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Filter Tabs
              _buildFilterChips(),
              const SizedBox(height: 14),

              // Booking List
              if (filteredBookings.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.check_circle_outline, size: 40, color: AppColors.statusReady),
                      const SizedBox(height: 8),
                      const Text(
                        'No cars in this queue segment',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Use "Gate Walk-In Entry" to register new arrivals.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              else
                ...filteredBookings.map((b) {
                  return ActiveQueueTile(
                    booking: b,
                    onAssignBayWasher: () => BayAssignmentModal.show(context, b),
                    onProcessPayment: () => PaymentProcessDialog.show(context, b),
                    onUpdateStatus: () => _advanceBookingStatus(context, b),
                  );
                }),

              const SizedBox(height: 70), // Spacing for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKPICounterSection(AppStateNotifier state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildKPIBox(
                  title: 'TODAY REVENUE',
                  value: CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
                  subvalue: '${state.totalCompletedCarsToday} cars washed',
                  color: AppColors.primary,
                  icon: Icons.payments_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildKPIBox(
                  title: 'ACTIVE QUEUE',
                  value: '${state.activeQueueCount} Cars',
                  subvalue: '${state.availableBaysCount} bays vacant',
                  color: AppColors.secondary,
                  icon: Icons.car_repair_rounded,
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPaymentSplitBadge(
                label: 'Cash Desk',
                amount: state.totalCashRevenueETB,
                color: AppColors.cashGreen,
                icon: Icons.money_rounded,
              ),
              Container(width: 1, height: 24, color: AppColors.cardBorder),
              _buildPaymentSplitBadge(
                label: 'Digital (Telebirr/CBE)',
                amount: state.totalDigitalRevenueETB,
                color: AppColors.telebirrBlue,
                icon: Icons.phone_android_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKPIBox({
    required String title,
    required String value,
    required String subvalue,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
              Icon(icon, size: 16, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color),
          ),
          Text(subvalue, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildPaymentSplitBadge({
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
            Text(
              CurrencyFormatter.formatShort(amount),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
      ],
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
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surfaceVariant,
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
      case 1: // Pending Bay
        return bookings.where((b) => b.status == WashStatus.pending || b.assignedBay == null).toList();
      case 2: // In Service
        return bookings.where((b) => b.status.isOngoing).toList();
      case 3: // Unpaid Only
        return bookings.where((b) => !b.payment.isPaid).toList();
      default: // All Active
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
    // Find first unassigned or pending booking
    try {
      final unassigned = bookings.firstWhere(
        (b) => b.assignedBay == null || b.status == WashStatus.pending,
      );
      BayAssignmentModal.show(context, unassigned);
    } catch (_) {
      // If no unassigned exists, open walk-in registration with preselected bay!
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
