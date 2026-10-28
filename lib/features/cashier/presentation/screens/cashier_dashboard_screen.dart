import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/domain/models/bay_station.dart';
import '../../../booking_service/domain/models/service_type.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_dispatcher.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import 'bank_deposit_dialog.dart';
import 'daily_closing_dialog.dart';
import 'payment_process_dialog.dart';
import 'phone_booking_dialog.dart';
import 'walk_in_registration_screen.dart';
import 'weekly_commission_report_dialog.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Pending, 2: In Service, 3: Unpaid, 4: Phone

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final bays = state.bays;
    final allBookings = state.bookings;
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    final bay1 = bays.firstWhere((b) => b.type == BayType.bay1, orElse: () => const StationBay(type: BayType.bay1));
    final bay2 = bays.firstWhere((b) => b.type == BayType.bay2, orElse: () => const StationBay(type: BayType.bay2));
    final van = bays.firstWhere((b) => b.type == BayType.mobileVan, orElse: () => const StationBay(type: BayType.mobileVan));

    final filteredBookings = _getFilteredBookings(allBookings);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('cashierTitle'),
      ),
      floatingActionButton: isMobile
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'fab_phone_intake',
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  tooltip: state.tr('registerPhoneBooking'),
                  onPressed: () => PhoneBookingDialog.show(context),
                  child: const Icon(Icons.phone_in_talk_rounded, size: 18),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.extended(
                  heroTag: 'fab_walk_in',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_road_rounded, size: 18),
                  label: Text(
                    state.tr('newWalkIn'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                  ),
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
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  heroTag: 'fab_phone_intake',
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: Text(
                    state.tr('registerPhoneBooking'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                  onPressed: () => PhoneBookingDialog.show(context),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.extended(
                  heroTag: 'fab_walk_in',
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_road_rounded, size: 18),
                  label: Text(
                    state.tr('newWalkIn'),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
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
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 28 : (isMobile ? 14 : 20),
            vertical: isMobile ? 12 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Shift KPI Stats
              _buildShiftSummaryBanner(state, isMobile),
              const SizedBox(height: 10),

              // 1.1 Payment Received by Channel & Cashier Actions (Deposit Cash & Confirm Closing)
              _buildFinancialActionToolbar(context, state, isMobile),
              const SizedBox(height: 14),

              // 2. Real-Time Capacity Quick Status Bar (Bay 1, Bay 2, Mobile Van 1)
              _buildCleanStationCapacityBar(context, state, bay1, bay2, van, isMobile),
              const SizedBox(height: 18),

              // 3. Queue Management Section OR Attendance Desk OR Wash History OR Financial Reports
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedFilterIndex == 5
                        ? '${state.tr("attendanceAndCommission")} (${state.presentWashersCount}/${state.totalWashersCount})'
                        : (_selectedFilterIndex == 6
                            ? state.tr("washHistory")
                            : (_selectedFilterIndex == 7
                                ? state.tr("closingAndFinancialReports")
                                : '${state.tr("queueAndVehicles")} (${filteredBookings.length})')),
                    style: TextStyle(
                      fontSize: isMobile ? 15.5 : 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Queue Filter Tabs (including Washer Attendance, Wash History & Financial Reports)
              _buildFilterChips(state),
              const SizedBox(height: 12),

              // Queue Items OR Washer Attendance & Commission Desk OR Wash History OR Financial Reports
              if (_selectedFilterIndex == 5)
                _buildWasherAttendanceAndCommissionSection(context, state, isMobile)
              else if (_selectedFilterIndex == 6)
                const VehicleHistoryScreen(isEmbedded: true)
              else if (_selectedFilterIndex == 7)
                const FinancialReportsView(isEmbedded: true)
              else if (filteredBookings.isEmpty)
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
                ...filteredBookings.map((b) => isMobile
                    ? _buildCleanQueueRowMobile(context, state, b)
                    : _buildCleanQueueRowDesktop(context, state, b)),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShiftSummaryBanner(dynamic state, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
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
              isMobile: isMobile,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('digitalPay'),
              CurrencyFormatter.formatShort(state.totalDigitalRevenueETB),
              state.tr('digitalPayments'),
              AppColors.telebirrBlue,
              isMobile: isMobile,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('cashCollected'),
              CurrencyFormatter.formatShort(state.totalCashRevenueETB),
              state.tr('atFrontDesk'),
              AppColors.cashGreen,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIColumn(String title, String value, String sub, Color color, {bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 10.5 : 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(fontSize: isMobile ? 15 : 17, fontWeight: FontWeight.w900, color: color),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 9.5 : 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFinancialActionToolbar(BuildContext context, dynamic state, bool isMobile) {
    final methodRevenue = state.getRevenueByPaymentMethod() as Map<PaymentMethod, double>;
    final methodCounts = state.getTransactionCountByPaymentMethod() as Map<PaymentMethod, int>;
    final undepositedCash = state.undepositedCashTodayETB as double;
    final isClosed = state.isTodayClosed as bool;

    final channels = [
      (method: PaymentMethod.cash, label: 'Cash Gate', color: AppColors.cashGreen),
      (method: PaymentMethod.telebirr, label: 'Telebirr', color: AppColors.telebirrBlue),
      (method: PaymentMethod.cbeBirr, label: 'CBE Birr', color: AppColors.cbeBirrPurple),
      (method: PaymentMethod.bankOfAbyssinia, label: 'BoA', color: const Color(0xFFF59E0B)),
      (method: PaymentMethod.awashBank, label: 'Awash Bank', color: const Color(0xFFEA580C)),
      (method: PaymentMethod.dashenBank, label: 'Dashen Bank', color: const Color(0xFF0284C7)),
      (method: PaymentMethod.otherBankTransfer, label: 'Other Bank', color: Colors.indigo),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Fast Action Buttons: Deposit Cash & Confirm Daily Closing
          Row(
            children: [
              // Deposit Cash Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => BankDepositDialog.show(context),
                  icon: const Icon(Icons.account_balance_rounded, size: 16),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Deposit Cash to Bank',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                      Text(
                        '${CurrencyFormatter.formatShort(undepositedCash)} awaiting deposit',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Confirm Daily Closing Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => DailyClosingDialog.show(context),
                  icon: Icon(isClosed ? Icons.verified_rounded : Icons.fact_check_rounded, size: 16),
                  label: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isClosed ? 'Daily Closing Confirmed' : 'Confirm Daily Closing',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                      ),
                      Text(
                        isClosed ? 'Shift locked ✓' : 'Reconcile register & commission',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                      ),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClosed ? AppColors.statusCompleted : AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Clear breakdown pills of money received by each provider
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: channels.map((c) {
                final amt = methodRevenue[c.method] ?? 0.0;
                final cnt = methodCounts[c.method] ?? 0;
                final hasPayments = amt > 0;

                return Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: hasPayments ? c.color.withOpacity(0.08) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasPayments ? c.color.withOpacity(0.3) : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(c.method.icon, size: 13, color: hasPayments ? c.color : AppColors.textSecondary),
                      const SizedBox(width: 5),
                      Text(
                        '${c.label}: ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: hasPayments ? c.color : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '${CurrencyFormatter.formatShort(amt)} ($cnt)',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: hasPayments ? AppColors.textPrimary : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Mobile Queue Row: Stacked cards with generous touch targets and no horizontal overflows.
  Widget _buildCleanQueueRowMobile(BuildContext context, dynamic state, WashBooking b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Avatar, License plate, car type pill, phone badge, status pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: b.status.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_car_wash_rounded, color: b.status.color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                b.licensePlate,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  b.carType.displayName,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
              if (b.isPhoneBooking) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.phone_in_talk, size: 10, color: AppColors.primary),
                      SizedBox(width: 2),
                      Text('Phone', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              // Status Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: b.status.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  b.status.displayName,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: b.status.color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Details Row: Package name, customer & price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${b.package.name}${b.customerName != null && b.customerName!.isNotEmpty ? " • ${b.customerName}" : ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                CurrencyFormatter.format(b.totalPrice),
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ],
          ),

          // Location / GPS if mobile van
          if (b.serviceType == ServiceType.atHomeMobile) ...[
            const SizedBox(height: 6),
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
                        const Icon(Icons.map, size: 11, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          state.tr('openInMaps'),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),

          // Full-width action button
          _buildActionButtonsMobile(context, state, b),
        ],
      ),
    );
  }

  Widget _buildActionButtonsMobile(BuildContext context, dynamic state, WashBooking b) {
    if (b.status == WashStatus.pending || b.status == WashStatus.assignedToBay || b.status == WashStatus.confirmed) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 16),
          label: Text(state.tr('startWashAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.washing),
        ),
      );
    } else if (b.status == WashStatus.washing) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bay1Color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.air_rounded, size: 16),
          label: Text(state.tr('moveToDryingAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.drying),
        ),
      );
    } else if (b.status == WashStatus.drying) {
      return SizedBox(
        width: double.infinity,
        height: 38,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.bay2Color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
          label: Text(state.tr('markCompletedAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.completed),
        ),
      );
    } else if ((b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && !b.payment.isPaid) {
      final payLabel = state.currentLang == 'EN'
          ? 'Pay 💰 (${CurrencyFormatter.format(b.totalPrice)})'
          : '${state.tr("collectPaymentAction")} (${CurrencyFormatter.format(b.totalPrice)})';

      return SizedBox(
        width: double.infinity,
        height: 40,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cashGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          icon: const Icon(Icons.payments_rounded, size: 16),
          label: Text(
            payLabel,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
          ),
          onPressed: () => PaymentProcessDialog.show(context, b),
        ),
      );
    } else if (b.payment.isPaid) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.statusCompleted.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.statusCompleted.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 14, color: AppColors.statusCompleted),
            const SizedBox(width: 6),
            Text(
              'SETTLED & PAID (${b.payment.method.displayName})',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Tablet & Desktop Queue Row: Spacious horizontal layout
  Widget _buildCleanQueueRowDesktop(BuildContext context, dynamic state, WashBooking b) {
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
          if (b.status == WashStatus.pending || b.status == WashStatus.assignedToBay || b.status == WashStatus.confirmed) ...[
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
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.washing),
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
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.drying),
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
              onPressed: () => _advanceBookingStatus(context, b, targetStatus: WashStatus.completed),
            ),
          ],

          // 2. Strict Payment Lock: ONLY visible when status == completed AND unpaid!
          if ((b.status == WashStatus.completed || b.status == WashStatus.readyForPickup) && !b.payment.isPaid) ...[
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
                state.currentLang == 'EN'
                    ? 'Pay 💰 (${CurrencyFormatter.formatShort(b.totalPrice)})'
                    : '${state.tr("collectPaymentAction")} (${CurrencyFormatter.formatShort(b.totalPrice)})',
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
    UrlLauncherHelper.openUrl(mapUrl);
  }

  Widget _buildFilterChips(dynamic state) {
    final filters = [
      state.tr('filterAll'),
      state.tr('filterPending'),
      state.tr('filterInService'),
      state.tr('filterUnpaid'),
      state.tr('phoneCallBooking'),
      '${state.tr("attendanceDesk")} (${state.presentWashersCount}/${state.totalWashersCount})',
      state.tr('washHistory'),
      state.tr('closingAndFinancialReports'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = index == _selectedFilterIndex;
          Widget? avatar;
          if (index == 5) {
            avatar = Icon(
              Icons.how_to_reg_rounded,
              size: 15,
              color: isSelected ? Colors.white : AppColors.primary,
            );
          } else if (index == 6) {
            avatar = Icon(
              Icons.history_rounded,
              size: 15,
              color: isSelected ? Colors.white : AppColors.telebirrBlue,
            );
          } else if (index == 7) {
            avatar = Icon(
              Icons.fact_check_rounded,
              size: 15,
              color: isSelected ? Colors.white : AppColors.cashGreen,
            );
          }

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              avatar: avatar,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
              ),
              onSelected: (_) => setState(() => _selectedFilterIndex = index),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildWasherAttendanceAndCommissionSection(BuildContext context, dynamic state, bool isMobile) {
    final washers = state.availableWashers;
    final pool = state.teamCommissionPoolTodayETB as double;
    final dividends = state.washerDividendsToday as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Shifted Disburse Commission Pool Card (Managed by Cashier)
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.oromiaGold.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: AppColors.oromiaGold.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isMobile) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.oromiaGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('dailyWasherCommissionPool'),
                            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            '${state.presentWashersCount} of ${state.totalWashersCount} Washers on Duty • 15% Gross Pool',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
                      child: OutlinedButton.icon(
                        onPressed: () => WeeklyCommissionReportDialog.show(context),
                        icon: const Icon(Icons.assignment_turned_in_rounded, size: 14),
                        label: Text(
                          state.tr('reportWeeklyCommission'),
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: pool > 0
                            ? () => _showDisburseCommissionDialog(context, state, pool, state.presentWashersCount)
                            : null,
                        icon: const Icon(Icons.payments_rounded, size: 14),
                        label: Text(state.tr('disburseCommission'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.oromiaGold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('dailyWasherCommissionPool'),
                              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${state.presentWashersCount} of ${state.totalWashersCount} Washers on Duty • 15% Gross Pool',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => WeeklyCommissionReportDialog.show(context),
                          icon: const Icon(Icons.assignment_turned_in_rounded, size: 14),
                          label: Text(
                            state.tr('reportWeeklyCommission'),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: pool > 0
                              ? () => _showDisburseCommissionDialog(context, state, pool, state.presentWashersCount)
                              : null,
                          icon: const Icon(Icons.payments_rounded, size: 14),
                          label: Text(state.tr('disburseCommission'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // Pool ETB Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.oromiaGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.oromiaGold.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Earned Commission Pool Today:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      CurrencyFormatter.format(pool),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.oromiaGold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Absent washer protection notice
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.15)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: Colors.blue),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '100% of the commission pool is distributed strictly among washers on duty today. Absent washers receive 0 ETB, and their share is automatically redistributed proportionally to active washers.',
                        style: TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Dividends breakdown list
              if (dividends.isNotEmpty) ...[
                const Text(
                  'Individual 100% Pool Distribution:',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 6),
                ...dividends.values.map((div) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              div.isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 13,
                              color: div.isPresent ? AppColors.statusCompleted : Colors.red,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              div.washerName,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: div.isPresent ? FontWeight.w700 : FontWeight.w500,
                                color: div.isPresent ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                div.customTierName ?? '',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          div.isPresent
                              ? '${div.percentageShare.toStringAsFixed(1)}% • ${CurrencyFormatter.format(div.earnedETB)}'
                              : 'Absent (0 ETB)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: div.isPresent ? AppColors.oromiaGold : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),

        // 2. Attendance Overview Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
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
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_ind_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Washer Roster & Attendance',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Shift: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.statusCompleted,
                      side: const BorderSide(color: AppColors.statusCompleted),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Mark All Present', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                    onPressed: () {
                      state.markAllWashersPresent();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All washers marked present for today.'),
                          backgroundColor: AppColors.statusCompleted,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.statusCompleted.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.statusCompleted.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.statusCompleted, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${state.presentWashersCount} Present',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.statusCompleted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${state.totalWashersCount - state.presentWashersCount} Absent',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.groups_rounded, color: AppColors.textSecondary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${state.totalWashersCount} Total',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // List of Washers
        ...washers.map((w) {
          final isPresent = state.isWasherPresentToday(w.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPresent ? AppColors.statusCompleted.withOpacity(0.4) : Colors.red.withOpacity(0.3),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isPresent ? AppColors.statusCompleted.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                  child: Text(
                    w.name.isNotEmpty ? w.name[0] : 'W',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isPresent ? AppColors.statusCompleted : Colors.red,
                    ),
                  ),
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
                              w.name,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isPresent ? AppColors.statusCompleted.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              isPresent ? 'ON DUTY' : 'ABSENT',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: isPresent ? AppColors.statusCompleted : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Assigned Base: ${(w.commissionRate * 100).toStringAsFixed(1)}% • ${w.phone}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isPresent,
                  activeColor: AppColors.statusCompleted,
                  onChanged: (val) {
                    state.setWasherAttendance(w.id, val);
                  },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showDisburseCommissionDialog(BuildContext context, dynamic state, double pool, int washerCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 24),
            const SizedBox(width: 8),
            const Text('Disburse Commission Pool', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Confirm distribution of ${CurrencyFormatter.format(pool)} team commission dividends among the $washerCount washer(s) on duty today according to their percentage share (summing to 100%)?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team commission pool recorded and distributed successfully!'),
                  backgroundColor: AppColors.statusReady,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Disbursement', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  List<WashBooking> _getFilteredBookings(List<WashBooking> bookings) {
    // Only vehicles that are NOT yet paid belong in the active station queue.
    // As soon as payment is confirmed, the vehicle vanishes from the queue and moves to Wash History.
    final activeQueue = bookings.where((b) => !b.payment.isPaid && b.status != WashStatus.cancelled).toList();

    switch (_selectedFilterIndex) {
      case 1:
        return activeQueue.where((b) => b.status == WashStatus.pending || b.assignedBay == null).toList();
      case 2:
        return activeQueue.where((b) => b.status.isOngoing).toList();
      case 3:
        return activeQueue.where((b) => !b.payment.isPaid).toList();
      case 4:
        return activeQueue.where((b) => b.isPhoneBooking).toList();
      default:
        return activeQueue;
    }
  }

  Widget _buildCleanStationCapacityBar(
    BuildContext context,
    dynamic state,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
    bool isMobile,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 12),
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
            child: _buildBayMiniIndicator(state.tr('bay1'), bay1.isVacant, state, isMobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('bay2'), bay2.isVacant, state, isMobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('mobileVan'), van.isVacant, state, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildBayMiniIndicator(String title, bool isFree, dynamic state, bool isMobile) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isMobile ? 10.5 : 11.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              isFree ? state.tr('availableNow') : state.tr('busyWashing'),
              style: TextStyle(
                fontSize: isMobile ? 9.5 : 10.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _advanceBookingStatus(
    BuildContext context,
    WashBooking booking, {
    WashStatus? targetStatus,
  }) async {
    final state = AppStateProvider.read(context);
    final next = targetStatus ?? (
      (booking.status == WashStatus.drying || booking.status == WashStatus.readyForPickup)
          ? WashStatus.completed
          : WashDispatcher.nextStatus(booking.status)
    );
    if (next == null) return;

    await state.updateWashStatus(booking.id, next);

    if (context.mounted) {
      final msg = next == WashStatus.completed
          ? '${booking.licensePlate} marked completed! Ready for payment 💰'
          : '${booking.licensePlate} updated to ${next.displayName}!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 2),
          backgroundColor: next == WashStatus.completed ? AppColors.cashGreen : next.color,
          content: Text(msg),
        ),
      );
    }
  }
}
