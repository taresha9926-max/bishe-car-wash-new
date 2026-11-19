import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/combined_service_header_banner.dart';
import '../../../../core/widgets/dual_service_entrance_tab_bar.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/models/staff_member.dart';
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
  bool _isDailyPnlView = true; // Default to True: Real-truth Daily Accrual P&L

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

          // Date Filter Toolbar
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
          const SizedBox(height: 18),

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
    final bookingsList = (state.bookings as List).cast<WashBooking>();
    final paidBookings = bookingsList.where((WashBooking b) => b.payment.isPaid).toList();
    final grossRevenue = paidBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final commissionPaid = (state.commissionLogs as List).cast<CommissionLog>().fold<double>(0.0, (sum, l) => sum + l.commissionEarnedETB);

    // 15% VAT on Car Wash services; Carpet and Shower services are 100% VAT exempt
    final vehicleWashRevenue = paidBookings.where((b) => !b.isCarpet).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final vehicleVat = vehicleWashRevenue * 0.15;
    final vehicleNet = vehicleWashRevenue - vehicleVat;
    final carpetWashRevenue = paidBookings.where((b) => b.isCarpet).fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final showerRevenue = _isDailyPnlView ? (state.todayShowerRevenueETB as double) : ((state.todayShowerRevenueETB as double) * 30.0);
    final totalNetRevenue = vehicleNet + carpetWashRevenue + showerRevenue;

    // COST OF GOODS SOLD (COGS): Only actual consumed soap via empty-full can exchange or bay consumption
    // NEVER deduct warehouse inventory restocks (receiveStock)
    final suppliesCost = (state.stockTransactions as List<StockTransaction>)
        .where((t) => t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption')
        .fold<double>(0.0, (sum, t) => sum + t.totalCostEtb);

    final pettyCost = (state.pettyCashExpenses as List<PettyCashExpense>)
        .fold<double>(0.0, (sum, p) => sum + p.amount);

    final List<MonthlyOverheadExpense> overheads = state.monthlyOverheads;
    final totalMonthlyOverheads = state.totalMonthlyOverheads as double;
    final totalDailyOverheads = state.totalDailyOverheadAccrual as double;
    final dailyDepreciation = state.dailyMachineryDepreciation as double;
    final monthlyDepreciation = dailyDepreciation * 30.0;

    final cogs = commissionPaid + suppliesCost;
    final grossProfit = totalNetRevenue - cogs;

    // OpEx calculation based on active view (Daily Accrual ÷ 30 vs Full Monthly)
    final opex = _isDailyPnlView
        ? (totalDailyOverheads + dailyDepreciation + pettyCost)
        : (totalMonthlyOverheads + monthlyDepreciation + pettyCost);

    final netOperatingProfit = grossProfit - opex;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Timeframe Mode Switcher (Today Live P&L vs Full Monthly Statement)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder.withOpacity(0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isDailyPnlView = true),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _isDailyPnlView ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.today_rounded, size: 16, color: _isDailyPnlView ? Colors.white : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            state.tr('pnlDailyView'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: _isDailyPnlView ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _isDailyPnlView = false),
                    borderRadius: BorderRadius.circular(9),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: !_isDailyPnlView ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 16, color: !_isDailyPnlView ? Colors.white : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            state.tr('pnlMonthlyView'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: !_isDailyPnlView ? Colors.white : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 2. Net Operating Profit Hero Banner
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
                      _isDailyPnlView ? 'TODAY NET OPERATING PROFIT (EBITDA)' : 'MONTHLY NET OPERATING PROFIT',
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
                  _isDailyPnlView
                      ? 'Gross Revenue − Direct COGS (Commissions + Soap) − Daily Accrued Overheads (Rent/30, Utilities/30, Salaries/30)'
                      : 'Gross Revenue − Direct COGS − Full Monthly Fixed Overheads & Machinery Depreciation',
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Text(
            _isDailyPnlView ? 'Daily Operational Income Statement (Real-Truth Model):' : 'Full Monthly Station Income Statement:',
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
            _isDailyPnlView ? 'III. DAILY ACCRUED OPERATING OVERHEADS (Monthly ÷ 30)' : 'III. MONTHLY OPERATING OVERHEADS (OpEx)',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.deepOrange),
          ),
          ...overheads.map((o) {
            final amt = _isDailyPnlView ? o.dailyAccrualEtb : o.monthlyAmountEtb;
            final isRent = o.id == 'overhead_rent' || o.category.toLowerCase() == 'rent';
            final subtitle = _isDailyPnlView ? '(${CurrencyFormatter.format(o.monthlyAmountEtb)}/mo ÷ 30)' : '(Monthly Lease Budget)';
            return _buildPnLLine(
              isRent ? '★ ${o.name} $subtitle' : '${o.name} $subtitle',
              '- ${CurrencyFormatter.format(amt)}',
              isRent ? Colors.amber.shade300 : Colors.deepOrange.shade700,
              isRent,
            );
          }),
          _buildPnLLine(
            _isDailyPnlView ? 'Machinery Depreciation (÷ 30)' : 'Machinery Depreciation (Monthly)',
            '- ${CurrencyFormatter.format(_isDailyPnlView ? dailyDepreciation : monthlyDepreciation)}',
            Colors.deepOrange.shade700,
            false,
          ),
          _buildPnLLine('Cashier Petty Cash / Emergency Spends', '- ${CurrencyFormatter.format(pettyCost)}', Colors.deepOrange.shade700, false),
          const Divider(thickness: 1, height: 16),
          _buildPnLLine('Total Operating Expenses (OpEx)', '- ${CurrencyFormatter.format(opex)}', Colors.deepOrange.shade900, true),
          const Divider(thickness: 1.5, height: 20),

          // Section 4: Final Net Operating Profit
          _buildPnLLine(
            _isDailyPnlView ? 'NET STATION OPERATING PROFIT (TODAY)' : 'NET STATION OPERATING PROFIT (MONTH)',
            CurrencyFormatter.format(netOperatingProfit),
            netOperatingProfit >= 0 ? Colors.green.shade800 : Colors.red,
            true,
          ),
        ],
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
    Widget imageWidget;
    try {
      if (imageUrl.startsWith('data:image')) {
        final commaIdx = imageUrl.indexOf(',');
        final base64Data = commaIdx != -1 ? imageUrl.substring(commaIdx + 1) : imageUrl;
        final bytes = base64Decode(base64Data);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Unable to preview image data.', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
        );
      } else if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
        imageWidget = Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Unable to load receipt image from web.', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
        );
      } else {
        final bytes = base64Decode(imageUrl);
        imageWidget = Image.memory(
          bytes,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Unable to preview image data.', style: TextStyle(color: AppColors.textMuted)),
            ),
          ),
        );
      }
    } catch (_) {
      imageWidget = const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Invalid or corrupted image format.', style: TextStyle(color: AppColors.textMuted)),
        ),
      );
    }

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
