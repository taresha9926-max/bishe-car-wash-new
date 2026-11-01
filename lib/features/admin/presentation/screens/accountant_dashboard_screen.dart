import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_role_header.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../domain/models/staff_member.dart';
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
  int _selectedWeekOffset = 0; // 0 = current week, 1 = prev week
  String _auditDateRange = 'All'; // All, Today, This Week, This Month

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
                  decoration: BoxDecoration(color: Colors.cyan.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_rounded, color: Colors.cyanAccent, size: 24),
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

          Text(
            'Submitted Daily Closings (${filteredClosings.length}):',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (filteredClosings.isEmpty)
            _buildEmptyState('No daily shift closings found for $_auditDateRange.', Icons.point_of_sale)
          else
            ...filteredClosings.map((c) => _buildClosingAuditCard(context, state, c, isMobile)),

          const SizedBox(height: 20),
          Text(
            'Bank Deposit Slips Log (${filteredDeposits.length}):',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (filteredDeposits.isEmpty)
            _buildEmptyState('No bank deposit slips found for $_auditDateRange.', Icons.receipt_outlined)
          else
            ...filteredDeposits.map((d) => _buildDepositCard(context, state, d, isMobile)),

          const SizedBox(height: 20),
          Text(
            'Petty Cash & Emergency Spend Log (${filteredPetty.length}):',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          if (filteredPetty.isEmpty)
            _buildEmptyState('No petty cash expenses found for $_auditDateRange.', Icons.outbox_rounded)
          else
            ...filteredPetty.map((p) => _buildPettyCashCard(context, state, p, isMobile)),
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
              const Text('Digital Money Breakdown:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  // ==========================================
  // TAB 2: TABULAR 7-DAY PAYROLL & MATRIX
  // ==========================================

  Widget _buildCommissionsTab(BuildContext context, dynamic state, bool isMobile) {
    final washers = state.availableWashers as List<StaffMember>;
    final weeklyPool = state.weeklyTotalCommissionPool as double;
    final monthlySalary = state.monthlyTotalBaseSalary as double;
    final weeklyReports = state.weeklyCommissionReports as List<WeeklyCommissionReport>;

    // 7 days of the current week (Mon-Sun)
    final now = DateTime.now().subtract(Duration(days: _selectedWeekOffset * 7));
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final weekDays = List.generate(7, (i) => monday.add(Duration(days: i)));

    final List<String> dayLabels = [
      state.tr('monShort') as String,
      state.tr('tueShort') as String,
      state.tr('wedShort') as String,
      state.tr('thuShort') as String,
      state.tr('friShort') as String,
      state.tr('satShort') as String,
      state.tr('sunShort') as String,
    ];

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
          const SizedBox(height: 18),

          // Date Filter Toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.tr('weeklyPayrollMatrix'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    onPressed: () => setState(() => _selectedWeekOffset++),
                    tooltip: 'Previous Week',
                  ),
                  Text(
                    _selectedWeekOffset == 0
                        ? 'Current Week'
                        : '$_selectedWeekOffset Week Ago',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    onPressed: _selectedWeekOffset > 0 ? () => setState(() => _selectedWeekOffset--) : null,
                    tooltip: 'Next Week',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Payroll View: Mobile Individual Cards vs Desktop Tabular Matrix
          if (isMobile)
            Column(
              children: washers.map((w) {
                final weeklyComm = (state.weeklyWasherCommissions as Map<String, double>)[w.name] ?? 0.0;
                final isPresentToday = state.isWasherPresentToday(w.id);
                return _buildMobileWasherCard(context, state, w, weeklyComm, isPresentToday, weekDays, dayLabels);
              }).toList(),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                  columnSpacing: 14,
                  horizontalMargin: 12,
                  columns: [
                    const DataColumn(label: Text('Washer', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                    const DataColumn(label: Text('Tier', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                    ...List.generate(7, (i) => DataColumn(
                      label: Text('${dayLabels[i]}\n${weekDays[i].day}', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                    )),
                    const DataColumn(label: Text('Active', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                    DataColumn(label: Text(state.tr('weeklyCommEarned'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                    DataColumn(label: Text(state.tr('monthlySalary'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
                  ],
                  rows: washers.map((w) {
                    final weeklyComm = (state.weeklyWasherCommissions as Map<String, double>)[w.name] ?? 0.0;
                    final isPresentToday = state.isWasherPresentToday(w.id);

                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: Text(w.name.isNotEmpty ? w.name[0] : 'W', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ),
                              const SizedBox(width: 6),
                              Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                            ],
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(6)),
                            child: Text('T${w.skillSeniorityLevel}', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.blue.shade900)),
                          ),
                        ),
                        // 7 days (Mon-Sun)
                        ...List.generate(7, (dayIdx) {
                          final dayDate = weekDays[dayIdx];
                          final isTodayCol = dayDate.day == DateTime.now().day &&
                              dayDate.month == DateTime.now().month &&
                              _selectedWeekOffset == 0;
                          final att = state.getWasherAttendanceForDate(w.id, dayDate);
                          final isPresent = isTodayCol ? isPresentToday : (att?.isPresent ?? true);
                          final earned = isTodayCol
                              ? (state.isDailyCommissionDisbursedToday
                                  ? (state.washerDividendsToday[w.id]?.earnedETB ?? 0.0)
                                  : 0.0)
                              : (att?.commissionEarnedETB ?? 0.0);
                          final hasDisbursed = (isTodayCol && state.isDailyCommissionDisbursedToday) ||
                              (att != null && att.commissionEarnedETB > 0);

                          String label;
                          if (!isPresent) {
                            label = 'A';
                          } else if (hasDisbursed && earned > 0) {
                            label = 'P • Br ${earned.toStringAsFixed(0)}';
                          } else {
                            label = 'P';
                          }

                          return DataCell(
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isPresent ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isPresent ? Colors.green.shade200 : Colors.red.shade200,
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    color: isPresent ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        const DataCell(Center(child: Text('6d', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)))),
                        DataCell(Text(CurrencyFormatter.format(weeklyComm), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.green))),
                        DataCell(Text(CurrencyFormatter.format(w.baseSalaryMonthlyETB), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSecondary))),
                      ],
                    );
                  }).toList()
                    ..add(
                      DataRow(
                        color: WidgetStateProperty.all(AppColors.surfaceVariant),
                        cells: [
                          const DataCell(
                            Text(
                              'Daily Total Pool',
                              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, color: AppColors.primary),
                            ),
                          ),
                          const DataCell(
                            Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 10, color: AppColors.primary)),
                          ),
                          ...List.generate(7, (dayIdx) {
                            final dayDate = weekDays[dayIdx];
                            final isTodayCol = dayDate.day == DateTime.now().day &&
                                dayDate.month == DateTime.now().month &&
                                _selectedWeekOffset == 0;
                            final dailyTotal = (isTodayCol && state.isDailyCommissionDisbursedToday)
                                ? state.teamCommissionPoolTodayETB
                                : state.getDailyCommissionTotalForDate(dayDate);

                            return DataCell(
                              Center(
                                child: Text(
                                  dailyTotal > 0 ? CurrencyFormatter.format(dailyTotal) : '-',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w900,
                                    color: dailyTotal > 0 ? Colors.green.shade800 : AppColors.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }),
                          const DataCell(Center(child: Text('—', style: TextStyle(color: AppColors.textMuted)))),
                          DataCell(Text(
                            CurrencyFormatter.format(weeklyPool),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: Colors.green),
                          )),
                          DataCell(Text(
                            CurrencyFormatter.format(monthlySalary),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11.5, color: AppColors.textSecondary),
                          )),
                        ],
                      ),
                    ),
                ),
              ),
            ),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 400,
          child: Image.network(
            imageUrl,
            errorBuilder: (c, e, s) => const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Unable to preview image data.'),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _buildMobileWasherCard(
    BuildContext context,
    dynamic state,
    StaffMember w,
    double weeklyComm,
    bool isPresentToday,
    List<DateTime> weekDays,
    List<String> dayLabels,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  w.name.isNotEmpty ? w.name[0] : 'W',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(w.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                          child: Text('Tier ${w.skillSeniorityLevel}', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.blue.shade900)),
                        ),
                        const SizedBox(width: 6),
                        Text(w.phone, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(weeklyComm),
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: Colors.green),
                  ),
                  Text(
                    state.tr('weeklyCommEarned'),
                    style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Mon-Sun Attendance Day Chips (Fits across screen without scrolling!)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder.withOpacity(0.6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (dayIdx) {
                final isTodayCol = weekDays[dayIdx].day == DateTime.now().day && _selectedWeekOffset == 0;
                final isPresent = isTodayCol ? isPresentToday : true;
                return Column(
                  children: [
                    Text(dayLabels[dayIdx], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 3),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isPresent ? Colors.green.shade100 : Colors.red.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(color: isPresent ? Colors.green.shade400 : Colors.red.shade400),
                      ),
                      child: Center(
                        child: Icon(
                          isPresent ? Icons.check_rounded : Icons.close_rounded,
                          size: 12,
                          color: isPresent ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.tr("monthlySalary")}: ${CurrencyFormatter.format(w.baseSalaryMonthlyETB)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('6/7 Days Present', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: Colors.green)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
