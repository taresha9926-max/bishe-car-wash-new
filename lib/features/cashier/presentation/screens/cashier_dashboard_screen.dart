import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/unified_washer_roster_card.dart';
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
import 'petty_cash_dialog.dart';
import 'phone_booking_dialog.dart';
import 'walk_in_registration_screen.dart';

class CashierDashboardScreen extends StatefulWidget {
  const CashierDashboardScreen({super.key});

  @override
  State<CashierDashboardScreen> createState() => _CashierDashboardScreenState();
}

class _CashierDashboardScreenState extends State<CashierDashboardScreen> {
  int _selectedFilterIndex = 0; // 0: Queue & Vehicles, 1: Attendance Desk, 2: Wash History, 3: Closing & Financial Reports
  bool _isDigitalBreakdownExpanded = false;
  bool _isShiftKpiExpanded = false;
  bool _isActionsExpanded = false;

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
        title: state.activeStaffFullName != null && state.activeStaffFullName!.isNotEmpty
            ? '${state.tr("cashierTitle")} • ${state.activeStaffFullName}'
            : state.tr('cashierTitle'),
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
                    _selectedFilterIndex == 1
                        ? '${state.tr("attendanceAndCommission")} (${state.presentWashersCount}/${state.totalWashersCount})'
                        : (_selectedFilterIndex == 2
                            ? state.tr("washHistory")
                            : (_selectedFilterIndex == 3
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
              _buildFilterChips(state, isMobile),
              const SizedBox(height: 12),

              // Queue Items OR Washer Attendance & Commission Desk OR Wash History OR Financial Reports
              if (_selectedFilterIndex == 1)
                UnifiedWasherRosterCard(isMobile: isMobile)
              else if (_selectedFilterIndex == 2)
                const VehicleHistoryScreen(isEmbedded: true)
              else if (_selectedFilterIndex == 3)
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
    if (isMobile) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _isShiftKpiExpanded = !_isShiftKpiExpanded),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.secondary.withValues(alpha: 0.04),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('todayRevenue'),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                            ),
                            Row(
                              children: [
                                Text(
                                  CurrencyFormatter.formatShort(state.totalRevenueTodayETB),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.statusCompleted.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${state.totalCompletedCarsToday} ${state.tr("carsWashed")}',
                                    style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          _isShiftKpiExpanded ? 'Less' : 'Details',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          _isShiftKpiExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildKPIColumn(
                        state.tr('digitalPay'),
                        CurrencyFormatter.formatShort(state.totalDigitalRevenueETB),
                        state.tr('digitalPayments'),
                        AppColors.telebirrBlue,
                        isMobile: true,
                      ),
                    ),
                    Container(width: 1, height: 32, color: AppColors.cardBorder),
                    Expanded(
                      child: _buildKPIColumn(
                        state.tr('cashCollected'),
                        CurrencyFormatter.formatShort(state.totalCashRevenueETB),
                        state.tr('atFrontDesk'),
                        AppColors.cashGreen,
                        isMobile: true,
                      ),
                    ),
                    Container(width: 1, height: 32, color: AppColors.cardBorder),
                    Expanded(
                      child: _buildKPIColumn(
                        state.currentLang == 'OM' ? 'Komishiinii' : (state.currentLang == 'AM' ? 'ኮሚሽን' : 'Commission'),
                        CurrencyFormatter.formatShort(state.teamCommissionPoolTodayETB as double),
                        '${(state.teamCommissionRate * 100).toInt()}% Pool',
                        AppColors.oromiaGold,
                        isMobile: true,
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: _isShiftKpiExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
              isMobile: false,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('digitalPay'),
              CurrencyFormatter.formatShort(state.totalDigitalRevenueETB),
              state.tr('digitalPayments'),
              AppColors.telebirrBlue,
              isMobile: false,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.tr('cashCollected'),
              CurrencyFormatter.formatShort(state.totalCashRevenueETB),
              state.tr('atFrontDesk'),
              AppColors.cashGreen,
              isMobile: false,
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.cardBorder),
          Expanded(
            child: _buildKPIColumn(
              state.currentLang == 'OM' ? 'Komishiinii' : (state.currentLang == 'AM' ? 'ኮሚሽን' : 'Commission'),
              CurrencyFormatter.formatShort(state.teamCommissionPoolTodayETB as double),
              '${(state.teamCommissionRate * 100).toInt()}% Pool (${state.presentWashersCount} Duty)',
              AppColors.oromiaGold,
              isMobile: false,
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

    final cashRevenue = methodRevenue[PaymentMethod.cash] ?? 0.0;
    final cashCount = methodCounts[PaymentMethod.cash] ?? 0;

    final digitalProviders = [
      (method: PaymentMethod.telebirr, label: 'Telebirr', color: AppColors.telebirrBlue),
      (method: PaymentMethod.cbeBirr, label: 'CBE Birr', color: AppColors.cbeBirrPurple),
      (method: PaymentMethod.bankOfAbyssinia, label: 'BoA', color: const Color(0xFFF59E0B)),
      (method: PaymentMethod.awashBank, label: 'Awash Bank', color: const Color(0xFFEA580C)),
      (method: PaymentMethod.dashenBank, label: 'Dashen Bank', color: const Color(0xFF0284C7)),
      (method: PaymentMethod.otherBankTransfer, label: 'Other Bank', color: Colors.indigo),
    ];

    double digitalRevenue = 0.0;
    int digitalCount = 0;
    for (final p in digitalProviders) {
      digitalRevenue += methodRevenue[p.method] ?? 0.0;
      digitalCount += methodCounts[p.method] ?? 0;
    }

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
          // 1. Fast Action Buttons: Deposit Cash, Log Petty Cash, & Confirm Daily Closing
          if (isMobile)
            Container(
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo.withValues(alpha: 0.2)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _isActionsExpanded = !_isActionsExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.indigo, Color(0xFF4F46E5)],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 14),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cashier Quick Actions',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    isClosed ? 'Daily closing confirmed' : 'Bank deposit, petty cash & shift close',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _isActionsExpanded ? 'Hide' : 'Open',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.indigo),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                _isActionsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: Colors.indigo,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox(width: double.infinity, height: 0),
                    secondChild: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => BankDepositDialog.show(context),
                              icon: const Icon(Icons.account_balance_rounded, size: 16),
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.tr('depositCashToBank'),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.formatShort(undepositedCash)} awaiting deposit',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => PettyCashDialog.show(context),
                              icon: const Icon(Icons.outbox_rounded, size: 16),
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    state.tr('logPettyCash'),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                                  ),
                                  Text(
                                    '${CurrencyFormatter.formatShort(state.todayPettyCashExpensesETB as double)} logged',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isClosed ? null : () => DailyClosingDialog.show(context),
                              icon: Icon(isClosed ? Icons.verified_rounded : Icons.fact_check_rounded, size: 16),
                              label: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isClosed ? 'Daily Closing Confirmed' : state.tr('confirmDailyClosing'),
                                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                                  ),
                                  Text(
                                    isClosed ? 'Shift locked' : 'Reconcile register',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.normal, color: Colors.white70),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.statusCompleted,
                                disabledForegroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    crossFadeState: _isActionsExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            )
          else
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
                        Text(
                          state.tr('depositCashToBank'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
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

                // Log Petty Cash Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => PettyCashDialog.show(context),
                    icon: const Icon(Icons.outbox_rounded, size: 16),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.tr('logPettyCash'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                        Text(
                          '${CurrencyFormatter.formatShort(state.todayPettyCashExpensesETB as double)} recorded',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Confirm Daily Closing Button (Disabled once confirmed)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isClosed ? null : () => DailyClosingDialog.show(context),
                    icon: Icon(isClosed ? Icons.verified_rounded : Icons.fact_check_rounded, size: 16),
                    label: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isClosed ? 'Daily Closing Confirmed' : state.tr('confirmDailyClosing'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
                        ),
                        Text(
                          isClosed ? 'Shift locked' : 'Reconcile register & commission',
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.normal, color: Colors.white70),
                        ),
                      ],
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.statusCompleted,
                      disabledForegroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),

          // 2. Clear Categorized Breakdown: Cash Collected vs Digital Money Transfer
          Row(
            children: [
              // Category A: Cash Collected (Gate)
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.cashGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cashGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_rounded, size: 18, color: AppColors.cashGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.tr('cashCollected'),
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.cashGreen),
                            ),
                            Text(
                              '${CurrencyFormatter.formatShort(cashRevenue)} ($cashCount)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Category B: Digital Money Transfer (Dropdown Trigger)
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _isDigitalBreakdownExpanded = !_isDigitalBreakdownExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.telebirrBlue.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _isDigitalBreakdownExpanded
                            ? AppColors.telebirrBlue
                            : AppColors.telebirrBlue.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phonelink_ring_rounded, size: 18, color: AppColors.telebirrBlue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.tr('digitalMoneyTransfer'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.telebirrBlue),
                              ),
                              Text(
                                '${CurrencyFormatter.formatShort(digitalRevenue)} ($digitalCount)',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isDigitalBreakdownExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          size: 18,
                          color: AppColors.telebirrBlue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // 2.1 Expandable Digital Providers Dropdown List
          if (_isDigitalBreakdownExpanded) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.6),
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
                        '${state.tr("digitalMoneyTransfer")} Channels:',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                      ),
                      Text(
                        'Total: ${CurrencyFormatter.format(digitalRevenue)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.telebirrBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: digitalProviders.map((c) {
                      final amt = methodRevenue[c.method] ?? 0.0;
                      final cnt = methodCounts[c.method] ?? 0;
                      final hasPayments = amt > 0;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: hasPayments ? c.color.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasPayments ? c.color.withOpacity(0.35) : AppColors.cardBorder,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(c.method.icon, size: 12, color: hasPayments ? c.color : AppColors.textSecondary),
                            const SizedBox(width: 4),
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
                ],
              ),
            ),
          ],
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
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: AutoCareAssets.getPackageImage(b.package),
                width: 36,
                height: 36,
                borderRadius: 8,
                fallbackIcon: Icons.local_car_wash_rounded,
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
              if (b.serviceType == ServiceType.valetPickUp) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.car_rental_rounded, size: 10, color: Color(0xFF7C3AED)),
                      const SizedBox(width: 2),
                      Text(state.tr('valetBadge'), style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
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

          // Location / GPS if mobile van or valet driver pick-up
          if (b.serviceType.requiresLocation) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 13,
                  color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    b.deliveryLocation ?? b.gpsCoordinates ?? (b.serviceType == ServiceType.valetPickUp ? state.tr("valetPickupInBishoftu") : state.tr("bishoftuMobileVan")),
                    style: TextStyle(
                      fontSize: 11,
                      color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                      fontWeight: FontWeight.w600,
                    ),
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
          ? 'Pay (${CurrencyFormatter.format(b.totalPrice)})'
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
          AutoCareAssets.buildPhotoThumbnail(
            imageUrl: AutoCareAssets.getPackageImage(b.package),
            width: 48,
            height: 48,
            borderRadius: 10,
            fallbackIcon: Icons.local_car_wash_rounded,
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
                if (b.serviceType.requiresLocation) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          b.deliveryLocation ?? b.gpsCoordinates ?? (b.serviceType == ServiceType.valetPickUp ? state.tr("valetPickupInBishoftu") : state.tr("bishoftuMobileVan")),
                          style: TextStyle(
                            fontSize: 11,
                            color: b.serviceType == ServiceType.valetPickUp ? const Color(0xFF7C3AED) : AppColors.mobileVanColor,
                            fontWeight: FontWeight.w600,
                          ),
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
                    ? 'Pay (${CurrencyFormatter.formatShort(b.totalPrice)})'
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

  Widget _buildFilterChips(dynamic state, bool isMobile) {
    final tabs = [
      (index: 0, title: state.tr('queueAndVehicles') as String, icon: Icons.view_list_rounded),
      (index: 1, title: '${state.tr("attendanceDesk")} (${state.presentWashersCount})', icon: Icons.how_to_reg_rounded),
      (index: 2, title: state.tr('washHistory') as String, icon: Icons.history_rounded),
      (index: 3, title: state.tr('closingAndFinancialReports') as String, icon: Icons.fact_check_rounded),
    ];

    if (isMobile) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: tabs.map((tab) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _buildFilterTabButton(
                tab.index,
                tab.title,
                tab.icon,
                _selectedFilterIndex == tab.index,
              ),
            );
          }).toList(),
        ),
      );
    }

    return Row(
      children: tabs.map((tab) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _buildFilterTabButton(tab.index, tab.title, tab.icon, _selectedFilterIndex == tab.index),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFilterTabButton(int index, String title, IconData icon, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedFilterIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : AppColors.cardBorder,
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<WashBooking> _getFilteredBookings(List<WashBooking> bookings) {
    // Only vehicles that are NOT yet paid belong in the active station queue.
    // As soon as payment is confirmed, the vehicle vanishes from the queue and moves to Wash History.
    return bookings.where((b) => !b.payment.isPaid && b.status != WashStatus.cancelled).toList();
  }

  Widget _buildCleanStationCapacityBar(
    BuildContext context,
    dynamic state,
    StationBay bay1,
    StationBay bay2,
    StationBay van,
    bool isMobile,
  ) {
    final bookings = state.bookings as List<WashBooking>;

    // Real-time busy detection from active queue in washing/drying/assigned
    WashBooking? active1;
    WashBooking? active2;
    WashBooking? activeVan;

    for (final b in bookings) {
      if (b.status == WashStatus.washing || b.status == WashStatus.drying || b.status == WashStatus.assignedToBay) {
        if (b.assignedBay == BayType.bay1 && active1 == null) {
          active1 = b;
        } else if (b.assignedBay == BayType.bay2 && active2 == null) {
          active2 = b;
        } else if ((b.assignedBay == BayType.mobileVan || b.serviceType == ServiceType.atHomeMobile) && activeVan == null) {
          activeVan = b;
        }
      }
    }

    final isBay1Busy = active1 != null || !bay1.isVacant;
    final plate1 = active1?.licensePlate ?? bay1.activeLicensePlate;

    final isBay2Busy = active2 != null || !bay2.isVacant;
    final plate2 = active2?.licensePlate ?? bay2.activeLicensePlate;

    final isVanBusy = activeVan != null || !van.isVacant;
    final plateVan = activeVan?.licensePlate ?? van.activeLicensePlate;

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
            child: _buildBayMiniIndicator(state.tr('bay1'), !isBay1Busy, plate1, state, isMobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('bay2'), !isBay2Busy, plate2, state, isMobile),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildBayMiniIndicator(state.tr('mobileVan'), !isVanBusy, plateVan, state, isMobile),
          ),
        ],
      ),
    );
  }

  Widget _buildBayMiniIndicator(String title, bool isFree, String? activePlate, dynamic state, bool isMobile) {
    final color = isFree ? AppColors.statusReady : AppColors.statusWashing;
    final statusText = isFree
        ? state.tr('availableNow')
        : (activePlate != null && activePlate.isNotEmpty ? 'Busy ($activePlate)' : state.tr('busyWashing'));

    final isVan = title.toLowerCase().contains('van');
    final bayImageUrl = isVan ? AutoCareAssets.mobileVanUrl : AutoCareAssets.packageFoamUrl;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          AutoCareAssets.buildPhotoThumbnail(
            imageUrl: bayImageUrl,
            width: isMobile ? 32 : 36,
            height: isMobile ? 32 : 36,
            borderRadius: 8,
            fallbackIcon: isVan ? Icons.airport_shuttle_rounded : Icons.local_car_wash_rounded,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
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
                Text(
                  statusText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 9.5 : 10.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
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

    if (next == WashStatus.completed) {
      await state.sendCustomerCompletionSms(booking);
    }

    if (context.mounted) {
      final msg = next == WashStatus.completed
          ? '${booking.licensePlate} completed! Ready for payment • SMS ready for ${booking.customerPhone}'
          : '${booking.licensePlate} updated to ${next.displayName}!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          backgroundColor: next == WashStatus.completed ? AppColors.cashGreen : next.color,
          action: next == WashStatus.completed
              ? SnackBarAction(
                  label: 'Copy SMS',
                  textColor: Colors.amberAccent,
                  onPressed: () {
                    final sms = state.getCustomerCompletionSmsText(booking);
                    Clipboard.setData(ClipboardData(text: sms));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Customer SMS message copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                )
              : null,
          content: Row(
            children: [
              Icon(
                next == WashStatus.completed ? Icons.sms_rounded : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
    }
  }
}
