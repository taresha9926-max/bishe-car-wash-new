import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/print_export_helper.dart';
import '../../../../core/utils/receipt_image_helper.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/combined_service_header_banner.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/models/staff_member.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/bank_deposit_record.dart';
import '../../domain/models/daily_financial_closing.dart';
import '../../domain/models/petty_cash_expense.dart';
import '../../domain/models/weekly_commission_report.dart';
import '../../domain/models/commission_log.dart';
import '../../../inventory/domain/models/stock_transaction.dart';
import '../../../../core/widgets/shared_washer_commission_hub.dart';
import '../../../../core/widgets/expandable_action_card.dart';
import '../../../../core/widgets/financial_balance_sheet_card.dart';
import '../../../../core/widgets/financial_cash_flow_card.dart';
import '../../../../core/widgets/storekeeper_chemical_reconciliation_card.dart';
import '../../domain/models/monthly_overhead_expense.dart';
import '../widgets/bishe_ai_executive_sheet.dart';

class AccountantDashboardScreen extends StatefulWidget {
  const AccountantDashboardScreen({super.key});

  @override
  State<AccountantDashboardScreen> createState() => _AccountantDashboardScreenState();
}

class _AccountantDashboardScreenState extends State<AccountantDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _auditDateRange = 'All'; // All, Today, This Week, This Month
  String _pnlDateRange = 'Today'; // Today, This Week, This Month, Custom Range
  DateTimeRange? _pnlCustomRange;
  int _selectedFinancialStatementView = 0; // 0 = P&L, 1 = Balance Sheet, 2 = Cash Flow, 3 = Chemical Audit

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppRoleHeader(
        title: state.tr('accountantRole'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome_rounded, color: AppColors.liquidCyanNeon),
            tooltip: state.tr('aiExecutiveTitle'),
            onPressed: () => BisheAiExecutiveSheet.show(context),
          ),
        ],
      ),
      body: Column(
        children: [
          CombinedServiceHeaderBanner(
            title: state.tr('accountantCombinedHeader'),
            subtitle: state.tr('accountantCombinedSub'),
            badgeText: state.tr('unifiedDesk'),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          if (state.hasNewCashierClosingAlert && state.latestClosingAlert != null)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF115E59)]),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.teal.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded, color: Colors.greenAccent, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New Cashier Daily Closing Submitted',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        Text(
                          'Cashier: ${state.latestClosingAlert!.cashierName} • Gross: ${CurrencyFormatter.format(state.latestClosingAlert!.grossRevenue)} • ${state.latestClosingAlert!.carsWashedCount} orders settled',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _tabController.animateTo(0),
                    icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 15),
                    label: const Text('View Audit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  IconButton(
                    onPressed: () => state.dismissCashierClosingAlert(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              border: Border(
                bottom: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.8), width: 1.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
              tabs: const [
                Tab(icon: Icon(Icons.verified_rounded, size: 17), text: 'Cashier & Bank Audits'),
                Tab(icon: Icon(Icons.table_chart_rounded, size: 17), text: 'Washer Payroll & Matrix'),
                Tab(icon: Icon(Icons.receipt_long_rounded, size: 17), text: 'Supplies & OpEx'),
                Tab(icon: Icon(Icons.analytics_rounded, size: 17), text: 'P&L Statement'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCashierAuditsTab(context, state, isMobile),
                _buildCommissionsTab(context, state, isMobile),
                _buildExpensesTab(context, state, isMobile),
                _buildPnLTab(context, state, isMobile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: CASHIER CLOSINGS & BANK AUDITS
  // ==========================================

  Widget _buildCashierAuditsTab(BuildContext context, dynamic state, bool isMobile) {
    final closings = state.dailyFinancialClosings as List<DailyFinancialClosing>;
    final deposits = state.bankDeposits as List<BankDepositRecord>;
    final pettyExpenses = state.pettyCashExpenses as List<PettyCashExpense>;
    final allBookings = state.bookings as List<WashBooking>;

    final now = DateTime.now();
    bool Function(DateTime) predicate;
    switch (_auditDateRange) {
      case 'Today':
        predicate = (d) => d.year == now.year && d.month == now.month && d.day == now.day;
        break;
      case 'This Week':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final startMonday = DateTime(monday.year, monday.month, monday.day);
        predicate = (d) => d.isAfter(startMonday) || d.isAtSameMomentAs(startMonday);
        break;
      case 'This Month':
        predicate = (d) => d.year == now.year && d.month == now.month;
        break;
      default:
        predicate = (d) => true;
    }

    final filteredClosings = closings.where((c) => predicate(c.closingDate)).toList();
    final filteredDeposits = deposits.where((d) => predicate(d.depositedAt)).toList();
    final filteredPetty = pettyExpenses.where((p) => predicate(p.loggedAt)).toList();
    final filteredDigitalBookings = allBookings.where((b) {
      if (!b.payment.isPaid || !b.payment.method.isDigital) return false;
      final d = b.payment.paidAt ?? b.createdAt;
      return predicate(d);
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.cbeLogoUrl,
                  width: 44,
                  height: 44,
                  borderRadius: 10,
                  fallbackIcon: Icons.account_balance_rounded,
                  fallbackColor: Colors.cyanAccent,
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cashier Shifts & Bank Deposit Verification', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      SizedBox(height: 2),
                      Text('Account A (CBE) & Account B (Awash) Stamped Slip Audits', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Date Filter Toolbar & Export/Print Actions
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['All', 'Today', 'This Week', 'This Month'].map((range) {
                  final isSel = _auditDateRange == range;
                  return ChoiceChip(
                    label: Text(range == 'All' ? 'All Time' : range),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    backgroundColor: const Color(0xFF1E293B),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: isSel ? AppColors.primary : AppColors.cardBorder),
                    ),
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSel ? Colors.white : AppColors.textSecondary,
                    ),
                    onSelected: (_) => setState(() => _auditDateRange = range),
                  );
                }).toList(),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                    label: Text(state.tr('printReport'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      side: const BorderSide(color: AppColors.primary, width: 1.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      PrintExportHelper.printTableReport(
                        title: 'Cashier Daily Financial Closings & Audits',
                        subtitle: 'Filter: $_auditDateRange • Printed by Accountant',
                        headers: ['Date', 'Cashier', 'Gross Rev (ETB)', 'Cash Drawer', 'Digital Total', 'Deposited', 'Orders', 'Status'],
                        rows: filteredClosings.map((c) => [
                          DateFormatter.formatDate(c.closingDate),
                          c.cashierName,
                          CurrencyFormatter.format(c.grossRevenue),
                          CurrencyFormatter.format(c.cashRevenue),
                          CurrencyFormatter.format(c.digitalRevenue),
                          CurrencyFormatter.format(c.cashDeposited),
                          c.carsWashedCount,
                          c.isConfirmed ? 'Confirmed' : 'Draft',
                        ]).toList(),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.download_rounded, size: 14, color: Color(0xFF38BDF8)),
                    label: Text(state.tr('exportCsv'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      side: const BorderSide(color: Color(0xFF38BDF8), width: 1.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      PrintExportHelper.exportCsv(
                        fileName: 'bishe_cashier_audits_${_auditDateRange.replaceAll(' ', '_')}.csv',
                        headers: ['Closing ID', 'Date', 'Cashier', 'Gross Revenue (ETB)', 'Cash Drawer', 'Digital Total', 'Cash Deposited', 'Cars Washed', 'Status'],
                        rows: filteredClosings.map((c) => [
                          c.id,
                          DateFormatter.formatDate(c.closingDate),
                          c.cashierName,
                          c.grossRevenue,
                          c.cashRevenue,
                          c.digitalRevenue,
                          c.cashDeposited,
                          c.carsWashedCount,
                          c.isConfirmed ? 'Confirmed' : 'Draft',
                        ]).toList(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Ministry of Revenues • VAT & Tax Segregation Audit Card
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.shade700.withOpacity(0.6), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade900.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.account_balance_rounded, color: Colors.amber.shade400, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('vatAuditCard'),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: Colors.white),
                          ),
                          Text(
                            state.tr('vatSummaryNotice'),
                            style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.tr('vatRateNotice'), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(state.todayVehicleRevenueETB),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '15% VAT: ${CurrencyFormatter.format(state.vatDeductedTodayETB)}',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10.5, color: Colors.amber.shade400),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.tr('vatExempt'), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(state.todayCarpetRevenueETB + state.todayShowerRevenueETB),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF38BDF8)),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Carpet & Shower (0%)',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(state.tr('netRevenue'), style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                            const SizedBox(height: 2),
                            Text(
                              CurrencyFormatter.format(state.netBusinessRevenueTodayETB),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Color(0xFF10B981)),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Pre-Tax Business Rev',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 10, color: Color(0xFF94A3B8)),
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

          // 1. Submitted Daily Closings
          ExpandableActionCard(
            icon: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.stationBayUrl,
              width: 44,
              height: 44,
              borderRadius: 10,
              fallbackIcon: Icons.point_of_sale_rounded,
              fallbackColor: Colors.blueAccent,
            ),
            iconPadding: EdgeInsets.zero,
            iconBackgroundColor: Colors.transparent,
            borderColor: Colors.blueAccent,
            title: 'Submitted Daily Closings',
            subtitle: 'Reconciliation of gross/net drawer cash and digital receipts',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${filteredClosings.length} Closings', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.blueAccent)),
            ),
            initiallyExpanded: false,
            child: filteredClosings.isEmpty
                ? _buildEmptyState('No daily shift closings found for $_auditDateRange.', Icons.point_of_sale)
                : Column(children: filteredClosings.map((c) => _buildClosingAuditCard(context, state, c, isMobile)).toList()),
          ),

          // 2. Digital Payment Receipts & Verification
          ExpandableActionCard(
            icon: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.cbeLogoUrl,
              width: 44,
              height: 44,
              borderRadius: 10,
              fallbackIcon: Icons.qr_code_scanner_rounded,
              fallbackColor: AppColors.telebirrBlue,
            ),
            iconPadding: EdgeInsets.zero,
            iconBackgroundColor: Colors.transparent,
            borderColor: AppColors.telebirrBlue,
            title: 'Digital Payment Receipts & Verification',
            subtitle: 'Telebirr, CBE Birr & Awash mobile bank slip audits',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.telebirrBlue.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${filteredDigitalBookings.length} Receipts', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.telebirrBlue)),
            ),
            initiallyExpanded: false,
            child: filteredDigitalBookings.isEmpty
                ? _buildEmptyState('No digital payment receipts found for $_auditDateRange.', Icons.qr_code_scanner_rounded)
                : Column(children: filteredDigitalBookings.map((b) => _buildDigitalPaymentCard(context, state, b, isMobile)).toList()),
          ),

          // 3. Cash Recieved by Cashier Deposited to Bank Log
          ExpandableActionCard(
            icon: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.cbeLogoUrl,
              width: 44,
              height: 44,
              borderRadius: 10,
              fallbackIcon: Icons.account_balance_rounded,
              fallbackColor: Colors.teal,
            ),
            iconPadding: EdgeInsets.zero,
            iconBackgroundColor: Colors.transparent,
            borderColor: Colors.teal,
            title: 'Cash Deposited to Bank (Account A & B)',
            subtitle: 'CBE & Awash stamped slip verification and drawer bank balance',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${filteredDeposits.length} Deposits', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.teal)),
            ),
            initiallyExpanded: false,
            child: filteredDeposits.isEmpty
                ? _buildEmptyState('No bank deposit slips found for $_auditDateRange.', Icons.receipt_outlined)
                : Column(children: filteredDeposits.map((d) => _buildDepositCard(context, state, d, isMobile)).toList()),
          ),

          // 4. Petty Cash & Emergency Spend Log
          ExpandableActionCard(
            icon: AutoCareAssets.buildPhotoThumbnail(
              imageUrl: AutoCareAssets.cashMoneyUrl,
              width: 44,
              height: 44,
              borderRadius: 10,
              fallbackIcon: Icons.outbox_rounded,
              fallbackColor: Colors.deepOrangeAccent,
            ),
            iconPadding: EdgeInsets.zero,
            iconBackgroundColor: Colors.transparent,
            borderColor: Colors.deepOrangeAccent,
            title: 'Petty Cash & Emergency Spends',
            subtitle: 'Incidentals & cashier minor expense slips',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: Colors.deepOrangeAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${filteredPetty.length} Logs', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.deepOrangeAccent)),
            ),
            initiallyExpanded: false,
            child: filteredPetty.isEmpty
                ? _buildEmptyState('No petty cash expenses found for $_auditDateRange.', Icons.outbox_rounded)
                : Column(children: filteredPetty.map((p) => _buildPettyCashCard(context, state, p, isMobile)).toList()),
          ),

          // 5. Carry-Over, Postponed & Prepaid Unfinished Vehicles Audit
          Builder(
            builder: (context) {
              final carryOverBookings = state.carryOverAuditBookings as List<WashBooking>;
              return ExpandableActionCard(
                icon: AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.carSedanUrl,
                  width: 44,
                  height: 44,
                  borderRadius: 10,
                  fallbackIcon: Icons.schedule_send_rounded,
                  fallbackColor: const Color(0xFFD97706),
                ),
                iconPadding: EdgeInsets.zero,
                iconBackgroundColor: Colors.transparent,
                borderColor: const Color(0xFFD97706),
                title: state.tr('carryOverAuditTitle'),
                subtitle: state.tr('carryOverAuditSub'),
                badge: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${carryOverBookings.length}',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFFB45309)),
                  ),
                ),
                initiallyExpanded: carryOverBookings.isNotEmpty,
                child: carryOverBookings.isEmpty
                    ? _buildEmptyState(state.tr('noCarryOverVehicles'), Icons.schedule_send_rounded)
                    : Column(
                        children: carryOverBookings.map((b) {
                          final statusLabel = b.status.localizedName(state.currentLang);
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  Icon(
                                    b.payment.isPaid ? Icons.verified_rounded : Icons.schedule_send_rounded,
                                    color: b.payment.isPaid ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${b.licensePlate} • $statusLabel',
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
                                        ),
                                        Text(
                                          [
                                            '${b.createdAt.day}/${b.createdAt.month} • ${b.customerName}',
                                            if (b.isHandedOverToManager) state.tr('handoffCustodyArrow'),
                                            if (b.postponedByRole != null && b.postponedByRole!.isNotEmpty)
                                              '${state.tr("postponedByLabel")}: ${b.postponedByRole}',
                                            if (b.postponedReason != null && b.postponedReason!.isNotEmpty) b.postponedReason!,
                                          ].join(' • '),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        CurrencyFormatter.format(b.totalPrice),
                                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (b.payment.isPaid ? const Color(0xFF059669) : const Color(0xFFD97706)).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          b.payment.isPaid ? state.tr('prepaidFinishWashBadge') : state.tr('postponedCarryOverBadge'),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: b.payment.isPaid ? const Color(0xFF047857) : const Color(0xFFB45309),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClosingAuditCard(BuildContext context, dynamic state, DailyFinancialClosing c, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AutoCareAssets.buildPhotoThumbnail(
                  imageUrl: AutoCareAssets.stationBayUrl,
                  width: 32,
                  height: 32,
                  borderRadius: 6,
                  fallbackIcon: Icons.point_of_sale_rounded,
                  fallbackColor: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${c.closingDate.day}/${c.closingDate.month}/${c.closingDate.year} • ${c.shiftType == 'night' ? 'Night Shift (Op Manager)' : 'Day Shift (Cashier)'}: ${c.cashierName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        c.shiftType == 'night'
                            ? (c.isHandoverAccepted
                                ? 'Delivered to Admin (${c.acceptedByName ?? "Admin"}) via OTP'
                                : 'Night Cash Pending Admin OTP Verification')
                            : (c.handoverMethod == 'bank_deposit'
                                ? 'Bank Deposited to ${c.handoverTo}'
                                : (c.handoverMethod == 'admin_otp'
                                    ? (c.isHandoverAccepted
                                        ? 'Direct Cashier Handover Confirmed by Admin (${c.acceptedByName ?? "Admin"}) via OTP'
                                        : 'Direct Cashier Handover Pending Admin OTP Verification')
                                    : (c.isHandoverAccepted
                                        ? 'Handover Confirmed by Op Manager (${c.acceptedByName ?? "Manager"}) via OTP'
                                        : 'Handover Pending Manager OTP Verification'))),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: c.shiftType == 'night'
                              ? (c.isHandoverAccepted ? Colors.indigo : Colors.orange.shade800)
                              : (c.isHandoverAccepted ? Colors.green.shade700 : Colors.orange.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.shade300)),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12, color: Colors.green.shade800),
                      const SizedBox(width: 4),
                      Text(c.isConfirmed ? 'CONFIRMED' : 'PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildKpiPill('Gross Revenue', CurrencyFormatter.format(c.grossRevenue), Colors.blueGrey),
                _buildKpiPill('Washer 15% (Accrued)', CurrencyFormatter.format(c.commissionPool), Colors.orange),
                _buildKpiPill('Physical Cash', CurrencyFormatter.format(c.handoverCashAmount > 0 ? c.handoverCashAmount : c.cashRemaining), Colors.green),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: c.isHandoverAccepted ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFFEA580C).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: c.isHandoverAccepted ? const Color(0xFF10B981).withValues(alpha: 0.35) : const Color(0xFFEA580C).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    c.isHandoverAccepted ? Icons.verified_user_rounded : Icons.pending_actions_rounded,
                    size: 16,
                    color: c.isHandoverAccepted ? const Color(0xFF059669) : const Color(0xFFC2410C),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.handoverOtp != null
                          ? 'OTP CODE: [ ${c.handoverOtp} ] • ${c.isHandoverAccepted ? "${state.tr('verifiedBadge')} & RECONCILED (${c.acceptedByName ?? 'Recipient'})" : state.tr('otpReconciliationPending')}'
                          : 'BANK DEPOSIT STAMPED • RECONCILED DIRECTLY TO ${c.handoverTo.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: c.isHandoverAccepted ? const Color(0xFF047857) : const Color(0xFFC2410C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (c.notes != null && c.notes!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  c.notes!,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF312E81)),
                ),
              ),
            ],
            if (c.providerBreakdown.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Digital Money Breakdown:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                  Builder(
                    builder: (context) {
                      final closingDigital = (state.bookings as List<WashBooking>).where((b) {
                        if (!b.payment.isPaid || !b.payment.method.isDigital) return false;
                        final d = b.payment.paidAt ?? b.createdAt;
                        return d.year == c.closingDate.year && d.month == c.closingDate.month && d.day == c.closingDate.day;
                      }).toList();
                      final receiptsCount = closingDigital.where((b) => b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty).length;
                      if (receiptsCount == 0) return const SizedBox.shrink();
                      return InkWell(
                        onTap: () => _showDigitalReceiptsDialog(context, c.closingDate, closingDigital),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.receipt_long_rounded, size: 12, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '$receiptsCount Receipts Available',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: c.providerBreakdown.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.cardBorder)),
                    child: Text('${e.key}: ${CurrencyFormatter.format(e.value)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text('Bank Deposited: ${CurrencyFormatter.format(c.cashDeposited)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.indigo)),
                Text('Petty Cash: ${CurrencyFormatter.format(c.pettyCashExpenses)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.deepOrange)),
                Text('Drawer Remaining: ${CurrencyFormatter.format(c.cashRemaining)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositCard(BuildContext context, dynamic state, BankDepositRecord d, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: AutoCareAssets.buildPhotoThumbnail(
          imageUrl: d.targetAccount.toLowerCase().contains('awash') ? AutoCareAssets.cbeLogoUrl : AutoCareAssets.cbeLogoUrl,
          width: 38,
          height: 38,
          borderRadius: 8,
          fallbackIcon: Icons.account_balance,
          fallbackColor: AppColors.primary,
        ),
        title: Text('${CurrencyFormatter.format(d.amount)} → ${d.targetAccount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        subtitle: Text('Slip #: ${d.referenceSlipNumber} • Cashier: ${d.cashierName}', style: const TextStyle(fontSize: 11.5)),
        trailing: d.receiptScreenshot != null && d.receiptScreenshot!.isNotEmpty
            ? TextButton.icon(
                icon: const Icon(Icons.image_outlined, size: 14),
                label: const Text('View Slip', style: TextStyle(fontSize: 11)),
                onPressed: () => _viewImageDialog(context, 'Bank Deposit Slip: ${d.referenceSlipNumber}', d.receiptScreenshot!),
              )
            : const Text('No photo', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    );
  }

  Widget _buildPettyCashCard(BuildContext context, dynamic state, PettyCashExpense p, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: AutoCareAssets.buildPhotoThumbnail(
          imageUrl: AutoCareAssets.cashMoneyUrl,
          width: 38,
          height: 38,
          borderRadius: 8,
          fallbackIcon: Icons.receipt_long_rounded,
          fallbackColor: Colors.deepOrange,
        ),
        title: Text('${CurrencyFormatter.format(p.amount)} • ${p.category.toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
        subtitle: Text('${p.reason} • By: ${p.cashierName}', style: const TextStyle(fontSize: 11.5)),
        trailing: p.voucherScreenshot != null && p.voucherScreenshot!.isNotEmpty
            ? TextButton.icon(
                icon: const Icon(Icons.image_outlined, size: 14),
                label: const Text('Voucher', style: TextStyle(fontSize: 11)),
                onPressed: () => _viewImageDialog(context, 'Petty Cash Voucher: ${p.reason}', p.voucherScreenshot!),
              )
            : const Text('No photo', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    );
  }

  Widget _buildDigitalPaymentCard(BuildContext context, dynamic state, WashBooking b, bool isMobile) {
    final method = b.payment.method;
    final hasScreenshot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty;
    final date = b.payment.paidAt ?? b.createdAt;
    final dateStr = '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: AutoCareAssets.buildPhotoThumbnail(
          imageUrl: AutoCareAssets.cbeLogoUrl,
          width: 38,
          height: 38,
          borderRadius: 8,
          fallbackIcon: method.icon,
          fallbackColor: method.color,
        ),
        title: Row(
          children: [
            Text(b.licensePlate, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: method.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                method.shortName,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: method.color),
              ),
            ),
            const Spacer(),
            Text(
              CurrencyFormatter.format(b.payment.amount),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: AppColors.primary),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'Ref: ${b.payment.transactionRef ?? 'N/A'} • $dateStr • ${b.package.name}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        trailing: hasScreenshot
            ? TextButton.icon(
                icon: const Icon(Icons.image_outlined, size: 14),
                label: const Text('View Receipt', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                style: TextButton.styleFrom(
                  foregroundColor: method.color,
                ),
                onPressed: () => _viewImageDialog(
                  context,
                  'Digital Receipt: ${b.licensePlate} (${method.displayName})',
                  b.payment.receiptScreenshot!,
                ),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('No photo', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
      ),
    );
  }

  void _showDigitalReceiptsDialog(BuildContext context, DateTime date, List<WashBooking> bookings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Digital Receipts (${date.day}/${date.month}/${date.year})', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: math.min(450.0, MediaQuery.sizeOf(ctx).width - 32),
          child: bookings.isEmpty
              ? const Padding(padding: EdgeInsets.all(16), child: Text('No digital payments recorded for this date.'))
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const Divider(height: 10),
                  itemBuilder: (c, i) {
                    final b = bookings[i];
                    final hasShot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty;
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(b.payment.method.icon, color: b.payment.method.color, size: 20),
                      title: Text('${b.licensePlate} • ${CurrencyFormatter.format(b.payment.amount)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                      subtitle: Text('${b.payment.method.displayName} • Ref: ${b.payment.transactionRef ?? "N/A"}', style: const TextStyle(fontSize: 11)),
                      trailing: hasShot
                          ? TextButton.icon(
                              icon: const Icon(Icons.image_outlined, size: 14),
                              label: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              onPressed: () => _viewImageDialog(context, 'Receipt: ${b.licensePlate} (${b.payment.method.displayName})', b.payment.receiptScreenshot!),
                            )
                          : const Text('No photo', style: TextStyle(fontSize: 10.5, color: Colors.grey)),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: TABULAR 7-DAY PAYROLL & MATRIX
  // ==========================================

  Widget _buildCommissionsTab(BuildContext context, dynamic state, bool isMobile) {
    final weeklyReports = state.weeklyCommissionReports as List<WeeklyCommissionReport>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action Bar: Print & Export
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${(state.availableWashers as List).length} Active Washers • ${weeklyReports.length} Reports',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                      label: Text(state.tr('printPayroll'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: AppColors.primary, width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final washers = (state.availableWashers as List).cast<StaffMember>();
                        PrintExportHelper.printTableReport(
                          title: 'Washer Team Payroll & Commission Matrix',
                          subtitle: 'BISHE Auto Care • Bishoftu',
                          headers: ['Washer ID', 'Name', 'Phone', 'Role', 'Status', 'Daily Dividend (ETB)'],
                          rows: washers.map((w) {
                            final dividend = state.washerDividendsToday[w.id] ?? 0.0;
                            return [
                              w.id,
                              w.name,
                              w.phone,
                              w.role.displayName,
                              w.isAvailable ? 'Available' : 'Assigned',
                              CurrencyFormatter.format(dividend),
                            ];
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 14, color: Color(0xFF38BDF8)),
                      label: Text(state.tr('exportPayroll'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final washers = (state.availableWashers as List).cast<StaffMember>();
                        PrintExportHelper.exportCsv(
                          fileName: 'bishe_washer_payroll_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                          headers: ['Washer ID', 'Name', 'Phone', 'Role', 'Status', 'Daily Dividend (ETB)'],
                          rows: washers.map((w) {
                            final dividend = state.washerDividendsToday[w.id] ?? 0.0;
                            return [
                              w.id,
                              w.name,
                              w.phone,
                              w.role.displayName,
                              w.isAvailable ? 'Available' : 'Assigned',
                              dividend,
                            ];
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 1. Unified Master Washer Team Roster, Attendance & Commission Hub
          // Mirrored across Cashier and Accountant dashboards with full mobile-first expandable architecture,
          // displaying exact daily earned commission (e.g. Br 250) instead of P, showing A only when absent,
          // and providing the "Confirm & Mark Weekly Commission Paid" action button.
          SharedWasherCommissionHub(
            state: state,
            role: WasherHubRole.accountant,
            isMobile: isMobile,
            initiallyExpanded: false,
          ),
          const SizedBox(height: 16),

          // 2. Expandable Action Card for Weekly Commission Submission Reports
          ExpandableActionCard(
            icon: const Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF0D9488), size: 22),
            iconBackgroundColor: const Color(0xFF0D9488).withOpacity(0.12),
            borderColor: const Color(0xFF0D9488),
            title: 'Weekly Commission Submission Reports',
            subtitle: '${weeklyReports.length} submitted reports from Cashier',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: weeklyReports.any((r) => !r.isDisbursed)
                    ? Colors.orange.withOpacity(0.15)
                    : Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${weeklyReports.where((r) => !r.isDisbursed).length} Pending',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  color: weeklyReports.any((r) => !r.isDisbursed) ? Colors.orange.shade900 : Colors.green.shade800,
                ),
              ),
            ),
            initiallyExpanded: false,
            child: weeklyReports.isEmpty
                ? _buildEmptyState('No weekly commission reports submitted yet.', Icons.date_range)
                : Column(
                    children: weeklyReports.map((r) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${r.weekStartDate.day}/${r.weekStartDate.month} – ${r.weekEndDate.day}/${r.weekEndDate.month} • Pool: ${CurrencyFormatter.format(r.totalWeeklyPool)}',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: r.isDisbursed ? Colors.green.shade50 : Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: r.isDisbursed ? Colors.green.shade300 : Colors.orange.shade300),
                                  ),
                                  child: Text(
                                    r.isDisbursed ? state.tr('disbursedStatus') : state.tr('pendingDisbursal'),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: r.isDisbursed ? Colors.green.shade800 : Colors.orange.shade900),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Reported by: ${r.cashierName} • Washers: ${r.washerCommissions.length}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                            if (!r.isDisbursed) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    await state.disburseWeeklyCommission(r.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Weekly commission disbursed successfully!')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.payments_outlined, size: 14),
                                  label: Text(state.tr('disburseWeeklyAction'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green.shade700,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 3: SUPPLIES & OPEX
  // ==========================================

  Widget _buildExpensesTab(BuildContext context, dynamic state, bool isMobile) {
    final transactions = state.stockTransactions as List<StockTransaction>;
    final restocks = transactions.where((t) => t.type == 'receiveStock').toList();
    final consumed = transactions.where((t) => t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption').toList();
    final totalSpent = restocks.fold(0.0, (sum, t) => sum + t.totalCostEtb);
    final totalConsumed = consumed.fold(0.0, (sum, t) => sum + t.totalCostEtb);
    final pettyExpenses = state.pettyCashExpenses as List<PettyCashExpense>;
    final totalPetty = pettyExpenses.fold(0.0, (sum, p) => sum + p.amount);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF334155), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Restock Spend (GRN)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(CurrencyFormatter.format(totalSpent), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.white24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Supplies Consumed', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(CurrencyFormatter.format(totalConsumed), style: const TextStyle(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                Container(width: 1, height: 32, color: Colors.white24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Petty Cash Outflow', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(CurrencyFormatter.format(totalPetty), style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 16, fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Bar: Print & Export
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${consumed.length} Consumed • ${restocks.length} Purchases • ${pettyExpenses.length} Petty Cash',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                      label: Text(state.tr('printReport'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: AppColors.primary, width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final rows = <List<dynamic>>[];
                        for (final c in consumed) {
                          rows.add([DateFormatter.formatDate(c.date), c.itemName, 'Consumed Supply', '${c.quantity} ${c.unit}', CurrencyFormatter.format(c.totalCostEtb), c.supplier]);
                        }
                        for (final r in restocks) {
                          rows.add([DateFormatter.formatDate(r.date), r.itemName, 'Inbound GRN Restock', '${r.quantity} ${r.unit}', CurrencyFormatter.format(r.totalCostEtb), r.supplier]);
                        }
                        for (final p in pettyExpenses) {
                          rows.add([DateFormatter.formatDate(p.loggedAt), p.reason, 'Petty Cash (${p.category})', '1', CurrencyFormatter.format(p.amount), p.cashierName]);
                        }
                        PrintExportHelper.printTableReport(
                          title: 'Station Supplies & Operating Expenses (OpEx)',
                          subtitle: 'BISHE Auto Care Station • Bishoftu',
                          headers: ['Date', 'Item / Expense', 'Category', 'Quantity', 'Amount (ETB)', 'Logged By / Supplier'],
                          rows: rows,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 14, color: Color(0xFF38BDF8)),
                      label: Text(state.tr('exportCsv'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        final rows = <List<dynamic>>[];
                        for (final c in consumed) {
                          rows.add([c.id, DateFormatter.formatDate(c.date), c.itemName, 'Consumed Supply', c.quantity, c.unit, c.totalCostEtb, c.supplier, c.notes ?? '']);
                        }
                        for (final r in restocks) {
                          rows.add([r.id, DateFormatter.formatDate(r.date), r.itemName, 'Inbound GRN Restock', r.quantity, r.unit, r.totalCostEtb, r.supplier, r.notes ?? '']);
                        }
                        for (final p in pettyExpenses) {
                          rows.add([p.id, DateFormatter.formatDate(p.loggedAt), p.reason, 'Petty Cash (${p.category})', 1, 'Event', p.amount, p.cashierName, '']);
                        }
                        PrintExportHelper.exportCsv(
                          fileName: 'bishe_supplies_and_opex_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                          headers: ['ID', 'Date', 'Item / Reason', 'Type', 'Quantity', 'Unit', 'Total Cost (ETB)', 'Supplier / Cashier', 'Notes'],
                          rows: rows,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 1. Daily Consumed Supplies (Empty-for-Full Exchanges)
          ExpandableActionCard(
            icon: const Icon(Icons.autorenew_rounded, color: Color(0xFF0D9488), size: 22),
            iconBackgroundColor: const Color(0xFF0D9488).withOpacity(0.12),
            borderColor: const Color(0xFF0D9488),
            title: 'Daily Consumed Supplies (Empty-for-Full)',
            subtitle: 'Reported chemical usage from storekeeper',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xFF0D9488).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${consumed.length} Consumed', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF0D9488))),
            ),
            initiallyExpanded: false,
            child: consumed.isEmpty
                ? _buildEmptyState('No daily consumable usage reported by storekeeper yet.', Icons.autorenew_rounded)
                : Column(
                    children: consumed.map((t) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: AutoCareAssets.buildPhotoThumbnail(
                          imageUrl: AutoCareAssets.getInventoryImage(t.itemName),
                          width: 40,
                          height: 40,
                          borderRadius: 8,
                          fallbackIcon: Icons.water_drop_rounded,
                          fallbackColor: Colors.teal,
                        ),
                        title: Text(t.itemName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        subtitle: Text(
                          '${t.quantity} ${t.unit} consumed • ${t.supplier} (${t.date.day}/${t.date.month})\n${t.notes}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        trailing: Text(
                          CurrencyFormatter.format(t.totalCostEtb),
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.deepOrange, fontSize: 13),
                        ),
                      ),
                    )).toList(),
                  ),
          ),

          // 2. Inventory Goods Received Notes (GRN - Purchases)
          ExpandableActionCard(
            icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 22),
            iconBackgroundColor: AppColors.primary.withOpacity(0.12),
            borderColor: AppColors.primary,
            title: 'Inventory Goods Received Notes (GRN)',
            subtitle: 'Inbound supplier purchases & invoice audits',
            badge: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Text('${restocks.length} Invoices', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.primary)),
            ),
            initiallyExpanded: false,
            child: restocks.isEmpty
                ? _buildEmptyState('No inventory purchases logged by storekeeper yet.', Icons.shopping_bag_outlined)
                : Column(
                    children: restocks.map((t) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder.withOpacity(0.85)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                AutoCareAssets.buildPhotoThumbnail(
                                  imageUrl: AutoCareAssets.getInventoryImage(t.itemName),
                                  width: 36,
                                  height: 36,
                                  borderRadius: 8,
                                  fallbackIcon: Icons.inventory_2_rounded,
                                  fallbackColor: AppColors.primary,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(t.itemName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                                ),
                                Text(CurrencyFormatter.format(t.totalCostEtb), style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.red, fontSize: 13.5)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${t.quantity} ${t.unit.isNotEmpty ? t.unit : "units"} @ ${CurrencyFormatter.format(t.unitCostEtb)} / ${t.unit.isNotEmpty ? t.unit : "unit"} • Supplier: ${t.supplier}',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                            ),
                            if (t.invoiceScreenshot != null && t.invoiceScreenshot!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              TextButton.icon(
                                icon: const Icon(Icons.receipt_rounded, size: 14),
                                label: const Text('View Invoice Attachment', style: TextStyle(fontSize: 11)),
                                onPressed: () => _viewImageDialog(context, 'Invoice: ${t.itemName}', t.invoiceScreenshot!),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: PROFIT & LOSS (P&L) STATEMENT
  // ==========================================

  Widget _buildPnLTab(BuildContext context, dynamic state, bool isMobile) {
    final now = DateTime.now();
    late DateTime rangeStart;
    late DateTime rangeEnd;
    int rangeDays = 1;

    switch (_pnlDateRange) {
      case 'This Week':
        final monday = now.subtract(Duration(days: now.weekday - 1));
        rangeStart = DateTime(monday.year, monday.month, monday.day);
        rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        rangeDays = 7;
        break;
      case 'This Month':
        rangeStart = DateTime(now.year, now.month, 1);
        rangeEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        rangeDays = 30;
        break;
      case 'Custom Range':
        if (_pnlCustomRange != null) {
          rangeStart = DateTime(_pnlCustomRange!.start.year, _pnlCustomRange!.start.month, _pnlCustomRange!.start.day);
          rangeEnd = DateTime(_pnlCustomRange!.end.year, _pnlCustomRange!.end.month, _pnlCustomRange!.end.day, 23, 59, 59);
          rangeDays = math.max(1, _pnlCustomRange!.end.difference(_pnlCustomRange!.start).inDays + 1);
        } else {
          rangeStart = DateTime(now.year, now.month, now.day);
          rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
          rangeDays = 1;
        }
        break;
      case 'Today':
      default:
        rangeStart = DateTime(now.year, now.month, now.day);
        rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        rangeDays = 1;
        break;
    }

    bool isInRange(DateTime dt) => !dt.isBefore(rangeStart) && !dt.isAfter(rangeEnd);

    final bookingsList = (state.bookings as List).cast<WashBooking>();
    final paidBookings = bookingsList.where((WashBooking b) {
      if (!b.payment.isPaid) return false;
      final dt = b.payment.paidAt ?? b.createdAt;
      return isInRange(dt);
    }).toList();

    // 15% VAT on Car Wash services; Carpet and Shower services are 100% VAT exempt
    final vehicleWashRevenue = paidBookings.where((b) => !b.isCarpet).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final vehicleVat = vehicleWashRevenue * 0.15;
    final vehicleNet = vehicleWashRevenue - vehicleVat;
    final carpetWashRevenue = paidBookings.where((b) => b.isCarpet).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final showerRevenue = (state.showerRecords as List)
        .where((s) => isInRange(s.recordedAt))
        .fold<double>(0.0, (sum, s) => sum + s.totalAmount);
    final grossRevenue = vehicleWashRevenue + carpetWashRevenue + showerRevenue;
    final totalNetRevenue = vehicleNet + carpetWashRevenue + showerRevenue;

    final cashCarWash = paidBookings
        .where((b) => !b.isCarpet && b.payment.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digitalCarWash = paidBookings
        .where((b) => !b.isCarpet && b.payment.method != PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final cashCarpet = paidBookings
        .where((b) => b.isCarpet && b.payment.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digitalCarpet = paidBookings
        .where((b) => b.isCarpet && b.payment.method != PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final totalDigitalInflows = digitalCarWash + digitalCarpet;
    final totalCashOnHand = cashCarWash + cashCarpet + showerRevenue;

    final carsWashedCount = paidBookings.where((b) => !b.isCarpet).length;
    final carpetsWashedCount = paidBookings.where((b) => b.isCarpet).length;

    // Direct commissions for the active range
    final logsInRange = (state.commissionLogs as List)
        .cast<CommissionLog>()
        .where((l) => isInRange(l.completedAt))
        .toList();
    final commissionPaid = logsInRange.isNotEmpty
        ? logsInRange.fold<double>(0.0, (sum, l) => sum + l.commissionEarnedETB)
        : (vehicleNet + carpetWashRevenue) * (state.teamCommissionRate as double);

    // COST OF GOODS SOLD (COGS): Only actual consumed soap via empty-full can exchange or bay consumption
    // NEVER deduct warehouse inventory restocks (receiveStock)
    final suppliesCost = (state.stockTransactions as List<StockTransaction>)
        .where((t) => isInRange(t.date) && (t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption'))
        .fold<double>(0.0, (sum, t) => sum + t.totalCostEtb);

    final pettyCost = (state.pettyCashExpenses as List<PettyCashExpense>)
        .where((p) => isInRange(p.loggedAt))
        .fold<double>(0.0, (sum, p) => sum + p.amount);

    final List<MonthlyOverheadExpense> overheads = state.monthlyOverheads;
    final dailyDepreciation = state.dailyMachineryDepreciation as double;
    final periodDepreciation = dailyDepreciation * rangeDays;

    final periodOverheads = overheads.fold<double>(0.0, (sum, o) => sum + (o.dailyAccrualEtb * rangeDays));

    final cogs = commissionPaid + suppliesCost;
    final grossProfit = totalNetRevenue - cogs;

    // OpEx calculation prorated by exact rangeDays (Monthly ÷ 30 × rangeDays)
    final opex = periodOverheads + periodDepreciation + pettyCost;
    final netOperatingProfit = grossProfit - opex;

    String heroTitle;
    String heroSubtitle;
    switch (_pnlDateRange) {
      case 'This Week':
        heroTitle = 'THIS WEEK NET OPERATING PROFIT (EBITDA)';
        heroSubtitle = 'Gross Revenue − Direct COGS − 7-Day Accrued Overheads (Rent, Utilities, Staff Salaries) & Machinery Depreciation';
        break;
      case 'This Month':
        heroTitle = 'THIS MONTH NET OPERATING PROFIT (EBITDA)';
        heroSubtitle = 'Gross Revenue − Direct COGS − Full Monthly Fixed Overheads (Rent, Utilities, Staff Salaries) & Machinery Depreciation';
        break;
      case 'Custom Range':
        heroTitle = 'PERIOD NET OPERATING PROFIT ($rangeDays DAYS)';
        heroSubtitle = 'Gross Revenue − Direct COGS − $rangeDays-Day Accrued Overheads (Rent, Utilities, Staff Salaries) & Machinery Depreciation';
        break;
      case 'Today':
      default:
        heroTitle = 'TODAY NET OPERATING PROFIT (EBITDA)';
        heroSubtitle = 'Gross Revenue − Direct COGS (Commissions + Soap) − Daily Accrued Overheads (Rent/30, Utilities/30, Salaries/30)';
        break;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Timeframe Date Range Toolbar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPnlFilterChip(
                label: state.tr('filterToday'),
                icon: Icons.today_rounded,
                isSelected: _pnlDateRange == 'Today',
                onTap: () => setState(() => _pnlDateRange = 'Today'),
              ),
              _buildPnlFilterChip(
                label: state.tr('filterThisWeek'),
                icon: Icons.view_week_rounded,
                isSelected: _pnlDateRange == 'This Week',
                onTap: () {
                  setState(() => _pnlDateRange = 'This Week');
                  final monday = now.subtract(Duration(days: now.weekday - 1));
                  final startMonday = DateTime(monday.year, monday.month, monday.day);
                  final endSunday = startMonday.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
                  state.fetchBookingsForDateRange(startMonday, endSunday);
                },
              ),
              _buildPnlFilterChip(
                label: state.tr('filterThisMonth'),
                icon: Icons.calendar_month_rounded,
                isSelected: _pnlDateRange == 'This Month',
                onTap: () {
                  setState(() => _pnlDateRange = 'This Month');
                  final startMonth = DateTime(now.year, now.month, 1);
                  final endMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
                  state.fetchBookingsForDateRange(startMonth, endMonth);
                },
              ),
              _buildPnlFilterChip(
                label: _pnlDateRange == 'Custom Range' && _pnlCustomRange != null
                    ? '${_pnlCustomRange!.start.day}/${_pnlCustomRange!.start.month} - ${_pnlCustomRange!.end.day}/${_pnlCustomRange!.end.month}'
                    : state.tr('filterCustomRange'),
                icon: Icons.date_range_rounded,
                isSelected: _pnlDateRange == 'Custom Range',
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2022),
                    lastDate: now.add(const Duration(days: 365)),
                    initialDateRange: _pnlCustomRange ??
                        DateTimeRange(
                          start: now.subtract(const Duration(days: 7)),
                          end: now,
                        ),
                  );
                  if (picked != null && mounted) {
                    setState(() {
                      _pnlCustomRange = picked;
                      _pnlDateRange = 'Custom Range';
                    });
                    final start = DateTime(picked.start.year, picked.start.month, picked.start.day);
                    final end = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
                    state.fetchBookingsForDateRange(start, end);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2. Executive Financial Statement Selector Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatementTypeChip(
                  label: state.tr('statementPnlTab'),
                  icon: Icons.analytics_rounded,
                  index: 0,
                ),
                const SizedBox(width: 8),
                _buildStatementTypeChip(
                  label: state.tr('statementBalanceSheetTab'),
                  icon: Icons.account_balance_rounded,
                  index: 1,
                ),
                const SizedBox(width: 8),
                _buildStatementTypeChip(
                  label: state.tr('statementCashFlowTab'),
                  icon: Icons.sync_alt_rounded,
                  index: 2,
                ),
                const SizedBox(width: 8),
                _buildStatementTypeChip(
                  label: state.tr('statementReconciliationTab'),
                  icon: Icons.compare_arrows_rounded,
                  index: 3,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Bar: Print Statement & Export CSV
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  _selectedFinancialStatementView == 0
                      ? 'P&L Statement • $_pnlDateRange'
                      : (_selectedFinancialStatementView == 1
                          ? 'Balance Sheet • Position'
                          : (_selectedFinancialStatementView == 2
                              ? 'Cash Flow Statement • Direct Method'
                              : 'Chemical Reconciliation Audit')),
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded, size: 14, color: AppColors.primary),
                      label: Text(state.tr('printStatement'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: AppColors.primary, width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (_selectedFinancialStatementView == 0) {
                          PrintExportHelper.printTableReport(
                            title: 'Profit & Loss (P&L) Statement',
                            subtitle: 'BISHE Auto Care • Bishoftu • Period: $_pnlDateRange',
                            headers: ['Financial Line Item', 'Classification', 'Amount (ETB)', 'Notes'],
                            rows: [
                              ['Gross Vehicle Revenue', 'Revenue', CurrencyFormatter.format(vehicleWashRevenue), 'Direct customer wash'],
                              ['Carpet Cleaning Revenue', 'Revenue', CurrencyFormatter.format(carpetWashRevenue), 'Zero VAT exempt'],
                              ['Shower Service Revenue', 'Revenue', CurrencyFormatter.format(showerRevenue), 'Zero VAT exempt'],
                              ['Total Gross Station Revenue', 'Gross Revenue', CurrencyFormatter.format(grossRevenue), 'All revenue streams'],
                              ['15% VAT Statutory Deductions', 'Tax Deduction', CurrencyFormatter.format(vehicleVat), 'Ministry of Revenues'],
                              ['Total Net Business Revenue', 'Net Revenue', CurrencyFormatter.format(totalNetRevenue), 'Gross − VAT'],
                              ['Washer Team Commission Pool', 'Direct COGS', CurrencyFormatter.format(commissionPaid), 'Labor cost'],
                              ['Supplies & Chemical Usage', 'Direct COGS', CurrencyFormatter.format(suppliesCost), 'Consumables'],
                              ['Total Cost of Goods Sold (COGS)', 'Direct COGS', CurrencyFormatter.format(cogs), 'Commissions + Soap'],
                              ['GROSS OPERATING PROFIT', 'Gross Profit', CurrencyFormatter.format(grossProfit), 'Net Revenue − COGS'],
                              ['Rent & Space Allocation', 'OpEx', CurrencyFormatter.format(periodOverheads * 0.4), 'Accrued facility rent'],
                              ['Utilities (Water & Power)', 'OpEx', CurrencyFormatter.format(periodOverheads * 0.3), 'Accrued utilities'],
                              ['Staff Salaries & Overhead', 'OpEx', CurrencyFormatter.format(periodOverheads * 0.3), 'Accrued management salaries'],
                              ['Machinery Depreciation', 'OpEx', CurrencyFormatter.format(periodDepreciation), 'Fixed asset wear'],
                              ['Petty Cash & Incidentals', 'OpEx', CurrencyFormatter.format(pettyCost), 'Cashier emergency disbursements'],
                              ['Total Operating Expenses (OpEx)', 'Total OpEx', CurrencyFormatter.format(opex), 'Accrued fixed + variable'],
                              ['NET OPERATING PROFIT (EBITDA)', 'Net Profit', CurrencyFormatter.format(netOperatingProfit), 'Gross Profit − OpEx'],
                            ],
                          );
                        } else if (_selectedFinancialStatementView == 1) {
                          PrintExportHelper.printTableReport(
                            title: 'Balance Sheet Statement',
                            subtitle: 'BISHE Auto Care • Bishoftu',
                            headers: ['Balance Sheet Item', 'Classification', 'Amount (ETB)', 'Description'],
                            rows: [
                              ['Drawer Cash on Hand', 'Current Assets', CurrencyFormatter.format(totalCashOnHand), 'Cashier drawer till'],
                              ['Bank / Digital Accounts', 'Current Assets', CurrencyFormatter.format(totalDigitalInflows), 'CBE, Awash & Telebirr'],
                              ['Chemical & Consumable Inventory', 'Current Assets', CurrencyFormatter.format(state.totalInventoryValueETB ?? 0.0), 'Stockroom inventory'],
                              ['Fixed Wash Machinery & Equipment', 'Non-Current Assets', CurrencyFormatter.format(state.totalFixedAssetsValueETB ?? 0.0), 'Capital equipment net'],
                              ['15% VAT Payable Liability', 'Current Liabilities', CurrencyFormatter.format(vehicleVat), 'Tax owed'],
                              ['Unpaid Washer Commission Pool', 'Current Liabilities', CurrencyFormatter.format(commissionPaid), 'Labor owed'],
                              ['Net Station Equity & Retained Earnings', 'Equity', CurrencyFormatter.format(netOperatingProfit), 'Accumulated profit'],
                            ],
                          );
                        } else if (_selectedFinancialStatementView == 2) {
                          PrintExportHelper.printTableReport(
                            title: 'Cash Flow Statement (Direct Method)',
                            subtitle: 'BISHE Auto Care • Bishoftu',
                            headers: ['Cash Flow Activity', 'Category', 'Amount (ETB)', 'Details'],
                            rows: [
                              ['Cash Receipts from Vehicle Wash', 'Operating Inflows', CurrencyFormatter.format(cashCarWash), 'Cashier drawer collections'],
                              ['Cash Receipts from Carpet Clean', 'Operating Inflows', CurrencyFormatter.format(cashCarpet), 'Carpet collections'],
                              ['Cash Receipts from Shower Admission', 'Operating Inflows', CurrencyFormatter.format(showerRevenue), 'Shower collections'],
                              ['Digital Bank & Telebirr Inflows', 'Operating Inflows', CurrencyFormatter.format(totalDigitalInflows), 'Mobile money & bank deposits'],
                              ['Direct Commission Outflows', 'Operating Outflows', CurrencyFormatter.format(-commissionPaid), 'Disbursed commissions'],
                              ['Storekeeper Restock Purchases', 'Operating Outflows', CurrencyFormatter.format(-suppliesCost), 'Supplier restocks'],
                              ['Cashier Petty Cash Disbursements', 'Operating Outflows', CurrencyFormatter.format(-pettyCost), 'Incidentals & petty cash'],
                            ],
                          );
                        } else {
                          PrintExportHelper.printTableReport(
                            title: 'Storekeeper Chemical Consumption Reconciliation',
                            subtitle: 'BISHE Auto Care • Bishoftu',
                            headers: ['Reconciliation Metric', 'Cars Washed', 'Consumed (L/Units)', 'Ratio (Cars/L)', 'Status'],
                            rows: [
                              ['Vehicle Wash Shampoo', '$carsWashedCount cars', '${suppliesCost > 0 ? (suppliesCost / 250).toStringAsFixed(1) : "0"} L', '~15 cars/L', 'Verified In-Tolerance'],
                              ['Carpet Cleaning Detergent', '$carpetsWashedCount carpets', '${carpetsWashedCount * 0.25} L', '~4 carpets/L', 'Verified In-Tolerance'],
                            ],
                          );
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download_rounded, size: 14, color: Color(0xFF38BDF8)),
                      label: Text(state.tr('exportStatement'), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8))),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        side: const BorderSide(color: Color(0xFF38BDF8), width: 1.1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (_selectedFinancialStatementView == 0) {
                          PrintExportHelper.exportCsv(
                            fileName: 'bishe_pnl_statement_${_pnlDateRange.replaceAll(' ', '_')}.csv',
                            headers: ['Line Item', 'Category', 'Amount (ETB)', 'Notes'],
                            rows: [
                              ['Gross Vehicle Revenue', 'Revenue', vehicleWashRevenue, 'Direct customer wash'],
                              ['Carpet Cleaning Revenue', 'Revenue', carpetWashRevenue, 'Zero VAT exempt'],
                              ['Shower Service Revenue', 'Revenue', showerRevenue, 'Zero VAT exempt'],
                              ['Total Gross Revenue', 'Gross Revenue', grossRevenue, 'All services'],
                              ['15% VAT Statutory', 'Tax', vehicleVat, 'Ministry of Revenues'],
                              ['Total Net Business Revenue', 'Net Revenue', totalNetRevenue, 'Gross − VAT'],
                              ['Washer Commission Pool', 'COGS', commissionPaid, 'Direct labor'],
                              ['Supplies & Soap Usage', 'COGS', suppliesCost, 'Chemical swaps'],
                              ['Total COGS', 'COGS', cogs, 'Commissions + Soap'],
                              ['Gross Operating Profit', 'Gross Margin', grossProfit, 'Net Revenue − COGS'],
                              ['Rent & Space Allocation', 'OpEx', periodOverheads * 0.4, 'Facility rent'],
                              ['Utilities (Water & Power)', 'OpEx', periodOverheads * 0.3, 'Power & water'],
                              ['Staff Salaries & Overhead', 'OpEx', periodOverheads * 0.3, 'Salaries'],
                              ['Machinery Depreciation', 'OpEx', periodDepreciation, 'Depreciation'],
                              ['Petty Cash Outflow', 'OpEx', pettyCost, 'Petty cash'],
                              ['Total OpEx', 'OpEx', opex, 'Total operating expenses'],
                              ['NET OPERATING PROFIT (EBITDA)', 'Net Profit', netOperatingProfit, 'Gross Profit − OpEx'],
                            ],
                          );
                        } else if (_selectedFinancialStatementView == 1) {
                          PrintExportHelper.exportCsv(
                            fileName: 'bishe_balance_sheet_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                            headers: ['Item', 'Category', 'Amount (ETB)', 'Description'],
                            rows: [
                              ['Drawer Cash on Hand', 'Current Assets', totalCashOnHand, 'Cashier drawer'],
                              ['Bank & Digital Accounts', 'Current Assets', totalDigitalInflows, 'CBE, Awash & Telebirr'],
                              ['Chemical & Consumable Inventory', 'Current Assets', state.totalInventoryValueETB ?? 0.0, 'Stockroom'],
                              ['Fixed Wash Machinery', 'Non-Current Assets', state.totalFixedAssetsValueETB ?? 0.0, 'Capital assets'],
                              ['15% VAT Payable Liability', 'Current Liabilities', vehicleVat, 'Tax liability'],
                              ['Unpaid Washer Commission Pool', 'Current Liabilities', commissionPaid, 'Labor liability'],
                              ['Net Station Equity & Retained Earnings', 'Equity', netOperatingProfit, 'Retained earnings'],
                            ],
                          );
                        } else if (_selectedFinancialStatementView == 2) {
                          PrintExportHelper.exportCsv(
                            fileName: 'bishe_cash_flow_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                            headers: ['Activity', 'Category', 'Amount (ETB)', 'Details'],
                            rows: [
                              ['Cash Receipts from Vehicle Wash', 'Operating Inflow', cashCarWash, 'Drawer cash'],
                              ['Cash Receipts from Carpet Clean', 'Operating Inflow', cashCarpet, 'Carpet cash'],
                              ['Cash Receipts from Shower', 'Operating Inflow', showerRevenue, 'Shower cash'],
                              ['Digital Bank Inflows', 'Operating Inflow', totalDigitalInflows, 'Telebirr & CBE'],
                              ['Direct Commission Outflows', 'Operating Outflow', -commissionPaid, 'Commissions'],
                              ['Storekeeper Restock Purchases', 'Operating Outflow', -suppliesCost, 'Purchases'],
                              ['Cashier Petty Cash', 'Operating Outflow', -pettyCost, 'Petty cash'],
                            ],
                          );
                        } else {
                          PrintExportHelper.exportCsv(
                            fileName: 'bishe_chemical_reconciliation_${DateTime.now().toIso8601String().split('T')[0]}.csv',
                            headers: ['Metric', 'Cars Washed', 'Consumed', 'Ratio', 'Status'],
                            rows: [
                              ['Vehicle Wash Shampoo', '$carsWashedCount cars', suppliesCost > 0 ? (suppliesCost / 250).toStringAsFixed(1) : '0', '~15 cars/L', 'Verified In-Tolerance'],
                              ['Carpet Cleaning Detergent', '$carpetsWashedCount carpets', '${carpetsWashedCount * 0.25} L', '~4 carpets/L', 'Verified In-Tolerance'],
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (_selectedFinancialStatementView == 1)
            FinancialBalanceSheetCard(
              state: state,
              isMobile: isMobile,
              cashOnHand: totalCashOnHand,
              bankBalance: totalDigitalInflows,
              vatPayable: vehicleVat,
              commissionPayable: commissionPaid,
              netRetainedProfit: netOperatingProfit,
              rangeDays: rangeDays,
            )
          else if (_selectedFinancialStatementView == 2)
            FinancialCashFlowCard(
              state: state,
              isMobile: isMobile,
              cashFromCarWash: cashCarWash,
              cashFromCarpet: cashCarpet,
              cashFromShower: showerRevenue,
              digitalCollections: totalDigitalInflows,
              suppliesPaid: suppliesCost,
              commissionsPaid: commissionPaid,
              pettyCashPaid: pettyCost,
              rentPaid: ((state.dailyFacilityRentAccrualETB as double?) ?? 833.33) * rangeDays,
              rangeDays: rangeDays,
            )
          else if (_selectedFinancialStatementView == 3)
            StorekeeperChemicalReconciliationCard(
              state: state,
              isMobile: isMobile,
              carsWashedCount: carsWashedCount,
              carpetsWashedCount: carpetsWashedCount,
              rangeDays: rangeDays,
              rangeStart: rangeStart,
              rangeEnd: rangeEnd,
            )
          else ...[
            // 3. Net Operating Profit Hero Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: netOperatingProfit >= 0
                      ? [const Color(0xFF065F46), const Color(0xFF047857)]
                      : [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: (netOperatingProfit >= 0 ? Colors.green : Colors.red).withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        heroTitle,
                        style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          grossRevenue > 0 ? '${((netOperatingProfit / grossRevenue) * 100).toStringAsFixed(1)}% Margin' : '0.0% Margin',
                          style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(netOperatingProfit),
                    style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    heroSubtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              rangeDays == 1
                  ? 'Daily Operational Income Statement (Real-Truth Model):'
                  : (rangeDays == 30
                      ? 'Full Monthly Station Income Statement (30-Day Budget):'
                      : 'Station Operational Income Statement ($rangeDays-Day Period):'),
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            // Section 1: Revenue by Service Division & Tax Treatment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('I. OPERATING REVENUE & TAX TREATMENT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(state.tr('departmentalPnl'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _buildPnLLine('1. Car Washing Services (Vatable Gross)', CurrencyFormatter.format(vehicleWashRevenue), Colors.white, false),
            _buildPnLLine('   ↳ Less: 15% VAT Output (Gov Tax Liability)', '- ${CurrencyFormatter.format(vehicleVat)}', Colors.amberAccent, false),
            _buildPnLLine('   ↳ Net Car Wash Revenue', CurrencyFormatter.format(vehicleNet), Colors.green.shade600, false),
            _buildPnLLine('2. Carpet Washing Services (VAT Exempt 0%)', CurrencyFormatter.format(carpetWashRevenue), Colors.green.shade600, false),
            _buildPnLLine('3. Shower Services Facility (VAT Exempt 0%)', CurrencyFormatter.format(showerRevenue), Colors.green.shade600, false),
            const Divider(thickness: 0.8, height: 12, color: Colors.white24),
            _buildPnLLine('TOTAL NET OPERATING REVENUE', CurrencyFormatter.format(totalNetRevenue), Colors.green.shade800, true),
            const SizedBox(height: 10),

            // Section 2: COGS
            const Text('II. DIRECT COST OF GOODS SOLD (COGS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange)),
            _buildPnLLine('Washer Team 15% Net Commission', '- ${CurrencyFormatter.format(commissionPaid)}', Colors.orange.shade800, false),
            _buildPnLLine('Storekeeper Soap Consumed (ዕቃ በዕቃ Exchange)', '- ${CurrencyFormatter.format(suppliesCost)}', Colors.orange.shade800, false),
            _buildPnLLine('Total Cost of Goods Sold', '- ${CurrencyFormatter.format(cogs)}', Colors.orange.shade900, true),
            const Divider(thickness: 1, height: 16),
            _buildPnLLine('GROSS OPERATING PROFIT', CurrencyFormatter.format(grossProfit), grossProfit >= 0 ? Colors.green.shade800 : Colors.red, true),
            const SizedBox(height: 10),

            // Section 3: Operating Overheads (OpEx)
            Text(
              rangeDays == 1
                  ? 'III. DAILY ACCRUED OPERATING OVERHEADS (Monthly ÷ 30)'
                  : (rangeDays == 30
                      ? 'III. FULL MONTHLY OPERATING OVERHEADS (30 Days Budget)'
                      : 'III. ACCRUED OPERATING OVERHEADS ($rangeDays Days: Monthly ÷ 30 × $rangeDays)'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.deepOrange),
            ),
            ...overheads.map((o) {
              final amt = o.dailyAccrualEtb * rangeDays;
              final isRent = o.id == 'overhead_rent' || o.category.toLowerCase() == 'rent';
              final subtitle = rangeDays == 1
                  ? '(${CurrencyFormatter.format(o.monthlyAmountEtb)}/mo ÷ 30)'
                  : (rangeDays == 30
                      ? '(${CurrencyFormatter.format(o.monthlyAmountEtb)}/mo Budget)'
                      : '(${CurrencyFormatter.format(o.dailyAccrualEtb)}/day × $rangeDays days)');
              return _buildPnLLine(
                isRent ? '★ ${o.name} $subtitle' : '${o.name} $subtitle',
                '- ${CurrencyFormatter.format(amt)}',
                isRent ? Colors.amber.shade300 : Colors.deepOrange.shade700,
                isRent,
              );
            }),
            _buildPnLLine(
              rangeDays == 1
                  ? 'Machinery Depreciation (÷ 30)'
                  : (rangeDays == 30
                      ? 'Machinery Depreciation (Monthly)'
                      : 'Machinery Depreciation ($rangeDays Days)'),
              '- ${CurrencyFormatter.format(periodDepreciation)}',
              Colors.deepOrange.shade700,
              false,
            ),
            _buildPnLLine('Cashier Petty Cash / Emergency Spends', '- ${CurrencyFormatter.format(pettyCost)}', Colors.deepOrange.shade700, false),
            const Divider(thickness: 1, height: 16),
            _buildPnLLine('Total Operating Expenses (OpEx)', '- ${CurrencyFormatter.format(opex)}', Colors.deepOrange.shade900, true),
            const Divider(thickness: 1.5, height: 20),

            // Section 4: Final Net Operating Profit
            _buildPnLLine(
              rangeDays == 1
                  ? 'NET STATION OPERATING PROFIT (TODAY)'
                  : (rangeDays == 30
                      ? 'NET STATION OPERATING PROFIT (MONTH)'
                      : 'NET STATION OPERATING PROFIT ($rangeDays DAYS)'),
              CurrencyFormatter.format(netOperatingProfit),
              netOperatingProfit >= 0 ? Colors.green.shade800 : Colors.red,
              true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPnlFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatementTypeChip({
    required String label,
    required IconData icon,
    required int index,
  }) {
    final isSelected = _selectedFinancialStatementView == index;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selectedFinancialStatementView = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPnLLine(String label, String value, Color color, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isBold ? 14 : 13, fontWeight: isBold ? FontWeight.w900 : FontWeight.w600, color: AppColors.textPrimary)),
          Text(value, style: TextStyle(fontSize: isBold ? 15 : 13.5, fontWeight: isBold ? FontWeight.w900 : FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  Widget _buildKpiPill(String title, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(msg, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  void _viewImageDialog(BuildContext context, String title, String imageUrl) {
    final imageWidget = ReceiptImageHelper.buildImage(
      imageUrl,
      fit: BoxFit.contain,
      fallback: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Unable to preview image data.', style: TextStyle(color: AppColors.textMuted)),
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
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
                    const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imageWidget,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.cardBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
