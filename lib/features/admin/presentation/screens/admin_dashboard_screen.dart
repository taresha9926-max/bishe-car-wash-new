import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/receipt_image_helper.dart';
import '../../../../core/utils/url_launcher_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/closing_sync_warning_banner.dart';
import '../../../../core/widgets/combined_service_header_banner.dart';
import '../../../../core/widgets/financial_pnl_statement_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/domain/models/wash_status.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../../welcome/domain/models/tiktok_ad_video.dart';
import '../widgets/admin_feedback_moderation_card.dart';
import 'credentials_management_screen.dart';
import 'pricing_management_screen.dart';
import 'staff_management_screen.dart';

enum AdminTimeFilter {
  today,
  thisWeek,
  thisMonth,
  customRange;

  String localizedLabel(dynamic state, [DateTimeRange? selectedRange]) {
    switch (this) {
      case AdminTimeFilter.today:
        return state.tr('filterToday');
      case AdminTimeFilter.thisWeek:
        return state.tr('filterThisWeek');
      case AdminTimeFilter.thisMonth:
        return state.tr('filterThisMonth');
      case AdminTimeFilter.customRange:
        if (selectedRange != null) {
          return '${selectedRange.start.day}/${selectedRange.start.month} - ${selectedRange.end.day}/${selectedRange.end.month}';
        }
        return state.tr('filterCustomRange');
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
  DateTimeRange? _selectedCustomRange;
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
        final endSunday = startMonday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return !dt.isBefore(startMonday) && !dt.isAfter(endSunday);
      case AdminTimeFilter.thisMonth:
        return dt.year == now.year && dt.month == now.month;
      case AdminTimeFilter.customRange:
        final range = _selectedCustomRange ??
            DateTimeRange(
              start: DateTime(now.year, now.month, now.day),
              end: DateTime(now.year, now.month, now.day),
            );
        final rangeStart = DateTime(range.start.year, range.start.month, range.start.day);
        final rangeEnd = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
        return !dt.isBefore(rangeStart) && !dt.isAfter(rangeEnd);
    }
  }

  FinancialReportFilter get _mappedFinancialFilter {
    switch (_selectedFilter) {
      case AdminTimeFilter.today:
        return FinancialReportFilter.today;
      case AdminTimeFilter.thisWeek:
        return FinancialReportFilter.thisWeek;
      case AdminTimeFilter.thisMonth:
        return FinancialReportFilter.thisMonth;
      case AdminTimeFilter.customRange:
        return FinancialReportFilter.customRange;
    }
  }

  String _selectedRangeSubtitle(dynamic state) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case AdminTimeFilter.today:
        return '${state.tr("filterToday")} (${now.day}/${now.month}/${now.year})';
      case AdminTimeFilter.thisWeek:
        final mon = now.subtract(Duration(days: now.weekday - 1));
        final sun = mon.add(const Duration(days: 6));
        return '${state.tr("filterThisWeek")} (${mon.day}/${mon.month} - ${sun.day}/${sun.month}/${sun.year})';
      case AdminTimeFilter.thisMonth:
        return '${state.tr("filterThisMonth")} (${now.month}/${now.year})';
      case AdminTimeFilter.customRange:
        final r = _selectedCustomRange;
        return r == null
            ? state.tr('filterToday')
            : '${r.start.day}/${r.start.month}/${r.start.year} - ${r.end.day}/${r.end.month}/${r.end.year}';
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
    final vatDeducted = serviceRevenue * 0.15;
    final netServiceRevenue = serviceRevenue - vatDeducted;
    final commissionPool = (netServiceRevenue * state.teamCommissionRate) + tipsRevenue;

    final digitalBookings = allBookings.where((b) => b.payment.isPaid && b.payment.method.isDigital).toList();

    // Show Cashier Handover card ONLY when Cashier requested Admin verification (admin_otp)
    // and Manager Night Handover card ONLY when Manager submitted Night Closing OTP.
    final anyPendingDay = state.pendingCashierAdminHandover;
    final pendingNight = state.pendingAdminNightHandover;
    final hasActiveOtpPending = anyPendingDay != null || pendingNight != null;

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

                  if (state.hasNewCashierClosingAlert &&
                      state.latestClosingAlert != null &&
                      state.latestClosingAlert!.isHandoverAccepted)
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
                      totalPettyCash,
                      totalSupplies,
                      vatDeducted: vatDeducted,
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
    double totalPettyCash,
    double totalSupplies, {
    double vatDeducted = 0.0,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExecutiveBanner(state, isMobile),
        const SizedBox(height: 12),

        _buildTimeFilterBar(state),
        const SizedBox(height: 12),

        const ClosingSyncWarningBanner(),

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
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FinancialReportsView(
                    initialFilter: _mappedFinancialFilter,
                    initialCustomRange: _selectedCustomRange,
                  ),
                ),
              ),
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

        // Full Profit & Loss Statement synchronized with selected Date / Date Range filter
        FinancialPnlStatementCard(
          state: state,
          isMobile: isMobile,
          periodSubtitle: _selectedRangeSubtitle(state),
          totalRevenue: totalRevenue,
          vatDeducted: vatDeducted,
          commissionPool: commissionPool,
          totalPettyCash: totalPettyCash,
          totalSupplies: totalSupplies,
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

  Future<void> _handleInlineAdminVerifyCashier(BuildContext context, dynamic state) async {
    final entered = _adminCashierOtpController.text.trim();
    if (entered.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('enterFourDigitOtpError')), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final anyPending = state.pendingCashierAdminHandover;
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
      _showClosingSyncToast(context, state);
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
      _showClosingSyncToast(context, state);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.tr('invalidOtpCode')), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _showClosingSyncToast(BuildContext context, dynamic state) {
    showClosingSyncResultSnackBar(
      context,
      state,
      successMessage: state.tr('handoverSuccess'),
    );
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AdminTimeFilter.values.map((filter) {
        final isSelected = filter == _selectedFilter;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (filter == AdminTimeFilter.customRange) {
                final now = DateTime.now();
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2022),
                  lastDate: now.add(const Duration(days: 365)),
                  initialDateRange: _selectedCustomRange ??
                      DateTimeRange(
                        start: now.subtract(const Duration(days: 7)),
                        end: now,
                      ),
                );
                if (picked != null && mounted) {
                  setState(() {
                    _selectedCustomRange = picked;
                    _selectedFilter = AdminTimeFilter.customRange;
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
                  if (filter == AdminTimeFilter.customRange) ...[
                    Icon(
                      Icons.date_range_rounded,
                      size: 15,
                      color: isSelected ? Colors.white : AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    filter.localizedLabel(state, _selectedCustomRange),
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
        );
      }).toList(),
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
              itemCount: bookings.take(10).length,
              separatorBuilder: (_, __) => const Divider(height: 14, color: AppColors.cardBorder),
              itemBuilder: (context, index) {
                final b = bookings[index];
                final hasScreenshot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.trim().isNotEmpty;
                return Row(
                  children: [
                    GestureDetector(
                      onTap: hasScreenshot ? () => _showScreenshotDialog(context, state, b) : null,
                      child: Container(
                        width: 42,
                        height: 42,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: b.payment.method.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: hasScreenshot ? Border.all(color: AppColors.telebirrBlue.withValues(alpha: 0.45)) : null,
                        ),
                        child: hasScreenshot
                            ? ReceiptImageHelper.buildImage(
                                b.payment.receiptScreenshot,
                                width: 42,
                                height: 42,
                                fit: BoxFit.cover,
                                fallback: Icon(b.payment.method.icon, color: b.payment.method.color, size: 19),
                              )
                            : Icon(b.payment.method.icon, color: b.payment.method.color, size: 19),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${b.licensePlate} • ${b.payment.method.localizedName(state.currentLang)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                          ),
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
    final screenshot = booking.payment.receiptScreenshot;
    final imageWidget = ReceiptImageHelper.buildImage(
      screenshot,
      fit: BoxFit.contain,
      fallback: Center(child: Text(state.tr('noReceipt'), style: const TextStyle(color: AppColors.textMuted))),
    );

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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: reels.map((reel) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
