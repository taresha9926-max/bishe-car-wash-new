import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_circular_ring.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/combined_service_header_banner.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/modern_expandable_card.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/rounded_meter_bar.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/weekly_commission_report.dart';
import '../../../inventory/domain/models/stock_transaction.dart';
import '../widgets/commission_item_card.dart';
import '../widgets/pricing_matrix_editor.dart';
import 'commission_logs_screen.dart';
import 'credentials_management_screen.dart';
import 'pricing_management_screen.dart';
import 'staff_management_screen.dart';
import '../../../welcome/domain/models/tiktok_ad_video.dart';
import '../../../../core/utils/url_launcher_helper.dart';

enum AdminTimeFilter {
  today,
  thisWeek,
  thisMonth,
  customDate;

  String localizedLabel(dynamic state, [DateTime? selectedCustomDate]) {
    switch (this) {
      case AdminTimeFilter.today:
        return state.tr('filterToday');
      case AdminTimeFilter.thisWeek:
        return state.tr('filterThisWeek');
      case AdminTimeFilter.thisMonth:
        return state.tr('filterThisMonth');
      case AdminTimeFilter.customDate:
        if (selectedCustomDate != null) {
          return '${selectedCustomDate.day}/${selectedCustomDate.month}/${selectedCustomDate.year}';
        }
        return 'Filter by Date';
    }
  }
}

class _OperationItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageUrl;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _OperationItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageUrl,
    required this.color,
    this.badge,
    required this.onTap,
  });
}

class _DeepModuleItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageUrl;
  final List<Color> gradientColors;
  final String? badgeText;
  final Color? badgeColor;
  final Widget Function() contentBuilder;

  const _DeepModuleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageUrl,
    required this.gradientColors,
    this.badgeText,
    this.badgeColor,
    required this.contentBuilder,
  });
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  AdminTimeFilter _selectedFilter = AdminTimeFilter.today;
  DateTime? _selectedCustomDate;
  int? _activeDeepModuleIndex;
  String _washerCommissionFilter = 'Weekly'; // Daily, Weekly, Date Range
  late final TextEditingController _cashierPhoneController;
  late final TextEditingController _customerPhoneController;
  final _adminCashierOtpController = TextEditingController();
  final _adminNightOtpController = TextEditingController();
  bool _phoneControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _cashierPhoneController = TextEditingController();
    _customerPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _cashierPhoneController.dispose();
    _customerPhoneController.dispose();
    _adminCashierOtpController.dispose();
    _adminNightOtpController.dispose();
    super.dispose();
  }

  List<WashBooking> _filterBookings(List<WashBooking> bookings, AdminTimeFilter filter, DateTime? customDate) {
    final now = DateTime.now();
    switch (filter) {
      case AdminTimeFilter.today:
        return bookings.where((b) =>
          b.createdAt.year == now.year &&
          b.createdAt.month == now.month &&
          b.createdAt.day == now.day,
        ).toList();
      case AdminTimeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return bookings.where((b) => b.createdAt.isAfter(startMonday) || b.createdAt.isAtSameMomentAs(startMonday)).toList();
      case AdminTimeFilter.thisMonth:
        return bookings.where((b) =>
          b.createdAt.year == now.year &&
          b.createdAt.month == now.month,
        ).toList();
      case AdminTimeFilter.customDate:
        final target = customDate ?? now;
        return bookings.where((b) =>
          b.createdAt.year == target.year &&
          b.createdAt.month == target.month &&
          b.createdAt.day == target.day,
        ).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    if (!_phoneControllerInitialized) {
      _cashierPhoneController.text = state.cashierSmsPhone;
      _customerPhoneController.text = state.customerPhoneBookingNumber;
      _phoneControllerInitialized = true;
    }

    // Time-filtered bookings
    final filteredBookings = _filterBookings(state.bookings, _selectedFilter, _selectedCustomDate);
    final paidBookings = filteredBookings.where((b) => b.payment.isPaid).toList();
    final completedCars = filteredBookings.where((b) => b.status == WashStatus.completed).length;

    // Financial Metrics
    final totalRevenue = paidBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final cashRevenue = paidBookings.where((b) => b.payment.method == PaymentMethod.cash).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digitalRevenue = paidBookings.where((b) => b.payment.method != PaymentMethod.cash).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final totalPettyCash = state.pettyCashExpenses.fold<double>(0.0, (sum, p) => sum + p.amount);
    final totalSupplies = state.stockTransactions
        .where((t) => t.type == 'receiveStock' || t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption')
        .fold<double>(0.0, (sum, t) => sum + t.totalCostEtb);
    final totalFixedAssets = 0.0;
    final commissionPool = totalRevenue * state.teamCommissionRate;
    final netProfit = totalRevenue - commissionPool - totalPettyCash;

    // Digital receipts for the period
    final digitalBookings = paidBookings.where((b) => b.payment.method.isDigital).toList();
    final recentLogs = state.commissionLogs.take(4).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('adminTitle'),
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
              CombinedServiceHeaderBanner(
                title: state.tr('adminCombinedHeader'),
                subtitle: state.tr('adminCombinedSub'),
                badgeText: state.tr('unifiedDesk'),
                padding: const EdgeInsets.only(bottom: 14),
              ),
              if (state.hasNewCashierClosingAlert && state.latestClosingAlert != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF115E59)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: Colors.teal.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.latestClosingAlert!.shiftType == 'night'
                                  ? 'Station Night Shift Closing Confirmed (Handover to Admin)'
                                  : 'Cashier Day Shift Closing Confirmed (Handover to Manager)',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                            ),
                            Text(
                              state.latestClosingAlert!.shiftType == 'night'
                                  ? 'Op Manager: ${state.latestClosingAlert!.cashierName} • Total Cash to Admin: ${CurrencyFormatter.format(state.latestClosingAlert!.handoverCashAmount)} • Gross: ${CurrencyFormatter.format(state.latestClosingAlert!.grossRevenue)}'
                                  : 'Cashier: ${state.latestClosingAlert!.cashierName} • Handover Cash: ${CurrencyFormatter.format(state.latestClosingAlert!.cashRemaining)} • Revenue: ${CurrencyFormatter.format(state.latestClosingAlert!.grossRevenue)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => state.dismissCashierClosingAlert(),
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                        tooltip: 'Dismiss Alert',
                      ),
                    ],
                  ),
                ),
              ],

              // Pending Manager Night Closing Cash Receipt via OTP
              if (state.pendingAdminNightHandover != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEA580C).withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_moon_rounded, size: 28, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('adminHandoverPending'),
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Manager ${state.pendingAdminNightHandover!.cashierName} closed night shift. Handover Cash: ${CurrencyFormatter.format(state.pendingAdminNightHandover!.handoverCashAmount)}',
                              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => _confirmAcceptManagerNightCash(context, state),
                        icon: const Icon(Icons.vpn_key_rounded, size: 16, color: Color(0xFFC2410C)),
                        label: Text(
                          state.tr('verifyAdminOtp'),
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: Color(0xFFC2410C)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Permanent OTP Shift Handover Desk (Always Visible)
              _buildOtpShiftHandoverDesk(context, state, isMobile),
              const SizedBox(height: 14),

              // Pending Approval Queue (from Secondary Admin actions)
              _buildPendingApprovalsBanner(context, state),

              // 1. Executive Banner (Responsive)
              _buildExecutiveBanner(state, isMobile),
              const SizedBox(height: 14),

              // 2. Interactive Time Filter Selector
              _buildTimeFilterBar(state),
              const SizedBox(height: 14),

              // Executive Radial Health & Real-Time Performance Gauges
              Container(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    AnimatedCircularRing(
                      progress: totalRevenue > 0 ? (netProfit > 0 ? (netProfit / totalRevenue) : 0.0) : 0.0,
                      size: isMobile ? 74 : 84,
                      strokeWidth: 7,
                      primaryColor: const Color(0xFF10B981),
                      secondaryColor: const Color(0xFF34D399),
                      trackColor: const Color(0xFF0B1320),
                      centerValue: totalRevenue > 0 ? '${((netProfit / totalRevenue) * 100).toInt()}%' : '0%',
                      centerLabel: 'Net Margin',
                      valueStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                      labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF34D399)),
                    ),
                    SizedBox(width: isMobile ? 12 : 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Executive Real-Time Metrics',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.5), width: 0.8),
                                ),
                                child: Text(
                                  '$completedCars Washed',
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF38BDF8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          RoundedMeterBar(
                            progress: totalRevenue > 0 ? (digitalRevenue / totalRevenue) : 0.0,
                            label: 'Digital Transfers vs Cash',
                            valueText: '${CurrencyFormatter.formatShort(digitalRevenue)} Digital',
                            gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                            trackColor: const Color(0xFF0B1320),
                            labelColor: Colors.white70,
                            valueColor: const Color(0xFF38BDF8),
                            height: 6,
                          ),
                          const SizedBox(height: 7),
                          RoundedMeterBar(
                            progress: (state.presentWashersCount / (state.totalWashersCount == 0 ? 1 : state.totalWashersCount)).clamp(0.0, 1.0),
                            label: 'Washer Crew Attendance',
                            valueText: '${state.presentWashersCount} / ${state.totalWashersCount} On Duty',
                            gradientColors: const [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                            trackColor: const Color(0xFF0B1320),
                            labelColor: Colors.white70,
                            valueColor: const Color(0xFFFBBF24),
                            height: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 3. Financial & Operational KPIs (Responsive Grid with no text clipping)
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final isMedium = constraints.maxWidth >= 550 && !isWide;
                  final crossAxisCount = isWide ? 4 : 2;
                  final childAspectRatio = isWide
                      ? 1.6
                      : (isMedium ? 1.55 : (constraints.maxWidth < 360 ? 1.2 : 1.35));

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: isMobile ? 10 : 12,
                    mainAxisSpacing: isMobile ? 10 : 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: childAspectRatio,
                    children: [
                      _buildMetricCard(
                        state.tr('totalRevenueAdmin'),
                        CurrencyFormatter.formatShort(totalRevenue),
                        '$completedCars ${state.tr("carsWashed")}',
                        Icons.account_balance_wallet_rounded,
                        AppColors.primary,
                        imageUrl: AutoCareAssets.stationBayUrl,
                        isMobile: isMobile,
                      ),
                      _buildMetricCard(
                        state.tr('commissionsPaid'),
                        CurrencyFormatter.formatShort(commissionPool),
                        '${(state.teamCommissionRate * 100).toStringAsFixed(0)}% team pool',
                        Icons.handshake_rounded,
                        AppColors.oromiaGold,
                        imageUrl: AutoCareAssets.packageFoamUrl,
                        isMobile: isMobile,
                      ),
                      _buildMetricCard(
                        state.tr('netStationProfit'),
                        CurrencyFormatter.formatShort(netProfit > 0 ? netProfit : 0),
                        state.tr('afterPayrollCuts'),
                        Icons.trending_up_rounded,
                        AppColors.statusReady,
                        imageUrl: AutoCareAssets.packageDeluxeSpaUrl,
                        isMobile: isMobile,
                      ),
                      _buildMetricCard(
                        state.tr('activeWashers'),
                        '${state.presentWashersCount} On Duty',
                        '${state.totalWashersCount} total washers',
                        Icons.groups_rounded,
                        AppColors.secondary,
                        imageUrl: AutoCareAssets.valetDriverUrl,
                        isMobile: isMobile,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),

              // 4. Cash vs Digital Settlement Bar (Responsive Wrap)
              _buildCashVsDigitalBar(state, totalRevenue, cashRevenue, digitalRevenue),
              const SizedBox(height: 18),

              // 5. Operational Management Modules (High priority quick actions)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.tr('managementOperations'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 15.5 : 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '6 MODULES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildManagementOperations(context, state, isMobile),
              const SizedBox(height: 18),

              // 6. Deep Operations & Audits (Card View with 3 Rows)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Deep Operations & Audits',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: isMobile ? 15.5 : 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '6 MODULES',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDeepManagementOperations(
                context,
                state,
                isMobile,
                totalRevenue,
                commissionPool,
                totalPettyCash,
                totalSupplies,
                totalFixedAssets,
                digitalBookings,
              ),
              const SizedBox(height: 36),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeFilterBar(dynamic state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: AdminTimeFilter.values.map((filter) {
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (filter == AdminTimeFilter.customDate) {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedCustomDate ?? DateTime.now(),
                      firstDate: DateTime(2022),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedCustomDate = picked;
                        _selectedFilter = AdminTimeFilter.customDate;
                      });
                    }
                  } else {
                    setState(() => _selectedFilter = filter);
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 1.4 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (filter == AdminTimeFilter.customDate) ...[
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        filter.localizedLabel(state, _selectedCustomDate),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
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
    );
  }

  Widget _buildCashVsDigitalBar(dynamic state, double total, double cash, double digital) {
    final cashPercent = total > 0 ? (cash / total) : 0.5;
    final digitalPercent = total > 0 ? (digital / total) : 0.5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  state.tr('cashVsDigital'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${CurrencyFormatter.format(total)} Total',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  Expanded(
                    flex: (cashPercent * 100).toInt().clamp(1, 99),
                    child: Container(color: Colors.green),
                  ),
                  Expanded(
                    flex: (digitalPercent * 100).toInt().clamp(1, 99),
                    child: Container(color: AppColors.telebirrBlue),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 4,
            spacing: 12,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                    'Cash: ${CurrencyFormatter.format(cash)} (${(cashPercent * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.telebirrBlue, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text(
                    'Digital: ${CurrencyFormatter.format(digital)} (${(digitalPercent * 100).toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalsBanner(BuildContext context, dynamic state) {
    if (state.pendingApprovals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade400, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pending_actions_rounded, color: Colors.orange, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.isSuperAdmin
                      ? '${state.pendingApprovals.length} Secondary Admin Action(s) Awaiting Approval'
                      : '${state.pendingApprovals.length} Action(s) Submitted for Super Admin Approval',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.brown),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...state.pendingApprovals.map((req) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(req.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(req.description, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (state.isSuperAdmin) ...[
                    TextButton(
                      onPressed: () async {
                        await state.rejectRequest(req.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Rejected request: ${req.title}'), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                      child: const Text('Reject', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusCompleted,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        await state.approveRequest(req.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Approved: ${req.title}'), backgroundColor: AppColors.statusCompleted),
                          );
                        }
                      },
                      child: const Text('Approve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Pending Review',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.brown),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStandardFinancialStatementCard(
    BuildContext context,
    dynamic state,
    bool isMobile,
    double totalRevenue,
    double commissionPool,
    double totalPettyCash,
    double totalSupplies,
    double totalFixedAssets,
  ) {
    final cogs = commissionPool + totalSupplies;
    final grossProfit = totalRevenue - cogs;
    final opex = totalPettyCash + totalFixedAssets;
    final netOperatingProfit = grossProfit - opex;
    final monthlySalaryObligation = state.monthlyTotalBaseSalary as double;
    final netRetainedProfit = netOperatingProfit - monthlySalaryObligation;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AutoCareAssets.buildPhotoThumbnail(
                imageUrl: AutoCareAssets.cashMoneyUrl,
                width: 38,
                height: 38,
                borderRadius: 10,
                fallbackIcon: Icons.account_balance_wallet_rounded,
                fallbackColor: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Executive Financial Statement (P&L)',
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Revenue, COGS, Consumables & OpEx Breakdown',
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (netOperatingProfit >= 0 ? AppColors.statusReady : AppColors.statusCancelled).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  netOperatingProfit >= 0 ? 'PROFITABLE' : 'DEFICIT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: netOperatingProfit >= 0 ? AppColors.statusReady : AppColors.statusCancelled,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          // Section 1: Revenue
          _buildStatementRow('I. Gross Wash Revenue', CurrencyFormatter.format(totalRevenue), Colors.green.shade800, isHeader: true),
          const SizedBox(height: 6),

          // Section 2: COGS
          _buildStatementRow('II. Cost of Goods Sold (COGS)', '- ${CurrencyFormatter.format(cogs)}', Colors.orange.shade900, isHeader: true),
          _buildStatementSubRow('• Washer Team 15% Commission Pool', '- ${CurrencyFormatter.format(commissionPool)}'),
          _buildStatementSubRow('• Consumables Used & Soap Restocks', '- ${CurrencyFormatter.format(totalSupplies)}'),
          const Divider(height: 12),
          _buildStatementRow('GROSS OPERATING PROFIT', CurrencyFormatter.format(grossProfit), grossProfit >= 0 ? Colors.green.shade700 : Colors.red, isBold: true),
          const SizedBox(height: 8),

          // Section 3: OpEx
          _buildStatementRow('III. Operating Expenses (OpEx)', '- ${CurrencyFormatter.format(opex)}', Colors.deepOrange.shade900, isHeader: true),
          _buildStatementSubRow('• Cashier Petty Cash Emergency Spends', '- ${CurrencyFormatter.format(totalPettyCash)}'),
          _buildStatementSubRow('• Fixed Assets & Equipment Purchases', '- ${CurrencyFormatter.format(totalFixedAssets)}'),
          const Divider(thickness: 1.5, height: 16),

          // Section 4: Net Operating Profit
          _buildStatementRow('NET OPERATING PROFIT (EBITDA)', CurrencyFormatter.format(netOperatingProfit), netOperatingProfit >= 0 ? Colors.teal.shade800 : Colors.red, isBold: true, isLarge: true),
          const Divider(height: 16),

          // Section 5: Base Salary Reserve
          _buildStatementRow('IV. Guaranteed Monthly Base Salaries Reserve', CurrencyFormatter.format(monthlySalaryObligation), Colors.blueGrey, isHeader: true),
          _buildStatementSubRow('• 8 Washers Monthly Guaranteed Wage', CurrencyFormatter.format(monthlySalaryObligation)),
          const SizedBox(height: 4),
          _buildStatementRow('Net Retained Cash Profit', CurrencyFormatter.format(netRetainedProfit), netRetainedProfit >= 0 ? Colors.indigo.shade800 : Colors.red, isBold: true),
        ],
      ),
    );
  }

  Widget _buildStatementRow(String label, String value, Color color, {bool isHeader = false, bool isBold = false, bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 13.5 : (isHeader ? 12.5 : 12),
              fontWeight: (isHeader || isBold || isLarge) ? FontWeight.w900 : FontWeight.w600,
              color: isHeader ? color : AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 14.5 : (isBold ? 13 : 12),
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatementSubRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 2, bottom: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildWeeklyWasherCommissionReportSection(
    BuildContext context,
    dynamic state,
    bool isMobile,
  ) {
    final latestReport = state.latestWeeklyCommissionReport as WeeklyCommissionReport?;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.oromiaGold.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (isMobile) ...[
            Row(
              children: [
                AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.packageDeluxeSpaUrl,
                  width: 36,
                  height: 36,
                  borderRadius: 10,
                  fallbackIcon: Icons.receipt_long_rounded,
                  fallbackColor: AppColors.oromiaGold,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr('weeklyCommissionReport'),
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        state.tr('weeklyCommissionReportSub'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
                  );
                },
                icon: const Icon(Icons.manage_accounts_rounded, size: 14),
                label: Text(
                  state.tr('staffAndSalaries'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: AutoCareAssets.packageDeluxeSpaUrl,
                        width: 38,
                        height: 38,
                        borderRadius: 10,
                        fallbackIcon: Icons.receipt_long_rounded,
                        fallbackColor: AppColors.oromiaGold,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.tr('weeklyCommissionReport'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              state.tr('weeklyCommissionReportSub'),
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
                    );
                  },
                  icon: const Icon(Icons.manage_accounts_rounded, size: 14),
                  label: Text(
                    state.tr('staffAndSalaries'),
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          // Filter Chips (Daily, Weekly, Selected Date Range)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('Daily Today'),
                  selected: _washerCommissionFilter == 'Daily',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _washerCommissionFilter == 'Daily' ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _washerCommissionFilter = 'Daily'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Weekly Report'),
                  selected: _washerCommissionFilter == 'Weekly',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _washerCommissionFilter == 'Weekly' ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _washerCommissionFilter = 'Weekly'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Selected Date Range'),
                  selected: _washerCommissionFilter == 'Date Range',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: _washerCommissionFilter == 'Date Range' ? Colors.white : AppColors.textPrimary,
                  ),
                  onSelected: (_) => setState(() => _washerCommissionFilter = 'Date Range'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          // View 1: Daily Today
          if (_washerCommissionFilter == 'Daily') ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today: ${state.presentWashersCount} of ${state.totalWashersCount} On Duty',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Pool: ${CurrencyFormatter.format(state.teamCommissionPoolTodayETB)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (state.availableWashers as List).length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final w = (state.availableWashers as List)[index];
                final isPresent = state.isWasherPresentToday(w.id);
                final div = state.washerDividendsToday[w.id];
                final earned = (isPresent && div != null) ? div.earnedETB : 0.0;

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: AutoCareAssets.spongeBucketUrl,
                        width: 32,
                        height: 32,
                        borderRadius: 8,
                        fallbackIcon: Icons.badge_rounded,
                        fallbackColor: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(w.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                            Text(
                              isPresent ? 'Present • On Duty' : 'Absent Today',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: isPresent ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(earned),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: isPresent ? AppColors.statusCompleted : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ]
          // View 2: Weekly Report
          else if (_washerCommissionFilter == 'Weekly') ...[
            if (latestReport == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_note_outlined, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        state.tr('noWeeklyCommissionReports'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cashier compiles and reports weekly commission payouts from Cashier Dashboard.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.statusCompleted.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  state.tr('statusPaid').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.statusCompleted,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${latestReport.weekStartDate.day}/${latestReport.weekStartDate.month} - ${latestReport.weekEndDate.day}/${latestReport.weekEndDate.month}/${latestReport.weekEndDate.year}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.tr('reportedByCashier')}: ${latestReport.cashierName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          state.tr('totalCommissionDisbursed'),
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(latestReport.totalWeeklyPool),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: latestReport.washerCommissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final entry = latestReport.washerCommissions.entries.toList()[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: AutoCareAssets.spongeBucketUrl,
                          width: 32,
                          height: 32,
                          borderRadius: 8,
                          fallbackIcon: Icons.badge_rounded,
                          fallbackColor: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(entry.value),
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.statusCompleted),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ]
          // View 3: Date Range Filter
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter: ${_selectedFilter.localizedLabel(state, _selectedCustomDate)}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  Text(
                    'Pool: ${CurrencyFormatter.format(state.weeklyTotalCommissionPool)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (state.availableWashers as List).length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final w = (state.availableWashers as List)[index];
                final earned = (state.weeklyWasherCommissions as Map<String, double>)[w.name] ?? 0.0;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: AutoCareAssets.spongeBucketUrl,
                        width: 32,
                        height: 32,
                        borderRadius: 8,
                        fallbackIcon: Icons.badge_rounded,
                        fallbackColor: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(w.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                      ),
                      Text(
                        CurrencyFormatter.format(earned),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.statusCompleted),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 14, color: Colors.blue),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Washers commission is paid weekly by the Cashier and reported to Admin. Base salaries are paid monthly.',
                    style: TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Responsive Management Operations:
  /// Modern card view with three clean rows (2 cards per row) featuring
  /// high-definition automotive photography thumbnails and status badges.
  Widget _buildManagementOperations(BuildContext context, dynamic state, bool isMobile) {
    final operations = [
      _OperationItem(
        title: state.tr('masterPricingAndInventory'),
        subtitle: 'Edit tariffs, car wash, carpet, consumables & fixed assets',
        icon: Icons.tune_rounded,
        imageUrl: AutoCareAssets.carSedanUrl,
        color: AppColors.primary,
        badge: '${state.serviceItems.length + state.consumables.length + state.fixedAssets.length} Items',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PricingManagementScreen()),
          );
        },
      ),
      _OperationItem(
        title: state.tr('staffPayroll'),
        subtitle: state.tr('staffPayrollSub'),
        icon: Icons.badge_rounded,
        imageUrl: AutoCareAssets.mobileVanUrl,
        color: AppColors.secondary,
        badge: '${state.staff.length} Crew',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffManagementScreen()),
          );
        },
      ),
      _OperationItem(
        title: state.tr('staffPins'),
        subtitle: state.tr('staffPinsSub'),
        icon: Icons.pin_outlined,
        imageUrl: AutoCareAssets.carCockpitUrl,
        color: AppColors.accent,
        badge: 'Security',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CredentialsManagementScreen()),
          );
        },
      ),
      _OperationItem(
        title: state.tr('washHistory'),
        subtitle: 'Audit paid & completed washes by date range',
        icon: Icons.history_edu_rounded,
        imageUrl: AutoCareAssets.welcomeHeroUrl,
        color: AppColors.telebirrBlue,
        badge: 'History',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VehicleHistoryScreen()),
          );
        },
      ),
      _OperationItem(
        title: state.tr('closingAndFinancialReports'),
        subtitle: 'Audit daily closings, bank deposits & payment channels',
        icon: Icons.fact_check_rounded,
        imageUrl: AutoCareAssets.packageTireRimUrl,
        color: AppColors.cashGreen,
        badge: 'Reports',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FinancialReportsView()),
          );
        },
      ),
      if (state.isSuperAdmin)
        _OperationItem(
          title: state.tr('clearAllBookings'),
          subtitle: state.tr('clearAllBookingsSubtitle'),
          icon: Icons.delete_sweep_rounded,
          imageUrl: AutoCareAssets.packageSteamEngineUrl,
          color: Colors.red.shade700,
          badge: '${state.bookings.length} Booked',
          onTap: () => _confirmClearAllBookings(context, state),
        )
      else
        _OperationItem(
          title: 'Automated SMS Gateway',
          subtitle: 'Active vehicle completion SMS dispatch & hotline numbers',
          icon: Icons.sms_rounded,
          imageUrl: AutoCareAssets.stationBayUrl,
          color: const Color(0xFF6366F1),
          badge: 'Gateway',
          onTap: () {},
        ),
    ];

    // Card View with Three Rows (2 cards per row)
    return Column(
      children: [
        // Row 1
        Row(
          children: [
            Expanded(child: _buildOperationCard(context, operations[0], isMobile)),
            const SizedBox(width: 10),
            Expanded(child: _buildOperationCard(context, operations[1], isMobile)),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2
        Row(
          children: [
            Expanded(child: _buildOperationCard(context, operations[2], isMobile)),
            const SizedBox(width: 10),
            Expanded(child: _buildOperationCard(context, operations[3], isMobile)),
          ],
        ),
        const SizedBox(height: 10),
        // Row 3
        Row(
          children: [
            Expanded(child: _buildOperationCard(context, operations[4], isMobile)),
            const SizedBox(width: 10),
            Expanded(child: _buildOperationCard(context, operations[5], isMobile)),
          ],
        ),
      ],
    );
  }

  Widget _buildOperationCard(BuildContext context, _OperationItem op, bool isMobile) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: op.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: op.color.withValues(alpha: 0.25), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: op.color.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  op.imageUrl != null
                      ? AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: op.imageUrl!,
                          width: isMobile ? 38 : 44,
                          height: isMobile ? 38 : 44,
                          borderRadius: 10,
                          fallbackIcon: op.icon,
                          fallbackColor: op.color,
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: op.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(op.icon, color: op.color, size: 20),
                        ),
                  if (op.badge != null) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: op.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          op.badge!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: op.color,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                op.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: isMobile ? 12.5 : 13.5,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                op.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Responsive Deep Management Operations:
  /// Modern card view with three clean rows (2 cards per row = 6 cards)
  /// featuring automotive photography thumbnails, indicator badges, and
  /// active inline panel expansion.
  Widget _buildDeepManagementOperations(
    BuildContext context,
    dynamic state,
    bool isMobile,
    double totalRevenue,
    double commissionPool,
    double totalPettyCash,
    double totalSupplies,
    double totalFixedAssets,
    List<WashBooking> digitalBookings,
  ) {
    final modules = [
      _DeepModuleItem(
        title: 'Customer SMS & Hotline',
        subtitle: 'Customer vehicle completion SMS dispatch & hotline numbers',
        icon: Icons.sms_rounded,
        imageUrl: AutoCareAssets.carSedanUrl,
        gradientColors: const [Color(0xFF6366F1), Color(0xFF4F46E5)],
        badgeText: 'Active Gateway',
        badgeColor: const Color(0xFF4F46E5),
        contentBuilder: () => _buildCashierSmsConfigCard(context, state, isMobile),
      ),
      _DeepModuleItem(
        title: 'TikTok Commercial Reels',
        subtitle: 'Video showcase on app launch for customer engagement',
        icon: Icons.video_library_rounded,
        imageUrl: AutoCareAssets.packageFoamUrl,
        gradientColors: const [Color(0xFFEC4899), Color(0xFFBE185D)],
        badgeText: '${(state.tiktokReels as List).length} Reels',
        badgeColor: const Color(0xFFEC4899),
        contentBuilder: () => _buildTikTokCommercialReelsManagerCard(context, state, isMobile),
      ),
      _DeepModuleItem(
        title: 'Financial Statement (P&L)',
        subtitle: 'Gross revenue, COGS, operating expenses & net station profit',
        icon: Icons.analytics_rounded,
        imageUrl: AutoCareAssets.stationBayUrl,
        gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
        badgeText: 'P&L Ledger',
        badgeColor: const Color(0xFF0F766E),
        contentBuilder: () => _buildStandardFinancialStatementCard(
          context,
          state,
          isMobile,
          totalRevenue,
          commissionPool,
          totalPettyCash,
          totalSupplies,
          totalFixedAssets,
        ),
      ),
      _DeepModuleItem(
        title: 'Washer Team & Attendance',
        subtitle: 'Washer attendance roster, daily presence & 100% pool distribution',
        icon: Icons.groups_rounded,
        imageUrl: AutoCareAssets.valetDriverUrl,
        gradientColors: const [AppColors.secondary, Color(0xFF0284C7)],
        badgeText: '${state.presentWashersCount}/${state.totalWashersCount} On Duty',
        badgeColor: AppColors.secondary,
        contentBuilder: () => SharedWasherCommissionHub(
          state: state,
          role: WasherHubRole.admin,
          isMobile: isMobile,
          initiallyExpanded: true,
        ),
      ),
      _DeepModuleItem(
        title: 'Weekly Washer Reports',
        subtitle: 'Cashier-submitted weekly payout ledgers and audits',
        icon: Icons.assignment_turned_in_rounded,
        imageUrl: AutoCareAssets.packageDeluxeSpaUrl,
        gradientColors: const [AppColors.oromiaGold, Color(0xFFD97706)],
        badgeText: '${(state.weeklyCommissionReports as List).length} Reports',
        badgeColor: AppColors.oromiaGold,
        contentBuilder: () => _buildWeeklyWasherCommissionReportSection(context, state, isMobile),
      ),
      _DeepModuleItem(
        title: 'Digital Receipts Audit',
        subtitle: 'Telebirr, CBE Birr & Awash transaction verification',
        icon: Icons.receipt_long_rounded,
        imageUrl: AutoCareAssets.stationBayUrl,
        gradientColors: const [AppColors.telebirrBlue, Color(0xFF0284C7)],
        badgeText: '${digitalBookings.length} Receipts',
        badgeColor: AppColors.telebirrBlue,
        contentBuilder: () => _buildDigitalReceiptsSection(context, digitalBookings, isMobile),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Card View with Three Rows (2 cards per row)
        // Row 1
        Row(
          children: [
            Expanded(child: _buildDeepModuleCard(context, modules[0], 0, isMobile)),
            const SizedBox(width: 10),
            Expanded(child: _buildDeepModuleCard(context, modules[1], 1, isMobile)),
          ],
        ),
        const SizedBox(height: 10),
        // Row 2
        Row(
          children: [
            Expanded(child: _buildDeepModuleCard(context, modules[2], 2, isMobile)),
            const SizedBox(width: 10),
            Expanded(child: _buildDeepModuleCard(context, modules[3], 3, isMobile)),
          ],
        ),
        const SizedBox(height: 10),
        // Row 3
        Row(
          children: [
            Expanded(child: _buildDeepModuleCard(context, modules[4], 4, isMobile)),
            const SizedBox(width: 10),
            Expanded(child: _buildDeepModuleCard(context, modules[5], 5, isMobile)),
          ],
        ),

        // Active Expanded Content Panel
        if (_activeDeepModuleIndex != null && _activeDeepModuleIndex! < modules.length) ...[
          const SizedBox(height: 14),
          _buildActiveDeepModulePanel(context, modules[_activeDeepModuleIndex!], isMobile),
        ],
      ],
    );
  }

  Widget _buildDeepModuleCard(BuildContext context, _DeepModuleItem item, int index, bool isMobile) {
    final isActive = _activeDeepModuleIndex == index;
    final primaryColor = item.gradientColors.first;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          setState(() {
            if (_activeDeepModuleIndex == index) {
              _activeDeepModuleIndex = null;
            } else {
              _activeDeepModuleIndex = index;
            }
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.all(isMobile ? 12 : 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? primaryColor : primaryColor.withValues(alpha: 0.25),
              width: isActive ? 2.0 : 1.2,
            ),
            boxShadow: [
              if (isActive)
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              else
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  item.imageUrl != null
                      ? AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: item.imageUrl!,
                          width: isMobile ? 38 : 44,
                          height: isMobile ? 38 : 44,
                          borderRadius: 10,
                          fallbackIcon: item.icon,
                          fallbackColor: primaryColor,
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: item.gradientColors),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon, color: Colors.white, size: 20),
                        ),
                  if (item.badgeText != null) ...[
                    const SizedBox(width: 4),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (item.badgeColor ?? primaryColor).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: (item.badgeColor ?? primaryColor).withValues(alpha: 0.3),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          item.badgeText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: item.badgeColor ?? primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: isMobile ? 12.5 : 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    isActive ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isActive ? primaryColor : AppColors.textMuted,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveDeepModulePanel(BuildContext context, _DeepModuleItem item, bool isMobile) {
    final primaryColor = item.gradientColors.first;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: item.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      item.imageUrl != null
                          ? AutoCareAssets.buildPhotoThumbnail(
                              imageUrl: item.imageUrl!,
                              width: 32,
                              height: 32,
                              borderRadius: 8,
                              fallbackIcon: item.icon,
                              fallbackColor: Colors.white,
                            )
                          : Icon(item.icon, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _activeDeepModuleIndex = null),
                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.white),
                  label: const Text(
                    'Close',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),

          // Child content
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: item.contentBuilder(),
          ),
        ],
      ),
    );
  }

  void _confirmClearAllBookings(BuildContext context, dynamic state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                state.tr('clearAllBookingsConfirm'),
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
            ),
          ],
        ),
        content: Text(
          state.tr('clearAllBookingsDesc'),
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.clearAllBookings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.tr('clearAllBookingsSuccess')),
                    backgroundColor: Colors.green.shade700,
                  ),
                );
              }
            },
            child: Text(state.tr('clearAllBookings')),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalReceiptsSection(
    BuildContext context,
    List<WashBooking> bookings,
    bool isMobile,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.telebirrBlue.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.receipt_long_rounded, color: AppColors.telebirrBlue, size: 19),
                    ),
                    const SizedBox(width: 10),
                    const Flexible(
                      child: Text(
                        'Digital Receipts & Verification',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  '${bookings.length} Digital',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (bookings.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              alignment: Alignment.center,
              child: const Text(
                'No digital payments recorded in this period.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: bookings.take(6).length,
              separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.cardBorder),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final hasScreenshot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty;

                return Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: b.payment.method.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(b.payment.method.icon, color: b.payment.method.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                b.licensePlate,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: b.payment.method.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  b.payment.method.shortName,
                                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: b.payment.method.color),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Ref: ${b.payment.transactionRef ?? 'N/A'} • ${CurrencyFormatter.format(b.payment.amount)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (hasScreenshot)
                      ElevatedButton.icon(
                        onPressed: () => _showScreenshotDialog(context, b),
                        icon: const Icon(Icons.image_rounded, size: 13),
                        label: const Text('Receipt', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.telebirrBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'No Receipt',
                          style: TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showScreenshotDialog(BuildContext context, WashBooking booking) {
    final screenshot = booking.payment.receiptScreenshot ?? '';
    Widget imageWidget;

    try {
      if (screenshot.startsWith('data:image')) {
        final commaIdx = screenshot.indexOf(',');
        final base64Data = commaIdx != -1 ? screenshot.substring(commaIdx + 1) : screenshot;
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('Unable to load receipt image')),
        );
      } else if (screenshot.startsWith('http://') || screenshot.startsWith('https://')) {
        imageWidget = Image.network(
          screenshot,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('Unable to load receipt from web')),
        );
      } else {
        final bytes = base64Decode(screenshot);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(child: Text('Unable to decode receipt image')),
        );
      }
    } catch (_) {
      imageWidget = const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Invalid or corrupted image format', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.primaryDark,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Row(
                  children: [
                    Icon(booking.payment.method.icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receipt • ${booking.licensePlate}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                          ),
                          Text(
                            'Ref: ${booking.payment.transactionRef ?? 'N/A'} • ${booking.payment.method.displayName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  color: Colors.black.withOpacity(0.04),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: InteractiveViewer(
                    maxScale: 3.0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageWidget,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${CurrencyFormatter.format(booking.payment.amount)}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExecutiveBanner(dynamic state, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade300, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: isMobile ? 19 : 22,
              backgroundColor: AppColors.primary,
              backgroundImage: const AssetImage('assets/images/admin_profile.jpg'),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        state.tr('adminTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.green.withOpacity(0.4)),
                      ),
                      child: const Text(
                        'SUPER ADMIN',
                        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Colors.lightGreenAccent),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${state.tr("bishoftu")} • 15% Seniority Commission & Live Supabase Cloud',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: isMobile ? 10.5 : 11.5, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String sub,
    IconData icon,
    Color color, {
    String? imageUrl,
    bool isMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.28), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 11.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              imageUrl != null
                  ? AutoCareAssets.buildPhotoThumbnail(
                      imageUrl: imageUrl,
                      width: isMobile ? 32 : 36,
                      height: isMobile ? 32 : 36,
                      borderRadius: 8,
                      fallbackIcon: icon,
                      fallbackColor: color,
                    )
                  : Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: isMobile ? 16 : 18),
                    ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isMobile ? 17 : 20,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sub,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isMobile ? 9.5 : 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCashierSmsConfigCard(BuildContext context, dynamic state, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
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
          // 1. Customer Phone Call Booking Hotline
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.phone_forwarded_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Customer Phone Call Booking Hotline',
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Hotline displayed on Customer Dashboard for customers to book washes by direct phone call',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: const Text(
                  'Hotline Active',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customerPhoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.call_rounded, size: 18, color: AppColors.primary),
                    labelText: 'Customer Hotline Booking Number',
                    hintText: 'e.g. 0910046553',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Save', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                onPressed: () async {
                  final newPhone = _customerPhoneController.text.trim();
                  if (newPhone.isNotEmpty) {
                    await state.setCustomerPhoneBookingNumber(newPhone);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Customer Phone Call Booking Hotline updated to $newPhone'),
                          backgroundColor: AppColors.statusCompleted,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),

          // 2. Cashier SMS Gateway Configuration
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cashGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sms_rounded, color: AppColors.cashGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr('smsGatewayPhone'),
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Cashier phone number used to send automated wash completion SMS to customers',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cashGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cashGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.cashGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'SMS Active',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.cashGreen),
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
                child: TextField(
                  controller: _cashierPhoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.cashGreen),
                    labelText: 'Cashier Phone Number',
                    hintText: 'e.g. 0962274450',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cashGreen,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 18, vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('Update', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                onPressed: () {
                  final newPhone = _cashierPhoneController.text.trim();
                  if (newPhone.isNotEmpty) {
                    state.setCashierSmsPhone(newPhone);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Cashier SMS Phone Number updated to $newPhone'),
                        backgroundColor: AppColors.statusReady,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokCommercialReelsManagerCard(BuildContext context, dynamic state, bool isMobile) {
    final reels = state.tiktokReels as List<TikTokAdVideo>;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFE2C55).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFE2C55).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFE2C55).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.video_library_rounded, color: Color(0xFFFE2C55), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Welcome Screen TikTok Reels',
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00F2FE).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('SUPER ADMIN', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF0284C7))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Manage the rolling advertising banner on the Welcome Screen (${reels.length} reels active)',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE2C55),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.tune_rounded, size: 16),
                label: const Text('Manage Reels', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                onPressed: () => _showSuperAdminReelsDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal Preview thumbnails row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: reels.map((reel) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          color: Colors.black12,
                          child: reel.thumbnailUrl.isNotEmpty
                              ? (reel.thumbnailUrl.startsWith('assets/')
                                  ? Image.asset(
                                      reel.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.music_note, color: Colors.grey)),
                                    )
                                  : Image.network(
                                      reel.thumbnailUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.music_note, color: Colors.grey)),
                                    ))
                              : const Center(child: Icon(Icons.music_note, color: Colors.grey)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        reel.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
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

  void _showSuperAdminReelsDialog(BuildContext context, dynamic state) {
    final reels = List<TikTokAdVideo>.from(state.tiktokReels as List<TikTokAdVideo>);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.video_library_rounded, color: Color(0xFFFE2C55), size: 24),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Super Admin: TikTok Rolling Reels',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580, maxHeight: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Official Account: @bishecarwash • Manage commercial TikTok video links displayed on Welcome Screen:',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      InkWell(
                        onTap: () => UrlLauncherHelper.openUrl('https://www.tiktok.com/@bishecarwash'),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE2C55).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFE2C55).withOpacity(0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFFFE2C55)),
                              SizedBox(width: 4),
                              Text('View @bishecarwash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFE2C55))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: reels.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final reel = reels[index];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  color: Colors.black12,
                                  child: reel.thumbnailUrl.isNotEmpty
                                      ? (reel.thumbnailUrl.startsWith('assets/')
                                          ? Image.asset(
                                              reel.thumbnailUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.grey),
                                            )
                                          : Image.network(
                                              reel.thumbnailUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.grey),
                                            ))
                                      : const Icon(Icons.music_note, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${index + 1}. ${reel.title}',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      reel.tiktokUrl,
                                      style: const TextStyle(fontSize: 11, color: Color(0xFFFE2C55)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                                tooltip: 'Edit Reel',
                                onPressed: () {
                                  _editReelPopup(context, reel, (updated) {
                                    setDialogState(() {
                                      reels[index] = updated;
                                    });
                                  });
                                },
                              ),
                              if (reels.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                  tooltip: 'Delete Reel',
                                  onPressed: () {
                                    setDialogState(() {
                                      reels.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFE2C55),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text('1-Click Sync All to @bishecarwash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        onPressed: () async {
                          final synced = <TikTokAdVideo>[];
                          final count = AutoCareAssets.officialTikTokVideos.length;
                          for (int i = 0; i < count; i++) {
                            final poolItem = AutoCareAssets.curatedReelsPool[i % AutoCareAssets.curatedReelsPool.length];
                            synced.add(TikTokAdVideo(
                              id: 'reel-${i + 1}',
                              title: poolItem['title']!,
                              subtitle: poolItem['subtitle']!,
                              tiktokUrl: AutoCareAssets.officialTikTokVideos[i],
                              thumbnailUrl: poolItem['url']!,
                            ));
                          }
                          setDialogState(() {
                            reels.clear();
                            reels.addAll(synced);
                          });
                          await state.setTikTokReels(reels);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('All ${synced.length} official @bishecarwash videos synced with direct links & HD photos!'),
                                backgroundColor: AppColors.statusReady,
                              ),
                            );
                          }
                        },
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFE2C55),
                          side: const BorderSide(color: Color(0xFFFE2C55)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: () => _showBatchImportDialog(context, reels, setDialogState, state),
                        icon: const Icon(Icons.playlist_add_rounded, size: 16),
                        label: const Text('Batch Paste Links', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        onPressed: () {
                          final nextIndex = reels.length;
                          final poolItem = AutoCareAssets.curatedReelsPool[nextIndex % AutoCareAssets.curatedReelsPool.length];
                          final newReel = TikTokAdVideo(
                            id: 'reel-${nextIndex + 1}',
                            title: poolItem['title']!,
                            subtitle: poolItem['subtitle']!,
                            tiktokUrl: 'https://www.tiktok.com/@bishecarwash',
                            thumbnailUrl: poolItem['url']!,
                          );
                          _editReelPopup(context, newReel, (created) {
                            setDialogState(() {
                              reels.add(created);
                            });
                          });
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Another Reel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE2C55),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  await state.setTikTokReels(reels);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('TikTok rolling reels updated & synced to cloud!'),
                        backgroundColor: AppColors.statusReady,
                      ),
                    );
                  }
                },
                child: const Text('Save All Reels'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _editReelPopup(BuildContext context, TikTokAdVideo reel, void Function(TikTokAdVideo) onSaved) {
    final state = AppStateProvider.read(context);
    final titleCtrl = TextEditingController(text: reel.title);
    final subCtrl = TextEditingController(text: reel.subtitle);
    final linkCtrl = TextEditingController(text: reel.tiktokUrl);
    final thumbCtrl = TextEditingController(text: reel.thumbnailUrl);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          Widget buildPoolChip(Map<String, String> p) {
            final isSel = thumbCtrl.text == p['url'];
            return InkWell(
              onTap: () {
                setDialogState(() {
                  thumbCtrl.text = p['url']!;
                  if (titleCtrl.text.isEmpty || titleCtrl.text.startsWith('New Detailing')) {
                    titleCtrl.text = p['title']!;
                    subCtrl.text = p['subtitle']!;
                  }
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSel ? const Color(0xFFFE2C55).withOpacity(0.12) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSel ? const Color(0xFFFE2C55) : AppColors.cardBorder,
                    width: isSel ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: p['url']!.startsWith('assets/')
                          ? Image.asset(
                              p['url']!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.photo, size: 14),
                            )
                          : Image.network(
                              p['url']!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.photo, size: 14),
                            ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      p['label']!,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                        color: isSel ? const Color(0xFFFE2C55) : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text('Edit TikTok Reel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Title / Highlight', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: subCtrl,
                      decoration: const InputDecoration(labelText: 'Subtitle / Description', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Video Source', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                        InkWell(
                          onTap: () {
                            setDialogState(() {
                              if (linkCtrl.text.isEmpty || !linkCtrl.text.contains('@bishecarwash')) {
                                linkCtrl.text = 'https://www.tiktok.com/@bishecarwash';
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE2C55).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Use @bishecarwash', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFFE2C55))),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: linkCtrl,
                            decoration: const InputDecoration(
                              labelText: 'TikTok Video Link',
                              hintText: 'https://www.tiktok.com/@bishecarwash/... or https://vt.tiktok.com/...',
                              prefixIcon: Icon(Icons.link_rounded),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: 'Test Link in TikTok',
                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                          onPressed: () {
                            final testUrl = UrlLauncherHelper.cleanUrl(linkCtrl.text);
                            if (testUrl.isNotEmpty) {
                              UrlLauncherHelper.openUrl(testUrl);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please paste a valid TikTok link first')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: thumbCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Thumbnail Image URL / Asset',
                        hintText: 'assets/images/ad_reel_1.jpg',
                        prefixIcon: Icon(Icons.image_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.tr('curatedReelsPoolTitle'),
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    // Section 1: Official Bishe Branding Artworks (First 8)
                    Text(
                      '🎨 ${state.tr('curatedPoolArtworks')}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AutoCareAssets.curatedReelsPool.take(8).map((p) => buildPoolChip(p)).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Section 2: Commercial Detailing & Carpet Ad Banners (Next 8)
                    Text(
                      '📢 ${state.tr('curatedPoolAdBanners')}',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFFE2C55)),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AutoCareAssets.curatedReelsPool.skip(8).map((p) => buildPoolChip(p)).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFE2C55), foregroundColor: Colors.white),
                onPressed: () {
                  final cleaned = UrlLauncherHelper.sanitizeTikTokUrl(linkCtrl.text);
                  if (cleaned.isNotEmpty) {
                    onSaved(
                      reel.copyWith(
                        title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : reel.title,
                        subtitle: subCtrl.text.trim().isNotEmpty ? subCtrl.text.trim() : reel.subtitle,
                        tiktokUrl: cleaned,
                        thumbnailUrl: thumbCtrl.text.trim().isNotEmpty ? thumbCtrl.text.trim() : reel.thumbnailUrl,
                      ),
                    );
                    Navigator.pop(ctx);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid TikTok link or username')),
                    );
                  }
                },
                child: const Text('Save Reel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBatchImportDialog(BuildContext context, List<TikTokAdVideo> reels, StateSetter setDialogState, dynamic state) {
    final batchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (batchCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.playlist_add_rounded, color: Color(0xFFFE2C55)),
            SizedBox(width: 8),
            Text('Batch Paste TikTok Links', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste multiple TikTok video URLs below (one link per line or separated by spaces/commas). They will be automatically linked to showcase reels with matching HD photography.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: batchCtrl,
                minLines: 5,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'https://www.tiktok.com/@bishecarwash/video/7703232736168791303\nhttps://www.tiktok.com/@bishecarwash/video/7703201662713728274\n...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(batchCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFE2C55),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.download_done_rounded, size: 16),
            label: const Text('Import Links', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () async {
              final urls = UrlLauncherHelper.extractUrls(batchCtrl.text);
              if (urls.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No valid TikTok URLs detected in pasted text.')),
                );
                return;
              }
              final pool = AutoCareAssets.curatedReelsPool;
              final imported = <TikTokAdVideo>[];
              for (int i = 0; i < urls.length; i++) {
                final poolItem = pool[i % pool.length];
                if (i < reels.length) {
                  imported.add(reels[i].copyWith(
                    tiktokUrl: urls[i],
                    thumbnailUrl: reels[i].thumbnailUrl.isNotEmpty ? reels[i].thumbnailUrl : poolItem['url']!,
                  ));
                } else {
                  imported.add(TikTokAdVideo(
                    id: 'reel-${i + 1}',
                    title: poolItem['title']!,
                    subtitle: poolItem['subtitle']!,
                    tiktokUrl: urls[i],
                    thumbnailUrl: poolItem['url']!,
                  ));
                }
              }
              if (reels.length > urls.length) {
                for (int i = urls.length; i < reels.length; i++) {
                  imported.add(reels[i]);
                }
              }
              setDialogState(() {
                reels.clear();
                reels.addAll(imported);
              });
              await state.setTikTokReels(reels);
              if (batchCtx.mounted) Navigator.pop(batchCtx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully imported ${urls.length} video links! Thumbnails preserved.'),
                    backgroundColor: AppColors.statusReady,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOtpShiftHandoverDesk(BuildContext context, dynamic state, bool isMobile) {
    final dayClosing = state.latestDayClosing;
    final nightClosing = state.latestNightClosing;
    final pendingNight = state.pendingAdminNightHandover;
    final anyPendingDay = state.pendingCashierAdminHandover ?? state.pendingCashierHandover;

    final isDayPending = anyPendingDay != null && !anyPendingDay.isHandoverAccepted;
    final isDayReconciled = dayClosing != null && dayClosing.isHandoverAccepted;

    final isNightPending = pendingNight != null && !pendingNight.isHandoverAccepted;
    final isNightReconciled = nightClosing != null && nightClosing.isHandoverAccepted;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.vpn_key_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.tr('shiftHandoverDesk'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isMobile ? 13 : 14.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield_rounded, size: 11, color: Color(0xFF10B981)),
                    const SizedBox(width: 4),
                    Text(
                      state.tr('threePartyCustody'),
                      style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF10B981)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 1. CASHIER OTP DESK CARD (PERMANENTLY VISIBLE)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDayPending
                  ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
                  : (isDayReconciled ? const Color(0xFF10B981).withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDayPending
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.6)
                    : (isDayReconciled ? const Color(0xFF10B981).withValues(alpha: 0.35) : AppColors.cardBorder),
                width: isDayPending ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.wb_sunny_rounded, color: Color(0xFFD97706), size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.tr('cashierHandoverVerification'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFFB45309)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDayPending
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                            : (isDayReconciled ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isDayPending
                            ? 'PENDING CASHIER OTP'
                            : (isDayReconciled ? 'RECONCILED' : 'DAY SHIFT ACTIVE'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isDayPending
                              ? const Color(0xFFB45309)
                              : (isDayReconciled ? const Color(0xFF047857) : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isDayPending
                      ? 'Cashier ${anyPendingDay.cashierName} closed day shift • Cash to Handover: ${CurrencyFormatter.format(anyPendingDay.handoverCashAmount > 0 ? anyPendingDay.handoverCashAmount : anyPendingDay.cashRemaining)}. Enter Cashier 4-digit OTP to confirm custody:'
                      : (isDayReconciled
                          ? 'Day shift reconciled: ${CurrencyFormatter.format(dayClosing.cashRemaining)} • Handed over to ${dayClosing.acceptedByName ?? "Admin"} via OTP [ ${dayClosing.handoverOtp ?? "----"} ]'
                          : 'Day shift active. Enter the 4-digit OTP sent by Cashier to verify and take cash custody:'),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 40,
                      child: TextField(
                        controller: _adminCashierOtpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 4),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'OTP',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFF59E0B))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isDayPending ? const Color(0xFFF59E0B) : AppColors.cardBorder)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFD97706), width: 2)),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleInlineAdminVerifyCashier(context, state),
                      icon: const Icon(Icons.check_circle_rounded, size: 15, color: Colors.white),
                      label: Text(
                        state.tr('confirmCashierHandover'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. OPERATIONAL MANAGER OTP DESK CARD (PERMANENTLY VISIBLE)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isNightPending
                  ? const Color(0xFF4338CA).withValues(alpha: 0.08)
                  : (isNightReconciled ? const Color(0xFF10B981).withValues(alpha: 0.05) : AppColors.surfaceVariant.withValues(alpha: 0.6)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNightPending
                    ? const Color(0xFF818CF8).withValues(alpha: 0.6)
                    : (isNightReconciled ? const Color(0xFF10B981).withValues(alpha: 0.35) : AppColors.cardBorder),
                width: isNightPending ? 1.5 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.shield_moon_rounded, color: Color(0xFF4338CA), size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.tr('managerHandoverVerification'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Color(0xFF3730A3)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isNightPending
                            ? const Color(0xFF4338CA).withValues(alpha: 0.2)
                            : (isNightReconciled ? const Color(0xFF10B981).withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isNightPending
                            ? 'PENDING VAULT SEAL'
                            : (isNightReconciled ? 'SEALED IN VAULT' : 'NIGHT SHIFT ACTIVE'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: isNightPending
                              ? const Color(0xFF3730A3)
                              : (isNightReconciled ? const Color(0xFF047857) : AppColors.textSecondary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isNightPending
                      ? 'Op Manager ${pendingNight.cashierName} closed night shift • Combined Cash: ${CurrencyFormatter.format(pendingNight.handoverCashAmount)}. Enter Manager 4-digit OTP to seal cash in Admin Vault:'
                      : (isNightReconciled
                          ? 'Night shift cash sealed in Vault: ${CurrencyFormatter.format(nightClosing.handoverCashAmount)} • Verified by Admin via OTP [ ${nightClosing.handoverOtp ?? "----"} ]'
                          : 'Night shift active. Enter the 4-digit OTP sent by Op Manager to confirm physical cash and seal into Vault:'),
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 40,
                      child: TextField(
                        controller: _adminNightOtpController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 4),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'OTP',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF818CF8))),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: isNightPending ? const Color(0xFF818CF8) : AppColors.cardBorder)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF4338CA), width: 2)),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _handleInlineAdminVerifyNight(context, state),
                      icon: const Icon(Icons.vpn_key_rounded, size: 15, color: Colors.white),
                      label: Text(
                        state.tr('confirmManagerNightCash'),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4338CA),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleInlineAdminVerifyCashier(BuildContext context, dynamic state) async {
    final entered = _adminCashierOtpController.text.trim();
    if (entered.isEmpty || entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit Cashier OTP code.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final anyPending = state.pendingCashierAdminHandover ?? state.pendingCashierHandover;
    if (anyPending == null) {
      if (state.latestDayClosing?.isHandoverAccepted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.tr('alreadyVerifiedClosing')), backgroundColor: Colors.orange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.tr('noPendingClosingToVerify')), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    final success = await state.acceptAdminHandover(
      adminName: state.activeStaffFullName ?? 'Admin Owner',
      enteredOtp: entered,
      shiftType: 'day',
    );

    if (success) {
      _adminCashierOtpController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('handoverSuccess')),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('invalidOtpCode')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleInlineAdminVerifyNight(BuildContext context, dynamic state) async {
    final entered = _adminNightOtpController.text.trim();
    if (entered.isEmpty || entered.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit Manager OTP code.'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final pending = state.pendingAdminNightHandover;
    if (pending == null) {
      if (state.latestNightClosing?.isHandoverAccepted == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.tr('alreadyVerifiedClosing')), backgroundColor: Colors.indigo),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.tr('noPendingClosingToVerify')), backgroundColor: Colors.redAccent),
        );
      }
      return;
    }

    final success = await state.acceptAdminHandover(
      adminName: state.activeStaffFullName ?? 'Admin Owner',
      enteredOtp: entered,
      shiftType: 'night',
    );

    if (success) {
      _adminNightOtpController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('handoverSuccess')),
            backgroundColor: AppColors.statusCompleted,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.tr('invalidOtpCode')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _confirmAcceptManagerNightCash(BuildContext context, dynamic state) async {
    final pending = state.pendingAdminNightHandover;
    if (pending == null) return;

    final otpController = TextEditingController();
    String? errorMessage;

    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('enterHandoverOtp'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Count ${CurrencyFormatter.format(pending.handoverCashAmount)} physical cash from Operational Manager ${pending.cashierName}, then enter the 4-digit code given by the manager.',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8, color: AppColors.primary),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: const TextStyle(letterSpacing: 8, color: AppColors.textMuted),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  errorText: errorMessage,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final otp = otpController.text.trim();
                final ok = await state.acceptAdminHandover(
                  adminName: state.activeStaffFullName ?? 'Admin / Owner',
                  enteredOtp: otp,
                );
                if (ok) {
                  Navigator.pop(ctx, true);
                } else {
                  setDialogState(() {
                    errorMessage = state.tr('invalidOtpCode');
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cashGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                state.tr('verifyAndTakeCustody'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );

    if (accepted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr('handoverSuccess')),
          backgroundColor: AppColors.statusReady,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
