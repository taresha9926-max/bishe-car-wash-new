import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../../domain/models/bank_deposit_record.dart';
import '../../domain/models/commission_log.dart';
import '../../domain/models/daily_financial_closing.dart';
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
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: isMobile,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.verified_rounded, size: 18), text: 'Cashier & Bank Audits'),
                Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Washer Commissions'),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.cyan.withOpacity(0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.cyanAccent, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cashier Shifts & Bank Deposit Verification', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('Account A (Awash Bank) & Account B (Bank of Abyssinia) Slip Audits', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Submitted Daily Closings:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (closings.isEmpty)
            _buildEmptyState('No daily shift closings submitted by cashier yet.', Icons.point_of_sale)
          else
            ...closings.map((c) => _buildClosingAuditCard(context, state, c, isMobile)),

          const SizedBox(height: 20),
          const Text('Bank Deposit Slips Log:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (deposits.isEmpty)
            _buildEmptyState('No bank deposit slips logged yet.', Icons.receipt_outlined)
          else
            ...deposits.map((d) => _buildDepositCard(context, state, d, isMobile)),
        ],
      ),
    );
  }

  Widget _buildClosingAuditCard(BuildContext context, dynamic state, DailyFinancialClosing c, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.green.shade300)),
                  child: Text(c.isConfirmed ? 'CONFIRMED ✅' : 'PENDING', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                ),
              ],
            ),
            const Divider(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildKpiPill('Gross Revenue', 'ETB ${c.grossRevenue.toStringAsFixed(0)}', Colors.blueGrey),
                _buildKpiPill('Washer 15%', '- ETB ${c.commissionPool.toStringAsFixed(0)}', Colors.orange),
                _buildKpiPill('Net Drawer Cash', 'ETB ${c.cashRevenue.toStringAsFixed(0)}', Colors.green),
              ],
            ),
            if (c.providerBreakdown.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('Digital Money Breakdown:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: c.providerBreakdown.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                    child: Text('${e.key}: ETB ${e.value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Bank Deposited: ETB ${c.cashDeposited.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.indigo)),
                const SizedBox(width: 12),
                Text('Drawer Remaining: ETB ${c.cashRemaining.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.black87)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepositCard(BuildContext context, dynamic state, BankDepositRecord d, bool isMobile) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade50,
          child: const Icon(Icons.account_balance, color: AppColors.primary, size: 20),
        ),
        title: Text('ETB ${d.amount.toStringAsFixed(0)} ➔ ${d.targetAccount}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
        subtitle: Text('Slip #: ${d.referenceSlipNumber} • Cashier: ${d.cashierName}', style: const TextStyle(fontSize: 11.5)),
        trailing: d.receiptScreenshot != null && d.receiptScreenshot!.isNotEmpty
            ? TextButton.icon(
                icon: const Icon(Icons.visibility, size: 14),
                label: const Text('View Slip', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Bank Deposit Slip: ${d.referenceSlipNumber}'),
                      content: Image.network(d.receiptScreenshot!, errorBuilder: (c, e, s) => const Text('Could not load slip image')),
                    ),
                  );
                },
              )
            : const Text('No photo', style: TextStyle(fontSize: 11, color: Colors.grey)),
      ),
    );
  }

  // ==========================================
  // TAB 2: WASHER COMMISSIONS & PAYROLL
  // ==========================================

  Widget _buildCommissionsTab(BuildContext context, dynamic state, bool isMobile) {
    final logs = state.commissionLogs as List<CommissionLog>;
    final weeklyReports = state.weeklyCommissionReports as List<WeeklyCommissionReport>;
    final totalPaid = logs.fold(0.0, (sum, l) => sum + l.commissionEarnedETB);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Washer Commissions Distributed', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('ETB ${totalPaid.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Text('15% Team Pool', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Weekly Commission Submission Reports:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (weeklyReports.isEmpty)
            _buildEmptyState('No weekly commission reports submitted yet.', Icons.date_range)
          else
            ...weeklyReports.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                title: Text('${r.weekStartDate.day}/${r.weekStartDate.month} - ${r.weekEndDate.day}/${r.weekEndDate.month} • Pool: ETB ${r.totalWeeklyPool.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                subtitle: Text('Reported by: ${r.cashierName} • Washers: ${r.washerCommissions.length}', style: const TextStyle(fontSize: 11.5)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(6)),
                  child: Text('DISBURSED', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.green.shade800)),
                ),
              ),
            )),
          const SizedBox(height: 18),
          const Text('Recent Commission Line Items:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          ...logs.take(15).map((l) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              dense: true,
              leading: const Icon(Icons.monetization_on_outlined, color: Colors.green, size: 20),
              title: Text('${l.washerName} • ${l.carPlate}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
              subtitle: Text(l.servicePackageName, style: const TextStyle(fontSize: 11)),
              trailing: Text('+ ETB ${l.commissionEarnedETB.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.green, fontSize: 12.5)),
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
    final totalSpent = restocks.fold(0.0, (sum, t) => sum + t.totalCostEtb);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Consumables & Stock Purchases', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text('ETB ${totalSpent.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.inventory_rounded, color: Colors.white70, size: 30),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Storekeeper Stock Inflows & Purchases:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          if (restocks.isEmpty)
            _buildEmptyState('No inventory purchases logged by storekeeper yet.', Icons.shopping_bag_outlined)
          else
            ...restocks.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.amber.shade50, child: const Icon(Icons.shopping_bag, color: Colors.amber, size: 18)),
                title: Text('${t.itemName} (+${t.quantity.toStringAsFixed(0)})', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                subtitle: Text('${t.date.day}/${t.date.month}/${t.date.year} • Supplier: ${t.supplier.isNotEmpty ? t.supplier : "Direct Purchase"}', style: const TextStyle(fontSize: 11.5)),
                trailing: Text('ETB ${t.totalCostEtb.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87, fontSize: 13)),
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
        .where((t) => t.type == 'receiveStock')
        .fold(0.0, (sum, t) => sum + t.totalCostEtb);
    final netProfit = grossRevenue - commissionPaid - suppliesCost;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: netProfit >= 0 ? [const Color(0xFF065F46), const Color(0xFF047857)] : [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NET STATION OPERATING PROFIT', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text('ETB ${netProfit.toStringAsFixed(0)}', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                const Text('Gross Revenue − Washer Commissions − Supplies Expenses', style: TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Executive Financial Summary:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          _buildPnLLine('1. Total Gross Wash Revenue', 'ETB ${grossRevenue.toStringAsFixed(0)}', Colors.green.shade700, false),
          _buildPnLLine('2. Washer Team 15% Commissions', '- ETB ${commissionPaid.toStringAsFixed(0)}', Colors.orange.shade800, false),
          _buildPnLLine('3. Consumables & Soap Restock Cost', '- ETB ${suppliesCost.toStringAsFixed(0)}', Colors.red.shade700, false),
          const Divider(thickness: 1.5, height: 24),
          _buildPnLLine('Net Profit After Direct Wash Costs', 'ETB ${netProfit.toStringAsFixed(0)}', netProfit >= 0 ? Colors.green.shade800 : Colors.red, true),
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
        Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
      ],
    );
  }

  Widget _buildEmptyState(String msg, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(msg, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
