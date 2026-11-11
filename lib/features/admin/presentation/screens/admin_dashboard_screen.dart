import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/combined_service_header_banner.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../welcome/domain/models/tiktok_ad_video.dart';
import '../../domain/models/weekly_commission_report.dart';
import '../widgets/admin_feedback_moderation_card.dart';
import 'credentials_management_screen.dart';
import 'pricing_management_screen.dart';
import 'staff_management_screen.dart';

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
        return state.tr('filterByDate');
    }
  }
}

class _AdminActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String? imageUrl;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _AdminActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.imageUrl,
    required this.color,
    this.badge,
    required this.onTap,
  });
}

/// Streamlined 3-Tab Executive Admin Action Desk:
/// - Top Priority Alerts & Active OTP Verification Cards (only surfaced when action is needed)
/// - Tab 0: Overview & Cash (Time filter, Health gauges, KPIs, P&L, Shift custody, Reports/History)
/// - Tab 1: Pricing & Team (Pricing/Inventory, Staff, Security PINs, Clear All, Commission Hub, Weekly Reports)
/// - Tab 2: Customers & Ads (Feedback moderation, Digital Receipts audit, Hotline & SMS, TikTok Reels)
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  AdminTimeFilter _selectedFilter = AdminTimeFilter.today;
  DateTime? _selectedCustomDate;
  String _washerCommissionFilter = 'Weekly'; // Daily, Weekly, Date Range
  late final TextEditingController _cashierPhoneController;
  late final TextEditingController _customerPhoneController;
  final _adminCashierOtpController = TextEditingController();
  final _adminNightOtpController = TextEditingController();
  bool _phoneControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging && mounted) {
        setState(() {});
      }
    });
    _cashierPhoneController = TextEditingController();
    _customerPhoneController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cashierPhoneController.dispose();
    _customerPhoneController.dispose();
    _adminCashierOtpController.dispose();
    _adminNightOtpController.dispose();
    super.dispose();
  }

  bool _matchesFilter(DateTime dt) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case AdminTimeFilter.today:
        return dt.year == now.year && dt.month == now.month && dt.day == now.day;
      case AdminTimeFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final startMonday = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return !dt.isBefore(startMonday);
      case AdminTimeFilter.thisMonth:
        return dt.year == now.year && dt.month == now.month;
      case AdminTimeFilter.customDate:
        final target = _selectedCustomDate ?? now;
        return dt.year == target.year && dt.month == target.month && dt.day == target.day;
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

    // Consistent period calculations across car washes, carpets, showers, tips & OpEx
    // Attributed by actual collection date (paidAt ?? createdAt) for postponed carry-overs.
    final allBookings = state.bookings;
    final paidBookings = allBookings
        .where((b) => b.payment.isPaid && _matchesFilter(b.payment.paidAt ?? b.createdAt))
        .toList();
    final completedCars = allBookings
        .where((b) => b.status == WashStatus.completed && _matchesFilter(b.completedAt ?? b.createdAt))
        .length;

    final filteredShowers = state.showerRecords.where((s) => _matchesFilter(s.recordedAt)).toList();
    final serviceRevenue = paidBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final tipsRevenue = paidBookings.fold<double>(0.0, (sum, b) => sum + b.payment.tipAmount);
    final showerRevenue = filteredShowers.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
    final totalRevenue = serviceRevenue + tipsRevenue + showerRevenue;

    final totalPettyCash = state.pettyCashExpenses
        .where((e) => _matchesFilter(e.loggedAt))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    final totalSupplies = state.stockTransactions
        .where((t) =>
            _matchesFilter(t.date) &&
            (t.type == 'receiveStock' || t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption'))
        .fold<double>(0.0, (sum, t) => sum + t.totalCostEtb);
    final commissionPool = (serviceRevenue * state.teamCommissionRate) + tipsRevenue;
    final netProfit = totalRevenue - commissionPool - totalPettyCash;

    final digitalBookings = paidBookings.where((b) => b.payment.method.isDigital).toList();

    final anyPendingDay = state.pendingCashierAdminHandover ?? state.pendingCashierHandover;
    final pendingNight = state.pendingAdminNightHandover;
    final hasActiveOtpPending =
        (anyPendingDay != null && !anyPendingDay.isHandoverAccepted) ||
        (pendingNight != null && !pendingNight.isHandoverAccepted);

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
            horizontal: isDesktop ? 28 : (isMobile ? 12 : 20),
            vertical: isMobile ? 10 : 16,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CombinedServiceHeaderBanner(
                    title: state.tr('adminCombinedHeader'),
                    subtitle: state.tr('adminCombinedSub'),
                    badgeText: state.tr('unifiedDesk'),
                    padding: const EdgeInsets.only(bottom: 12),
                  ),

                  if (state.hasNewCashierClosingAlert && state.latestClosingAlert != null)
                    _buildClosingAlertBanner(context, state),

                  // Actionable Handover OTP Card(s) — only pinned at top when verification is pending
                  if (hasActiveOtpPending) ...[
                    _buildActiveHandoverCards(context, state, anyPendingDay, pendingNight),
                    const SizedBox(height: 12),
                  ],

                  // Pending Secondary Admin Approvals (only when present)
                  _buildPendingApprovalsBanner(context, state),

                  // Clean 3-Tab Executive Action Bar
                  _buildAdminTabBar(state, digitalBookings.length, isMobile),
                  const SizedBox(height: 14),

                  if (_tabController.index == 0)
                    _buildOverviewAndCashTab(
                      context,
                      state,
                      isMobile,
                      completedCars,
                      totalRevenue,
                      commissionPool,
                      netProfit,
                      totalPettyCash,
                      totalSupplies,
                      anyPendingDay,
                      pendingNight,
                    )
                  else if (_tabController.index == 1)
                    _buildPricingAndTeamTab(context, state, isMobile)
                  else
                    _buildCustomersAndAdsTab(context, state, isMobile, digitalBookings),

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP ALERTS & 3-TAB NAVIGATION BAR
  // ===========================================================================

  Widget _buildClosingAlertBanner(BuildContext context, dynamic state) {
    final alert = state.latestClosingAlert!;
    final isNight = alert.shiftType == 'night';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF115E59)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: Colors.greenAccent, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isNight ? state.tr('nightClosingConfirmed') : state.tr('dailyClosingConfirmed'),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
                Text(
                  '${alert.cashierName} • ${CurrencyFormatter.format(alert.handoverCashAmount)} • ${CurrencyFormatter.format(alert.grossRevenue)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => state.dismissCashierClosingAlert(),
            icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            tooltip: state.tr('close'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveHandoverCards(
    BuildContext context,
    dynamic state,
    dynamic anyPendingDay,
    dynamic pendingNight,
  ) {
    final isDayPending = anyPendingDay != null && !anyPendingDay.isHandoverAccepted;
    final isNightPending = pendingNight != null && !pendingNight.isHandoverAccepted;

    return Column(
      children: [
        if (isDayPending)
          _buildSingleOtpVerificationCard(
            context: context,
            state: state,
            controller: _adminCashierOtpController,
            title: state.tr('cashierHandoverVerification'),
            badgeText: state.tr('pendingDayOtpBadge'),
            subtitle: [
              '${anyPendingDay.cashierName} • ${CurrencyFormatter.format(anyPendingDay.handoverCashAmount > 0 ? anyPendingDay.handoverCashAmount : anyPendingDay.cashRemaining)}',
              if (anyPendingDay.notes != null && anyPendingDay.notes.toString().trim().isNotEmpty)
                anyPendingDay.notes.toString().trim(),
            ].join('\n'),
            buttonLabel: state.tr('confirmCashierHandover'),
            accentColor: const Color(0xFFD97706),
            icon: Icons.wb_sunny_rounded,
            onVerify: () => _handleInlineAdminVerifyCashier(context, state),
          ),
        if (isDayPending && isNightPending) const SizedBox(height: 10),
        if (isNightPending)
          _buildSingleOtpVerificationCard(
            context: context,
            state: state,
            controller: _adminNightOtpController,
            title: state.tr('managerHandoverVerification'),
            badgeText: state.tr('pendingVaultSealBadge'),
            subtitle: [
              '${pendingNight.cashierName} • ${CurrencyFormatter.format(pendingNight.handoverCashAmount)}',
              if (pendingNight.notes != null && pendingNight.notes.toString().trim().isNotEmpty)
                pendingNight.notes.toString().trim(),
            ].join('\n'),
            buttonLabel: state.tr('confirmManagerNightCash'),
            accentColor: const Color(0xFF4338CA),
            icon: Icons.shield_moon_rounded,
            onVerify: () => _handleInlineAdminVerifyNight(context, state),
          ),
      ],
    );
  }

  Widget _buildSingleOtpVerificationCard({
    required BuildContext context,
    required dynamic state,
    required TextEditingController controller,
    required String title,
    required String badgeText,
    required String subtitle,
    required String buttonLabel,
    required Color accentColor,
    required IconData icon,
    required VoidCallback onVerify,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: accentColor),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              SizedBox(
                width: 122,
                height: 40,
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 4),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: state.tr('enterOtp'),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onVerify,
                  icon: const Icon(Icons.vpn_key_rounded, size: 16),
                  label: Text(
                    buttonLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildAdminTabBar(dynamic state, int digitalCount, bool isMobile) {
    final pendingFeedbackCount = (state.pendingCustomerFeedback as List).length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: [
          _buildCompactTab(
            icon: Icons.insights_rounded,
            label: state.tr('adminTabOverviewCash'),
            isMobile: isMobile,
          ),
          _buildCompactTab(
            icon: Icons.tune_rounded,
            label: state.tr('adminTabPricingTeam'),
            isMobile: isMobile,
          ),
          _buildCompactTab(
            icon: Icons.campaign_rounded,
            label: pendingFeedbackCount > 0
                ? '${state.tr("adminTabCustomersAds")} ($pendingFeedbackCount)'
                : '${state.tr("adminTabCustomersAds")} ($digitalCount)',
            isMobile: isMobile,
          ),
        ],
      ),
    );
  }

  Tab _buildCompactTab({required IconData icon, required String label, required bool isMobile}) {
    return Tab(
      height: 40,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isMobile ? 15 : 16),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: isMobile ? 11.5 : 12.5),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: OVERVIEW & CASH
  // ===========================================================================

  Widget _buildOverviewAndCashTab(
    BuildContext context,
    dynamic state,
    bool isMobile,
    int completedCars,
    double totalRevenue,
    double commissionPool,
    double netProfit,
    double totalPettyCash,
    double totalSupplies,
    dynamic anyPendingDay,
    dynamic pendingNight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExecutiveBanner(state, isMobile),
        const SizedBox(height: 12),

        _buildTimeFilterBar(state),
        const SizedBox(height: 12),

        // 4 Financial & Operational KPIs
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final isMedium = constraints.maxWidth >= 550 && !isWide;
            final childAspectRatio = isWide
                ? 1.65
                : (isMedium ? 1.55 : (constraints.maxWidth < 360 ? 1.25 : 1.38));

            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
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
                  '${(state.teamCommissionRate * 100).toStringAsFixed(0)}% ${state.tr("teamPoolLabel")}',
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
                  '${state.presentWashersCount} ${state.tr("onDutyCountLabel")}',
                  '${state.totalWashersCount} ${state.tr("totalWashersLabel")}',
                  Icons.groups_rounded,
                  AppColors.secondary,
                  imageUrl: AutoCareAssets.valetDriverUrl,
                  isMobile: isMobile,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // Quick Financial Reports & Wash History shortcuts
        _buildActionPairRow(
          isMobile: isMobile,
          items: [
            _AdminActionItem(
              title: state.tr('closingAndFinancialReports'),
              subtitle: state.tr('financialReportsAuditDesc'),
              icon: Icons.fact_check_rounded,
              imageUrl: AutoCareAssets.packageTireRimUrl,
              color: AppColors.cashGreen,
              badge: '${state.dailyFinancialClosings.length}',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialReportsView())),
            ),
            _AdminActionItem(
              title: state.tr('washHistory'),
              subtitle: state.tr('washHistoryAuditDesc'),
              icon: Icons.history_edu_rounded,
              imageUrl: AutoCareAssets.welcomeHeroUrl,
              color: AppColors.telebirrBlue,
              badge: '$completedCars',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VehicleHistoryScreen())),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Shift Custody Audit Summary (replaces redundant idle OTP walls)
        _buildShiftCustodyAuditCard(context, state, anyPendingDay, pendingNight),
        const SizedBox(height: 12),

        // Full Profit & Loss Statement directly visible on Overview
        _buildStandardFinancialStatementCard(
          context,
          state,
          isMobile,
          totalRevenue,
          commissionPool,
          totalPettyCash,
          totalSupplies,
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 1: PRICING & TEAM
  // ===========================================================================

  Widget _buildPricingAndTeamTab(BuildContext context, dynamic state, bool isMobile) {
    final coreActions = [
      _AdminActionItem(
        title: state.tr('masterPricingAndInventory'),
        subtitle: state.tr('editTariffsInventorySub'),
        icon: Icons.tune_rounded,
        imageUrl: AutoCareAssets.carSedanUrl,
        color: AppColors.primary,
        badge: '${state.serviceItems.length + state.consumables.length + state.fixedAssets.length}',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PricingManagementScreen())),
      ),
      _AdminActionItem(
        title: state.tr('staffPayroll'),
        subtitle: state.tr('staffPayrollSub'),
        icon: Icons.badge_rounded,
        imageUrl: AutoCareAssets.mobileVanUrl,
        color: AppColors.secondary,
        badge: '${state.staff.length}',
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffManagementScreen())),
      ),
      _AdminActionItem(
        title: state.tr('staffPins'),
        subtitle: state.tr('staffPinsSub'),
        icon: Icons.pin_outlined,
        imageUrl: AutoCareAssets.carCockpitUrl,
        color: AppColors.accent,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CredentialsManagementScreen())),
      ),
      if (state.isSuperAdmin)
        _AdminActionItem(
          title: state.tr('clearAllBookings'),
          subtitle: state.tr('clearAllBookingsSubtitle'),
          icon: Icons.delete_sweep_rounded,
          imageUrl: AutoCareAssets.packageSteamEngineUrl,
          color: Colors.red.shade700,
          badge: '${state.bookings.length}',
          onTap: () => _confirmClearAllBookings(context, state),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResponsiveActionGrid(coreActions, isMobile),
        const SizedBox(height: 14),
        SharedWasherCommissionHub(
          state: state,
          role: WasherHubRole.admin,
          isMobile: isMobile,
          initiallyExpanded: true,
          respectInitiallyExpanded: true,
        ),
        const SizedBox(height: 14),
        _buildWeeklyWasherCommissionReportSection(context, state, isMobile),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: CUSTOMERS & ADS
  // ===========================================================================

  Widget _buildCustomersAndAdsTab(
    BuildContext context,
    dynamic state,
    bool isMobile,
    List<WashBooking> digitalBookings,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AdminFeedbackModerationCard(),
        const SizedBox(height: 14),
        _buildDigitalReceiptsSection(context, state, digitalBookings, isMobile),
        const SizedBox(height: 14),
        _buildCashierSmsConfigCard(context, state, isMobile),
        const SizedBox(height: 14),
        _buildTikTokCommercialReelsManagerCard(context, state, isMobile),
      ],
    );
  }

  // ===========================================================================
  // SHIFT CUSTODY SUMMARY & STRICT OTP VERIFICATION
  // ===========================================================================

  Widget _buildShiftCustodyAuditCard(
    BuildContext context,
    dynamic state,
    dynamic anyPendingDay,
    dynamic pendingNight,
  ) {
    final dayClosing = state.latestDayClosing;
    final nightClosing = state.latestNightClosing;

    final isDayPending = anyPendingDay != null && !anyPendingDay.isHandoverAccepted;
    final isDayReconciled = dayClosing != null && dayClosing.isHandoverAccepted;
    final isNightPending = pendingNight != null && !pendingNight.isHandoverAccepted;
    final isNightReconciled = nightClosing != null && nightClosing.isHandoverAccepted;

    return Container(
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
            children: [
              const Icon(Icons.shield_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('shiftHandoverDesk'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  state.tr('threePartyCustody'),
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Color(0xFF047857)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildShiftStatusTile(
            icon: Icons.wb_sunny_rounded,
            title: state.tr('cashierHandoverVerification'),
            badge: isDayPending
                ? state.tr('pendingDayOtpBadge')
                : (isDayReconciled ? state.tr('reconciledBadge') : state.tr('dayShiftActiveBadge')),
            color: isDayPending
                ? const Color(0xFFD97706)
                : (isDayReconciled ? const Color(0xFF047857) : AppColors.textSecondary),
            subtitle: isDayReconciled
                ? '${CurrencyFormatter.format(dayClosing.cashRemaining)} • ${dayClosing.acceptedByName ?? "Admin"}'
                : '${state.tr("physicalCashInDrawer")}: ${CurrencyFormatter.format(state.undepositedCashTodayETB)}',
          ),
          const SizedBox(height: 8),
          _buildShiftStatusTile(
            icon: Icons.shield_moon_rounded,
            title: state.tr('managerHandoverVerification'),
            badge: isNightPending
                ? state.tr('pendingVaultSealBadge')
                : (isNightReconciled ? state.tr('sealedInVaultBadge') : state.tr('nightShiftActiveBadge')),
            color: isNightPending
                ? const Color(0xFF4338CA)
                : (isNightReconciled ? const Color(0xFF047857) : AppColors.textSecondary),
            subtitle: isNightReconciled
                ? '${CurrencyFormatter.format(nightClosing.handoverCashAmount)} • ${nightClosing.acceptedByName ?? "Admin"}'
                : '${state.tr("dayShiftHandoverCashLabel")} ${CurrencyFormatter.format(state.managerCarriedCashETB)}',
          ),
          if ((state.carryOverAuditBookings as List).isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildShiftStatusTile(
              icon: Icons.schedule_send_rounded,
              title: state.tr('carryOverAuditTitle'),
              badge: '${(state.carryOverAuditBookings as List).length}',
              color: const Color(0xFFD97706),
              subtitle: (state.carryOverAuditBookings as List)
                  .map((b) => '${b.licensePlate}${b.payment.isPaid ? " [PAID]" : ""}')
                  .take(4)
                  .join(', '),
            ),
          ],
          if (state.closingCloudSyncError != null) ...[
            const SizedBox(height: 8),
            _buildShiftStatusTile(
              icon: Icons.warning_amber_rounded,
              title: 'Supabase RLS',
              badge: '42501',
              color: const Color(0xFFB45309),
              subtitle: state.tr('closingCloudSyncRlsWarning'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShiftStatusTile({
    required IconData icon,
    required String title,
    required String badge,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: color)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleInlineAdminVerifyCashier(BuildContext context, dynamic state) async {
    final entered = _adminCashierOtpController.text.trim();
    if (entered.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('enterFourDigitOtpError')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final anyPending = state.pendingCashierAdminHandover ?? state.pendingCashierHandover;
    if (anyPending == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.latestDayClosing?.isHandoverAccepted == true
                ? state.tr('alreadyVerifiedClosing')
                : state.tr('noPendingClosingToVerify'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if ((anyPending.handoverOtp ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('otpMissingOrCorruptError')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await state.acceptAdminHandover(
      adminName: state.activeStaffFullName ?? 'Admin Owner',
      enteredOtp: entered,
      shiftType: 'day',
    );

    if (!context.mounted) return;
    if (success) {
      _adminCashierOtpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('handoverSuccess')), backgroundColor: AppColors.statusCompleted),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('invalidOtpCode')), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _handleInlineAdminVerifyNight(BuildContext context, dynamic state) async {
    final entered = _adminNightOtpController.text.trim();
    if (entered.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('enterFourDigitManagerOtpError')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final pending = state.pendingAdminNightHandover;
    if (pending == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.latestNightClosing?.isHandoverAccepted == true
                ? state.tr('alreadyVerifiedClosing')
                : state.tr('noPendingClosingToVerify'),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if ((pending.handoverOtp ?? '').trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('otpMissingOrCorruptError')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final success = await state.acceptAdminHandover(
      adminName: state.activeStaffFullName ?? 'Admin Owner',
      enteredOtp: entered,
      shiftType: 'night',
    );

    if (!context.mounted) return;
    if (success) {
      _adminNightOtpController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('handoverSuccess')), backgroundColor: AppColors.statusCompleted),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('invalidOtpCode')), backgroundColor: Colors.redAccent),
      );
    }
  }

  // ===========================================================================
  // EXECUTIVE BANNER, FILTERS, KPIS & P&L
  // ===========================================================================

  Widget _buildExecutiveBanner(dynamic state, bool isMobile) {
    final isSuper = state.isSuperAdmin as bool;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.shade300, width: 2),
            ),
            child: CircleAvatar(
              radius: isMobile ? 18 : 21,
              backgroundColor: AppColors.primary,
              backgroundImage: const AssetImage('assets/images/admin_profile.jpg'),
            ),
          ),
          SizedBox(width: isMobile ? 10 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        state.activeStaffFullName != null && (state.activeStaffFullName as String).isNotEmpty
                            ? state.activeStaffFullName
                            : state.tr('adminTitle'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: isMobile ? 14 : 15, fontWeight: FontWeight.w900, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: (isSuper ? Colors.green : Colors.amber).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: (isSuper ? Colors.green : Colors.amber).withValues(alpha: 0.45)),
                      ),
                      child: Text(
                        isSuper ? state.tr('superAdminRoleBadge') : state.tr('secondaryAdminRoleBadge'),
                        style: TextStyle(
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          color: isSuper ? Colors.lightGreenAccent : Colors.amberAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  state.tr('bishoftu'),
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
                    if (picked != null && mounted) {
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

  Widget _buildMetricCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color, {
    String? imageUrl,
    required bool isMobile,
  }) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 11 : 14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              imageUrl != null
                  ? AutoCareAssets.buildPhotoThumbnail(
                      imageUrl: imageUrl,
                      width: isMobile ? 32 : 36,
                      height: isMobile ? 32 : 36,
                      borderRadius: 9,
                      fallbackIcon: icon,
                      fallbackColor: color,
                    )
                  : Icon(icon, color: color, size: 22),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: isMobile ? 11 : 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(fontSize: isMobile ? 16.5 : 18, fontWeight: FontWeight.w900, color: color),
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
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
  ) {
    final cogs = commissionPool + totalSupplies;
    final grossProfit = totalRevenue - cogs;
    final netOperatingProfit = grossProfit - totalPettyCash;
    final monthlySalaryObligation = state.monthlyTotalBaseSalary as double;
    final netRetainedProfit = netOperatingProfit - monthlySalaryObligation;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
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
                    Text(
                      state.tr('pnlStatementTitle'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('pnlStatementSub'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (netOperatingProfit >= 0 ? AppColors.statusReady : AppColors.statusCancelled).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  netOperatingProfit >= 0 ? state.tr('profitableBadge') : state.tr('deficitBadge'),
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
          _buildStatementRow(state.tr('grossRevenueRow'), CurrencyFormatter.format(totalRevenue), Colors.green.shade800, isHeader: true),
          const SizedBox(height: 6),
          _buildStatementRow(state.tr('cogsRow'), '- ${CurrencyFormatter.format(cogs)}', Colors.orange.shade900, isHeader: true),
          _buildStatementSubRow('• ${state.tr("washerCommissionSub")}', '- ${CurrencyFormatter.format(commissionPool)}'),
          _buildStatementSubRow('• ${state.tr("consumablesSub")}', '- ${CurrencyFormatter.format(totalSupplies)}'),
          const Divider(height: 12),
          _buildStatementRow(state.tr('grossOperatingProfitRow'), CurrencyFormatter.format(grossProfit), grossProfit >= 0 ? Colors.green.shade700 : Colors.red, isBold: true),
          const SizedBox(height: 8),
          _buildStatementRow(state.tr('opexRow'), '- ${CurrencyFormatter.format(totalPettyCash)}', Colors.deepOrange.shade900, isHeader: true),
          _buildStatementSubRow('• ${state.tr("pettyCashOpexSub")}', '- ${CurrencyFormatter.format(totalPettyCash)}'),
          const Divider(thickness: 1.5, height: 16),
          _buildStatementRow(state.tr('netOperatingProfitRow'), CurrencyFormatter.format(netOperatingProfit), netOperatingProfit >= 0 ? Colors.teal.shade800 : Colors.red, isBold: true, isLarge: true),
          const Divider(height: 16),
          _buildStatementRow(state.tr('salaryReserveRow'), CurrencyFormatter.format(monthlySalaryObligation), Colors.blueGrey, isHeader: true),
          const SizedBox(height: 4),
          _buildStatementRow(state.tr('netRetainedProfitRow'), CurrencyFormatter.format(netRetainedProfit), netRetainedProfit >= 0 ? Colors.indigo.shade800 : Colors.red, isBold: true),
        ],
      ),
    );
  }

  Widget _buildStatementRow(String label, String value, Color color, {bool isHeader = false, bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 14 : (isHeader || isBold ? 13 : 12),
              fontWeight: isHeader || isBold || isLarge ? FontWeight.w800 : FontWeight.w600,
              color: isLarge ? color : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 15 : 13,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatementSubRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ===========================================================================
  // PENDING APPROVALS & WEEKLY REPORTS & ACTION CARDS
  // ===========================================================================

  Widget _buildPendingApprovalsBanner(BuildContext context, dynamic state) {
    if (state.pendingApprovals.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                      ? '${state.pendingApprovals.length} ${state.tr("secondaryApprovalsAwaiting")}'
                      : '${state.pendingApprovals.length} ${state.tr("submittedForSuperApproval")}',
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
                            SnackBar(content: Text('${state.tr("rejectAction")}: ${req.title}'), backgroundColor: Colors.redAccent),
                          );
                        }
                      },
                      child: Text(state.tr('rejectAction'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
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
                            SnackBar(content: Text('${state.tr("approveAction")}: ${req.title}'), backgroundColor: AppColors.statusCompleted),
                          );
                        }
                      },
                      child: Text(state.tr('approveAction'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text(state.tr('pendingReviewBadge'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.brown)),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildResponsiveActionGrid(List<_AdminActionItem> items, bool isMobile) {
    final rows = <Widget>[];
    for (int i = 0; i < items.length; i += 2) {
      final first = items[i];
      final second = (i + 1 < items.length) ? items[i + 1] : null;
      rows.add(
        Row(
          children: [
            Expanded(child: _buildActionCard(first, isMobile)),
            const SizedBox(width: 10),
            if (second != null)
              Expanded(child: _buildActionCard(second, isMobile))
            else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < items.length) rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Widget _buildActionPairRow({required bool isMobile, required List<_AdminActionItem> items}) {
    return Row(
      children: [
        Expanded(child: _buildActionCard(items[0], isMobile)),
        const SizedBox(width: 10),
        Expanded(child: _buildActionCard(items[1], isMobile)),
      ],
    );
  }

  Widget _buildActionCard(_AdminActionItem op, bool isMobile) {
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
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  op.imageUrl != null
                      ? AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: op.imageUrl!,
                          width: isMobile ? 36 : 42,
                          height: isMobile ? 36 : 42,
                          borderRadius: 10,
                          fallbackIcon: op.icon,
                          fallbackColor: op.color,
                        )
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: op.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Icon(op.icon, color: op.color, size: 20),
                        ),
                  if (op.badge != null) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: op.color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(op.badge!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: op.color)),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              Text(
                op.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                op.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: isMobile ? 10.5 : 11, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyWasherCommissionReportSection(BuildContext context, dynamic state, bool isMobile) {
    final latestReport = state.latestWeeklyCommissionReport as WeeklyCommissionReport?;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.oromiaGold.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('weeklyCommissionReportSub'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!isMobile)
                OutlinedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffManagementScreen())),
                  icon: const Icon(Icons.manage_accounts_rounded, size: 14),
                  label: Text(state.tr('staffAndSalaries'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(state.tr('dailyTodayFilter')),
                  selected: _washerCommissionFilter == 'Daily',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _washerCommissionFilter == 'Daily' ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _washerCommissionFilter = 'Daily'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(state.tr('weeklyReportFilter')),
                  selected: _washerCommissionFilter == 'Weekly',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _washerCommissionFilter == 'Weekly' ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _washerCommissionFilter = 'Weekly'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text(state.tr('periodReportFilter')),
                  selected: _washerCommissionFilter == 'Date Range',
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _washerCommissionFilter == 'Date Range' ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => setState(() => _washerCommissionFilter = 'Date Range'),
                ),
              ],
            ),
          ),
          const Divider(height: 20, color: AppColors.cardBorder),
          if (_washerCommissionFilter == 'Daily') ...[
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
                return _buildWasherDividendRow(
                  name: w.name,
                  subtitle: isPresent ? state.tr('onDutyCountLabel') : state.tr('absent'),
                  amount: earned,
                  isPositive: isPresent,
                );
              },
            ),
          ] else if (_washerCommissionFilter == 'Weekly') ...[
            if (latestReport == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text(
                    state.tr('noWeeklyCommissionReports'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                  ),
                ),
              )
            else ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${latestReport.weekStartDate.day}/${latestReport.weekStartDate.month} - ${latestReport.weekEndDate.day}/${latestReport.weekEndDate.month}/${latestReport.weekEndDate.year}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            '${state.tr("reportedByCashier")}: ${latestReport.cashierName}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(latestReport.totalWeeklyPool),
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: latestReport.washerCommissions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final entry = latestReport.washerCommissions.entries.toList()[index];
                  return _buildWasherDividendRow(name: entry.key, amount: entry.value, isPositive: true);
                },
              ),
            ],
          ] else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (state.availableWashers as List).length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final w = (state.availableWashers as List)[index];
                final earned = (state.weeklyWasherCommissions as Map<String, double>)[w.name] ?? 0.0;
                return _buildWasherDividendRow(name: w.name, amount: earned, isPositive: earned > 0);
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWasherDividendRow({
    required String name,
    String? subtitle,
    required double amount,
    required bool isPositive,
  }) {
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
            width: 30,
            height: 30,
            borderRadius: 8,
            fallbackIcon: Icons.badge_rounded,
            fallbackColor: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                if (subtitle != null)
                  Text(subtitle, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: isPositive ? Colors.green.shade800 : Colors.red.shade700)),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isPositive ? AppColors.statusCompleted : AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // CUSTOMERS & ADS SECTION: DIGITAL RECEIPTS, HOTLINE/SMS & TIKTOK REELS
  // ===========================================================================

  Widget _buildDigitalReceiptsSection(
    BuildContext context,
    dynamic state,
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.telebirrBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.receipt_long_rounded, color: AppColors.telebirrBlue, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.tr('digitalReceiptsTitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
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
                  '${bookings.length} ${state.tr("digitalPay")}',
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (bookings.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Text(state.tr('noDigitalReceipts'), style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5)),
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
                        color: b.payment.method.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(b.payment.method.icon, color: b.payment.method.color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.licensePlate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
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
                        onPressed: () => _showScreenshotDialog(context, state, b),
                        icon: const Icon(Icons.image_rounded, size: 13),
                        label: Text(state.tr('viewReceipt'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
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
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                        child: Text(state.tr('noReceipt'), style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showScreenshotDialog(BuildContext context, dynamic state, WashBooking booking) {
    final screenshot = booking.payment.receiptScreenshot!;
    Widget imageWidget;
    try {
      if (screenshot.startsWith('http://') || screenshot.startsWith('https://')) {
        imageWidget = Image.network(screenshot, fit: BoxFit.contain);
      } else {
        imageWidget = Image.memory(base64Decode(screenshot), fit: BoxFit.contain);
      }
    } catch (_) {
      imageWidget = Center(child: Text(state.tr('noReceipt'), style: const TextStyle(color: AppColors.textMuted)));
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 620),
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
                      child: Text(
                        '${booking.licensePlate} • ${CurrencyFormatter.format(booking.payment.amount)}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.04),
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: InteractiveViewer(maxScale: 3.0, child: imageWidget),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('close'))),
                ),
              ),
            ],
          ),
        ),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.phone_forwarded_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  state.tr('smsAndHotlineTitle'),
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customerPhoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.call_rounded, size: 18, color: AppColors.primary),
                    labelText: state.tr('hotlineBookingLabel'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  final newPhone = _customerPhoneController.text.trim();
                  if (newPhone.isNotEmpty) {
                    await state.setCustomerPhoneBookingNumber(newPhone);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${state.tr("save")}: $newPhone'), backgroundColor: AppColors.statusReady),
                      );
                    }
                  }
                },
                child: Text(state.tr('save'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cashierPhoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone_android_rounded, size: 18, color: AppColors.cashGreen),
                    labelText: state.tr('cashierSmsPhoneLabel'),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cashGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final newPhone = _cashierPhoneController.text.trim();
                  if (newPhone.isNotEmpty) {
                    state.setCashierSmsPhone(newPhone);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${state.tr("updateAction")}: $newPhone'), backgroundColor: AppColors.statusReady),
                    );
                  }
                },
                child: Text(state.tr('updateAction'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokCommercialReelsManagerCard(BuildContext context, dynamic state, bool isMobile) {
    final reels = state.tiktokReels as List<TikTokAdVideo>;
    final isSuper = state.isSuperAdmin as bool;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFE2C55).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFFE2C55).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.video_library_rounded, color: Color(0xFFFE2C55), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            state.tr('tiktokReelsCardTitle'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: isMobile ? 13.5 : 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFF00F2FE).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            isSuper ? state.tr('superAdminRoleBadge') : state.tr('secondaryAdminRoleBadge'),
                            style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: Color(0xFF0284C7)),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${reels.length} ${state.tr("reelsActiveSuffix")}',
                      style: TextStyle(fontSize: isMobile ? 11 : 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE2C55),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.tune_rounded, size: 15),
                  label: Text(state.tr('manageReelsBtn'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5)),
                  onPressed: () => _showSuperAdminReelsDialog(context, state),
                ),
              ],
            ],
          ),
          if (isMobile) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFE2C55),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.tune_rounded, size: 15),
                label: Text(state.tr('manageReelsBtn'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                onPressed: () => _showSuperAdminReelsDialog(context, state),
              ),
            ),
          ],
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: reels.map((reel) {
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 130,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Text(
                    reel.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
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
            Expanded(child: Text(state.tr('clearAllBookingsConfirm'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16))),
          ],
        ),
        content: Text(state.tr('clearAllBookingsDesc'), style: const TextStyle(fontSize: 13, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await state.clearAllBookings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.tr('clearAllBookingsSuccess')), backgroundColor: Colors.green.shade700),
                );
              }
            },
            child: Text(state.tr('clearAllBookings')),
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
            title: Row(
              children: [
                const Icon(Icons.video_library_rounded, color: Color(0xFFFE2C55), size: 24),
                const SizedBox(width: 10),
                Expanded(child: Text(state.tr('tiktokReelsCardTitle'), style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold))),
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
                          'Official Account: @bishecarwash',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                      InkWell(
                        onTap: () => UrlLauncherHelper.openUrl('https://www.tiktok.com/@bishecarwash'),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE2C55).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFE2C55).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFFFE2C55)),
                              SizedBox(width: 4),
                              Text('@bishecarwash', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFFE2C55))),
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
                          padding: const EdgeInsets.all(10),
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
                                  width: 44,
                                  height: 44,
                                  color: Colors.black12,
                                  child: reel.thumbnailUrl.isNotEmpty
                                      ? (reel.thumbnailUrl.startsWith('assets/')
                                          ? Image.asset(reel.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.grey))
                                          : Image.network(reel.thumbnailUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: Colors.grey)))
                                      : const Icon(Icons.music_note, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${index + 1}. ${reel.title}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(reel.tiktokUrl, style: const TextStyle(fontSize: 11, color: Color(0xFFFE2C55)), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.primary),
                                onPressed: () => _editReelPopup(context, reel, (updated) => setDialogState(() => reels[index] = updated)),
                              ),
                              if (reels.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                                  onPressed: () => setDialogState(() => reels.removeAt(index)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFE2C55), foregroundColor: Colors.white),
                        icon: const Icon(Icons.sync_rounded, size: 16),
                        label: const Text('Sync @bishecarwash', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
                        },
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showBatchImportDialog(context, reels, setDialogState, state),
                        icon: const Icon(Icons.playlist_add_rounded, size: 16),
                        label: const Text('Batch Paste', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      OutlinedButton.icon(
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
                          _editReelPopup(context, newReel, (created) => setDialogState(() => reels.add(created)));
                        },
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add Reel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFE2C55), foregroundColor: Colors.white),
                onPressed: () async {
                  await state.setTikTokReels(reels);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: Text(state.tr('save')),
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
                  color: isSel ? const Color(0xFFFE2C55).withValues(alpha: 0.12) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isSel ? const Color(0xFFFE2C55) : AppColors.cardBorder, width: isSel ? 1.5 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: p['url']!.startsWith('assets/')
                          ? Image.asset(p['url']!, width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo, size: 14))
                          : Image.network(p['url']!, width: 24, height: 24, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.photo, size: 14)),
                    ),
                    const SizedBox(width: 6),
                    Text(p['label']!, style: TextStyle(fontSize: 10.5, fontWeight: isSel ? FontWeight.bold : FontWeight.w600)),
                  ],
                ),
              ),
            );
          }

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(state.tr('manageReelsBtn'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            content: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: subCtrl, decoration: const InputDecoration(labelText: 'Subtitle', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(controller: linkCtrl, decoration: const InputDecoration(labelText: 'TikTok URL', border: OutlineInputBorder())),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.open_in_new_rounded, size: 20),
                          onPressed: () {
                            final testUrl = UrlLauncherHelper.cleanUrl(linkCtrl.text);
                            if (testUrl.isNotEmpty) UrlLauncherHelper.openUrl(testUrl);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: thumbCtrl, decoration: const InputDecoration(labelText: 'Thumbnail', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    Text(state.tr('curatedReelsPoolTitle'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: AutoCareAssets.curatedReelsPool.map(buildPoolChip).toList()),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFE2C55), foregroundColor: Colors.white),
                onPressed: () {
                  final cleaned = UrlLauncherHelper.sanitizeTikTokUrl(linkCtrl.text);
                  if (cleaned.isNotEmpty) {
                    onSaved(reel.copyWith(
                      title: titleCtrl.text.trim().isNotEmpty ? titleCtrl.text.trim() : reel.title,
                      subtitle: subCtrl.text.trim().isNotEmpty ? subCtrl.text.trim() : reel.subtitle,
                      tiktokUrl: cleaned,
                      thumbnailUrl: thumbCtrl.text.trim().isNotEmpty ? thumbCtrl.text.trim() : reel.thumbnailUrl,
                    ));
                    Navigator.pop(ctx);
                  }
                },
                child: Text(state.tr('save')),
              ),
            ],
          );
        },
      ),
    ).then((_) {
      titleCtrl.dispose();
      subCtrl.dispose();
      linkCtrl.dispose();
      thumbCtrl.dispose();
    });
  }

  void _showBatchImportDialog(BuildContext context, List<TikTokAdVideo> reels, StateSetter setDialogState, dynamic state) {
    final batchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (batchCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Batch Paste TikTok Links', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: TextField(
            controller: batchCtrl,
            minLines: 5,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'https://www.tiktok.com/@bishecarwash/video/...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(batchCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFE2C55), foregroundColor: Colors.white),
            onPressed: () async {
              final urls = UrlLauncherHelper.extractUrls(batchCtrl.text);
              if (urls.isEmpty) return;
              final pool = AutoCareAssets.curatedReelsPool;
              final imported = <TikTokAdVideo>[];
              for (int i = 0; i < urls.length; i++) {
                final poolItem = pool[i % pool.length];
                if (i < reels.length) {
                  imported.add(reels[i].copyWith(tiktokUrl: urls[i]));
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
                imported.addAll(reels.skip(urls.length));
              }
              setDialogState(() {
                reels.clear();
                reels.addAll(imported);
              });
              await state.setTikTokReels(reels);
              if (batchCtx.mounted) Navigator.pop(batchCtx);
            },
            child: Text(state.tr('confirm')),
          ),
        ],
      ),
    ).then((_) => batchCtrl.dispose());
  }
}
