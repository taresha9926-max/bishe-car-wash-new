import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/animated_circular_ring.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/floating_pill_nav_bar.dart';
import '../../../../core/widgets/modern_expandable_card.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/rounded_meter_bar.dart';
import '../../../../core/widgets/unified_washer_roster_card.dart';
import '../../../booking_service/domain/models/wash_booking.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/bank_deposit_record.dart';
import '../../domain/models/daily_financial_closing.dart';
import '../../domain/models/petty_cash_expense.dart';
import '../../domain/models/weekly_commission_report.dart';
import '../../../inventory/domain/models/stock_transaction.dart';

class AccountantDashboardScreen extends StatefulWidget {
  const AccountantDashboardScreen({super.key});

  @override
  State<AccountantDashboardScreen> createState() => _AccountantDashboardScreenState();
}

class _AccountantDashboardScreenState extends State<AccountantDashboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _auditDateRange = 'All'; // All, Today, This Week, This Month

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
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
      ),
      bottomNavigationBar: FloatingPillNavBar(
        selectedIndex: _tabController.index,
        onItemSelected: (idx) => _tabController.animateTo(idx),
        items: const [
          FloatingNavItem(
            icon: Icons.verified_rounded,
            label: 'Audits',
          ),
          FloatingNavItem(
            icon: Icons.table_chart_rounded,
            label: 'Payroll',
          ),
          FloatingNavItem(
            icon: Icons.receipt_long_rounded,
            label: 'OpEx',
          ),
          FloatingNavItem(
            icon: Icons.analytics_rounded,
            label: 'P&L',
          ),
        ],
      ),
      body: Column(
        children: [
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
                          'Cashier: ${state.latestClosingAlert!.cashierName} • Gross: ${CurrencyFormatter.format(state.latestClosingAlert!.grossRevenue)} (${state.latestClosingAlert!.carsWashedCount} cars washed)',
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
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.verified_rounded, size: 18), text: 'Cashier & Bank Audits'),
                Tab(icon: Icon(Icons.table_chart_rounded, size: 18), text: 'Washer Payroll & Matrix'),
                Tab(icon: Icon(Icons.receipt_long_rounded, size: 18), text: 'Supplies & OpEx'),
                Tab(icon: Icon(Icons.analytics_rounded, size: 18), text: 'P&L Statement'),
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
            padding: EdgeInsets.all(isMobile ? 14 : 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF064E3B), Color(0xFF0F766E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                AnimatedCircularRing(
                  progress: filteredClosings.isEmpty
                      ? 1.0
                      : (filteredClosings.where((c) => c.isConfirmed).length / filteredClosings.length),
                  size: isMobile ? 74 : 84,
                  strokeWidth: 7,
                  primaryColor: const Color(0xFF34D399),
                  secondaryColor: const Color(0xFF6EE7B7),
                  trackColor: const Color(0xFF032B21),
                  centerValue: '${filteredClosings.length}',
                  centerLabel: 'Closings',
                  valueStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  labelStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF6EE7B7)),
                ),
                SizedBox(width: isMobile ? 12 : 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Shift & Bank Audit Status',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 0.8),
                            ),
                            child: Text(
                              '${filteredDeposits.length} Bank Deposits',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      RoundedMeterBar(
                        progress: filteredDigitalBookings.isEmpty
                            ? 1.0
                            : (filteredDigitalBookings.where((b) => b.payment.isPaid).length / filteredDigitalBookings.length),
                        label: 'Digital Receipts Reconciled',
                        valueText: '${filteredDigitalBookings.length} Receipts',
                        gradientColors: const [Color(0xFF38BDF8), Color(0xFF0284C7)],
                        trackColor: const Color(0xFF032B21),
                        labelColor: Colors.white70,
                        valueColor: const Color(0xFF38BDF8),
                        height: 6,
                      ),
                      const SizedBox(height: 7),
                      RoundedMeterBar(
                        progress: 0.85,
                        label: 'Petty Cash Ledger Verified',
                        valueText: '${filteredPetty.length} Vouchers',
                        gradientColors: const [Color(0xFFFB923C), Color(0xFFF97316)],
                        trackColor: const Color(0xFF032B21),
                        labelColor: Colors.white70,
                        valueColor: const Color(0xFFFB923C),
                        height: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Date Filter Toolbar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Today', 'This Week', 'This Month'].map((range) {
                final isSel = _auditDateRange == range;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(range == 'All' ? 'All Time' : range),
                    selected: isSel,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: isSel ? Colors.white : AppColors.textPrimary,
                    ),
                    onSelected: (_) => setState(() => _auditDateRange = range),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 1. Submitted Daily Closings (Expandable)
          ModernExpandableCard(
            title: 'Submitted Daily Closings',
            subtitle: 'Reconcile net drawer cash, gross revenue & discrepancy notes',
            icon: Icons.point_of_sale_rounded,
            gradientColors: const [Color(0xFF0F766E), Color(0xFF14B8A6)],
            badgeText: '${filteredClosings.length} Reports',
            badgeColor: const Color(0xFF0F766E),
            initiallyExpanded: true,
            padding: EdgeInsets.zero,
            child: filteredClosings.isEmpty
                ? _buildEmptyState('No daily shift closings found for $_auditDateRange.', Icons.point_of_sale)
                : Column(
                    children: filteredClosings.map((c) => _buildClosingAuditCard(context, state, c, isMobile)).toList(),
                  ),
          ),

          // 2. Digital Payment Receipts (Expandable)
          ModernExpandableCard(
            title: 'Digital Payment Receipts & Verification',
            subtitle: 'Telebirr, CBE Birr, Awash, BoA screenshot audits',
            icon: Icons.qr_code_scanner_rounded,
            gradientColors: const [AppColors.telebirrBlue, Color(0xFF0284C7)],
            badgeText: '${filteredDigitalBookings.length} Receipts',
            badgeColor: AppColors.telebirrBlue,
            initiallyExpanded: false,
            padding: EdgeInsets.zero,
            child: filteredDigitalBookings.isEmpty
                ? _buildEmptyState('No digital payment receipts found for $_auditDateRange.', Icons.qr_code_scanner_rounded)
                : Column(
                    children: filteredDigitalBookings.map((b) => _buildDigitalPaymentCard(context, state, b, isMobile)).toList(),
                  ),
          ),

          // 3. Bank Deposits Log (Expandable)
          ModernExpandableCard(
            title: 'Cash Recieved by Cashier Deposited to Bank Log',
            subtitle: 'Stamped bank deposit slips (Account A CBE & Account B Awash)',
            icon: Icons.account_balance_rounded,
            gradientColors: const [Colors.indigo, Color(0xFF4F46E5)],
            badgeText: '${filteredDeposits.length} Slips',
            badgeColor: Colors.indigo,
            initiallyExpanded: false,
            padding: EdgeInsets.zero,
            child: filteredDeposits.isEmpty
                ? _buildEmptyState('No bank deposit slips found for $_auditDateRange.', Icons.receipt_outlined)
                : Column(
                    children: filteredDeposits.map((d) => _buildDepositCard(context, state, d, isMobile)).toList(),
                  ),
          ),

          // 4. Petty Cash Log (Expandable)
          ModernExpandableCard(
            title: 'Petty Cash & Emergency Spend Log',
            subtitle: 'Drawer deductions for station emergency supplies & vouchers',
            icon: Icons.outbox_rounded,
            gradientColors: const [Colors.deepOrange, Color(0xFFF97316)],
            badgeText: '${filteredPetty.length} Vouchers',
            badgeColor: Colors.deepOrange,
            initiallyExpanded: false,
            padding: EdgeInsets.zero,
            child: filteredPetty.isEmpty
                ? _buildEmptyState('No petty cash expenses found for $_auditDateRange.', Icons.outbox_rounded)
                : Column(
                    children: filteredPetty.map((p) => _buildPettyCashCard(context, state, p, isMobile)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosingAuditCard(BuildContext context, dynamic state, DailyFinancialClosing c, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: const Color(0xFF0F766E).withValues(alpha: 0.25), width: 1.2),
      ),
      elevation: 2,
      shadowColor: const Color(0xFF0F766E).withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('${c.closingDate.day}/${c.closingDate.month}/${c.closingDate.year} • Cashier: ${c.cashierName}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                const Spacer(),
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
                _buildKpiPill('Washer 15%', '- ${CurrencyFormatter.format(c.commissionPool)}', Colors.orange),
                _buildKpiPill('Net Drawer Cash', CurrencyFormatter.format(c.cashRevenue), Colors.green),
              ],
            ),
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
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text('${e.key}: ${CurrencyFormatter.format(e.value)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
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
    final isAwash = d.targetAccount.toLowerCase().contains('awash');
    final bankColor = isAwash ? const Color(0xFF0284C7) : const Color(0xFF701A75);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: bankColor.withValues(alpha: 0.25), width: 1.2),
      ),
      elevation: 2,
      shadowColor: bankColor.withValues(alpha: 0.08),
      child: ListTile(
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
    const pettyColor = Color(0xFFEA580C);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: pettyColor.withValues(alpha: 0.25), width: 1.2),
      ),
      elevation: 2,
      shadowColor: pettyColor.withValues(alpha: 0.08),
      child: ListTile(
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

  Widget _buildDigitalPaymentCard(BuildContext context, dynamic state, WashBooking b, [bool isMobile = false]) {
    final method = b.payment.method;
    final hasScreenshot = b.payment.receiptScreenshot != null && b.payment.receiptScreenshot!.isNotEmpty;
    final date = b.payment.paidAt ?? b.createdAt;
    final dateStr = '${date.day}/${date.month} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final payColor = method.color;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: payColor.withValues(alpha: 0.25), width: 1.2),
      ),
      elevation: 2,
      shadowColor: payColor.withValues(alpha: 0.08),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: method.color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(method.icon, color: method.color, size: 20),
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
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('No photo', style: TextStyle(fontSize: 10, color: Colors.grey)),
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
          width: 450,
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
    final weeklyPool = state.weeklyTotalCommissionPool as double;
    final monthlySalary = state.monthlyTotalBaseSalary as double;
    final weeklyReports = state.weeklyCommissionReports as List<WeeklyCommissionReport>;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 2-Tier Compensation Header Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('2-Tier Compensation Structure', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                      child: const Text('Weekly Comm + Monthly Wage', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10.5)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weekly Commission Pool', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(CurrencyFormatter.format(weeklyPool), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.white24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Monthly Base Salaries', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          const SizedBox(height: 2),
                          Text(CurrencyFormatter.format(monthlySalary), style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Mirrored Unified Washer Roster & Commission Pool (from Cashier Dashboard)
          UnifiedWasherRosterCard(isMobile: isMobile),
          const SizedBox(height: 20),

          // Weekly Submission Reports & One-Click Disbursement
          const Text('Weekly Commission Submission Reports:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (weeklyReports.isEmpty)
            _buildEmptyState('No weekly commission reports submitted yet.', Icons.date_range)
          else
            ...weeklyReports.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${r.weekStartDate.day}/${r.weekStartDate.month} – ${r.weekEndDate.day}/${r.weekEndDate.month} • Pool: ${CurrencyFormatter.format(r.totalWeeklyPool)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
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
            )),
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
          const Text(
            'Daily Consumed Supplies Reported by Storekeeper (Empty-for-Full):',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (consumed.isEmpty)
            _buildEmptyState('No daily consumable usage reported by storekeeper yet.', Icons.autorenew_rounded)
          else
            ...consumed.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            )),

          const SizedBox(height: 20),

          // 2. Inventory Goods Received Notes (GRN - Supplier Purchases)
          const Text(
            'Inventory Goods Received Notes (GRN - Purchases):',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (restocks.isEmpty)
            _buildEmptyState('No inventory purchases logged by storekeeper yet.', Icons.shopping_bag_outlined)
          else
            ...restocks.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            )),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 4: PROFIT & LOSS (P&L) STATEMENT
  // ==========================================

  Widget _buildPnLTab(BuildContext context, dynamic state, bool isMobile) {
    final paidBookings = state.bookings.where((b) => b.payment.isPaid).toList();
    final grossRevenue = paidBookings.fold(0.0, (sum, b) => sum + b.totalPrice);
    final commissionPaid = state.commissionLogs.fold(0.0, (sum, l) => sum + l.commissionEarnedETB);
    final suppliesCost = (state.stockTransactions as List<StockTransaction>)
        .where((t) => t.type == 'receiveStock' || t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption')
        .fold(0.0, (sum, t) => sum + t.totalCostEtb);
    final pettyCost = (state.pettyCashExpenses as List<PettyCashExpense>)
        .fold(0.0, (sum, p) => sum + p.amount);
    final fixedAssetsCost = 0.0;
    final monthlySalaryObligation = state.monthlyTotalBaseSalary as double;

    final cogs = commissionPaid + suppliesCost;
    final grossProfit = grossRevenue - cogs;
    final opex = pettyCost + fixedAssetsCost;
    final netOperatingProfit = grossProfit - opex;
    final netRetainedProfit = netOperatingProfit - monthlySalaryObligation;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: netOperatingProfit >= 0 ? [const Color(0xFF065F46), const Color(0xFF047857)] : [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NET STATION OPERATING PROFIT', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(CurrencyFormatter.format(netOperatingProfit), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Gross Revenue − COGS (Commissions + Consumables) − OpEx (Petty Cash + Equipment)', style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Standard Income & Financial Statement:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),

          // Section 1: Revenue
          const Text('I. OPERATING REVENUE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary)),
          _buildPnLLine('Gross Vehicle Wash Services Revenue', CurrencyFormatter.format(grossRevenue), Colors.green.shade700, false),
          const SizedBox(height: 8),

          // Section 2: COGS
          const Text('II. COST OF GOODS SOLD (COGS)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.orange)),
          _buildPnLLine('Washer Team 15% Commissions', '- ${CurrencyFormatter.format(commissionPaid)}', Colors.orange.shade800, false),
          _buildPnLLine('Consumables Used & Soap Restocks', '- ${CurrencyFormatter.format(suppliesCost)}', Colors.orange.shade800, false),
          _buildPnLLine('Total Cost of Goods Sold', '- ${CurrencyFormatter.format(cogs)}', Colors.orange.shade900, true),
          const Divider(thickness: 1, height: 16),
          _buildPnLLine('GROSS PROFIT', CurrencyFormatter.format(grossProfit), grossProfit >= 0 ? Colors.green.shade800 : Colors.red, true),
          const SizedBox(height: 8),

          // Section 3: OpEx
          const Text('III. OPERATING EXPENSES (OPEX)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.deepOrange)),
          _buildPnLLine('Cashier Petty Cash / Emergency Spends', '- ${CurrencyFormatter.format(pettyCost)}', Colors.deepOrange.shade700, false),
          _buildPnLLine('Fixed Assets & Machinery Purchases', '- ${CurrencyFormatter.format(fixedAssetsCost)}', Colors.deepOrange.shade700, false),
          _buildPnLLine('Total Operating Expenses', '- ${CurrencyFormatter.format(opex)}', Colors.deepOrange.shade900, true),
          const Divider(thickness: 1.5, height: 20),

          // Section 4: Net Operating Profit
          _buildPnLLine('NET OPERATING PROFIT (EBITDA)', CurrencyFormatter.format(netOperatingProfit), netOperatingProfit >= 0 ? Colors.green.shade800 : Colors.red, true),
          const Divider(thickness: 1, height: 20),

          // Section 5: Base Salary Reserve
          const Text('IV. GUARANTEED MONTHLY PAYROLL RESERVE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.blueGrey)),
          _buildPnLLine('Guaranteed Monthly Base Salary Reserve', CurrencyFormatter.format(monthlySalaryObligation), Colors.blueGrey, false),
          _buildPnLLine('Net Retained Cash Profit', CurrencyFormatter.format(netRetainedProfit), netRetainedProfit >= 0 ? Colors.teal.shade800 : Colors.red, true),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500)),
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
