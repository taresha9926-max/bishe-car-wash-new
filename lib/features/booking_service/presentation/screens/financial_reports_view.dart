import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/receipt_image_helper.dart';
import '../../../../core/widgets/financial_pnl_statement_card.dart';
import '../../../../core/widgets/language_switcher_action.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../admin/domain/models/bank_deposit_record.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../domain/models/payment_info.dart';
import '../state/app_state_provider.dart';

enum FinancialReportFilter {
  today,
  yesterday,
  thisWeek,
  thisMonth,
  customRange;

  String localizedLabel(dynamic state) {
    switch (this) {
      case FinancialReportFilter.today:
        return state.tr('filterToday');
      case FinancialReportFilter.yesterday:
        return state.tr('filterYesterday');
      case FinancialReportFilter.thisWeek:
        return state.tr('filterThisWeek');
      case FinancialReportFilter.thisMonth:
        return state.tr('filterThisMonth');
      case FinancialReportFilter.customRange:
        return state.tr('filterCustomRange');
    }
  }
}

class FinancialReportsView extends StatefulWidget {
  final bool isEmbedded;
  final bool isCashierMode;
  final FinancialReportFilter? initialFilter;
  final DateTimeRange? initialCustomRange;

  const FinancialReportsView({
    super.key,
    this.isEmbedded = false,
    this.isCashierMode = false,
    this.initialFilter,
    this.initialCustomRange,
  });

  @override
  State<FinancialReportsView> createState() => _FinancialReportsViewState();
}

class _FinancialReportsViewState extends State<FinancialReportsView> {
  late FinancialReportFilter _periodFilter;
  DateTimeRange? _customRange;

  @override
  void initState() {
    super.initState();
    _periodFilter = widget.initialFilter ?? FinancialReportFilter.today;
    _customRange = widget.initialCustomRange;
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

  String _consolidatedTitle(dynamic state, DateTime rangeStart, DateTime rangeEnd) {
    switch (_periodFilter) {
      case FinancialReportFilter.today:
      case FinancialReportFilter.yesterday:
        return state.tr('consolidatedDailyTitle');
      case FinancialReportFilter.thisWeek:
        return state.tr('consolidatedWeeklyTitle');
      case FinancialReportFilter.thisMonth:
        return state.tr('consolidatedMonthlyTitle');
      case FinancialReportFilter.customRange:
        final label = '${_formatDate(rangeStart)} - ${_formatDate(rangeEnd)}';
        return '${state.tr("consolidatedCustomPrefix")} [$label] ${state.tr("consolidatedCustomSuffix")}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final now = DateTime.now();
    late DateTime rangeStart;
    late DateTime rangeEnd;

    switch (_periodFilter) {
      case FinancialReportFilter.today:
        rangeStart = DateTime(now.year, now.month, now.day);
        rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case FinancialReportFilter.yesterday:
        final y = now.subtract(const Duration(days: 1));
        rangeStart = DateTime(y.year, y.month, y.day);
        rangeEnd = DateTime(y.year, y.month, y.day, 23, 59, 59);
        break;
      case FinancialReportFilter.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        rangeStart = DateTime(monday.year, monday.month, monday.day);
        rangeEnd = rangeStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case FinancialReportFilter.thisMonth:
        rangeStart = DateTime(now.year, now.month, 1);
        rangeEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case FinancialReportFilter.customRange:
        if (_customRange != null) {
          rangeStart = DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day);
          rangeEnd = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
        } else {
          rangeStart = DateTime(now.year, now.month, now.day);
          rangeEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
        }
        break;
    }

    bool inRange(DateTime dt) =>
        (dt.isAfter(rangeStart) || dt.isAtSameMomentAs(rangeStart)) &&
        (dt.isBefore(rangeEnd) || dt.isAtSameMomentAs(rangeEnd));

    final periodBookings = state.bookings
        .where((b) => b.payment.isPaid && inRange(b.payment.paidAt ?? b.createdAt))
        .toList();

    final periodCarBookings = periodBookings.where((b) => !b.isCarpet).toList();
    final periodCarpetBookings = periodBookings.where((b) => b.isCarpet).toList();
    final periodShowers = state.showerRecords.where((s) => inRange(s.recordedAt)).toList();

    final carRevenue = periodCarBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final carpetRevenue = periodCarpetBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final totalTips = periodBookings.fold<double>(0.0, (sum, b) => sum + b.payment.tipAmount);
    final showerRevenue = periodShowers.fold<double>(0.0, (sum, s) => sum + s.totalAmount);
    final showerCount = periodShowers.fold<int>(0, (sum, s) => sum + s.userCount);
    final showerCash = periodShowers
        .where((s) => s.paymentMethod == PaymentMethod.cash)
        .fold<double>(0.0, (sum, s) => sum + s.totalAmount);

    final grossRevenue = carRevenue + carpetRevenue + totalTips + showerRevenue;
    final serviceCash = periodBookings
        .where((b) => b.payment.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice + b.payment.tipAmount);
    final cashRevenue = serviceCash + showerCash;
    final digitalRevenue = grossRevenue - cashRevenue;
    final vatDeducted = (carRevenue + carpetRevenue) * 0.15;
    final netServiceRevenue = (carRevenue + carpetRevenue) - vatDeducted;
    final commissionDeducted = (netServiceRevenue * state.teamCommissionRate) + totalTips;
    final netStationProfit = (grossRevenue - vatDeducted) - commissionDeducted;

    final periodPettyCash = state.pettyCashExpenses
        .where((e) => inRange(e.loggedAt))
        .fold<double>(0.0, (sum, e) => sum + e.amount);
    final periodSupplies = state.stockTransactions
        .where((t) =>
            inRange(t.date) &&
            (t.type == 'receiveStock' || t.type == 'emptyExchangeConsumption' || t.type == 'dailyConsumption'))
        .fold<double>(0.0, (sum, t) => sum + t.totalCostEtb);

    final periodDeposits = state.bankDeposits.where((d) => inRange(d.depositedAt)).toList();
    final totalCashDeposited = periodDeposits.fold<double>(0.0, (sum, d) => sum + d.amount);

    final periodClosings = state.dailyFinancialClosings.where((c) => inRange(c.closingDate)).toList();

    final dynamicTitle = _consolidatedTitle(state, rangeStart, rangeEnd);
    final rangeCaption = '${_formatDate(rangeStart)} - ${_formatDate(rangeEnd)}';

    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterBar(context, state),
        const SizedBox(height: 14),

        // Header & Service Division Revenue Table
        _buildTabularSectionCard(
          title: dynamicTitle,
          badge: rangeCaption,
          icon: Icons.assessment_rounded,
          accentColor: AppColors.primary,
          table: _buildDivisionTable(
            context: context,
            state: state,
            carRevenue: carRevenue,
            carCount: periodCarBookings.length,
            carpetRevenue: carpetRevenue,
            carpetCount: periodCarpetBookings.length,
            showerRevenue: showerRevenue,
            showerCount: showerCount,
            tipsTotal: totalTips,
          ),
        ),
        const SizedBox(height: 14),

        // Collections & Profit Summary Table (replaces old grid cards)
        _buildTabularSectionCard(
          title: state.tr('paymentSummaryTableTitle'),
          badge: '${periodBookings.length} ${state.tr("carsWashed")}',
          icon: Icons.table_chart_rounded,
          accentColor: AppColors.cashGreen,
          table: _buildCollectionsTable(
            context: context,
            state: state,
            grossRevenue: grossRevenue,
            vatDeducted: vatDeducted,
            cashRevenue: cashRevenue,
            digitalRevenue: digitalRevenue,
            commissionDeducted: commissionDeducted,
            netStationProfit: netStationProfit,
            totalCashDeposited: totalCashDeposited,
            carCount: periodCarBookings.length,
            carpetCount: periodCarpetBookings.length,
            depositCount: periodDeposits.length,
          ),
        ),
        const SizedBox(height: 14),

        // Financial Statement (P&L) synchronized with selected date range (hidden for Cashier mode)
        if (!widget.isCashierMode) ...[
          FinancialPnlStatementCard(
            state: state,
            isMobile: isMobile,
            periodSubtitle: rangeCaption,
            totalRevenue: grossRevenue,
            vatDeducted: vatDeducted,
            commissionPool: commissionDeducted,
            totalPettyCash: periodPettyCash,
            totalSupplies: periodSupplies,
          ),
          const SizedBox(height: 16),
        ],

        // Shift Closings Table
        _buildDailyClosingsTableCard(context, state, periodClosings),
        const SizedBox(height: 16),

        // Bank Deposits Table
        _buildBankDepositsTableCard(context, state, periodDeposits),
        const SizedBox(height: 30),
      ],
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(dynamicTitle, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: const [
          LanguageSwitcherAction(isDark: false),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : (isMobile ? 12 : 20),
              vertical: 16,
            ),
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, dynamic state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 6),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: FinancialReportFilter.values.map((filter) {
          final isSelected = filter == _periodFilter;
          return ChoiceChip(
              label: Text(
                filter == FinancialReportFilter.customRange && _customRange != null
                    ? '${_customRange!.start.day}/${_customRange!.start.month}/${_customRange!.start.year} - ${_customRange!.end.day}/${_customRange!.end.month}/${_customRange!.end.year}'
                    : filter.localizedLabel(state),
                style: TextStyle(
                  fontSize: 12,
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
              onSelected: (_) async {
                if (filter == FinancialReportFilter.customRange) {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 1),
                    lastDate: DateTime(now.year + 1),
                    initialDateRange: _customRange ?? DateTimeRange(
                      start: now.subtract(const Duration(days: 7)),
                      end: now,
                    ),
                  );
                  if (picked != null && mounted) {
                    setState(() {
                      _periodFilter = filter;
                      _customRange = picked;
                    });
                  }
                } else {
                  setState(() => _periodFilter = filter);
                }
              },
            );
          }).toList(),
        ),
      );
  }

  Widget _buildTabularSectionCard({
    required String title,
    required String badge,
    required IconData icon,
    required Color accentColor,
    required Widget table,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: accentColor, size: 19),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: accentColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: table,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivisionTable({
    required BuildContext context,
    required dynamic state,
    required double carRevenue,
    required int carCount,
    required double carpetRevenue,
    required int carpetCount,
    required double showerRevenue,
    required int showerCount,
    required double tipsTotal,
  }) {
    final rows = [
      (label: state.tr('carWashSubtotal'), detail: '$carCount ${state.tr("carsWashed")}', amount: CurrencyFormatter.format(carRevenue), color: const Color(0xFF1E3A8A)),
      (label: state.tr('carpetWashSubtotal'), detail: '$carpetCount ${state.tr("myCarpetCleanings")}', amount: CurrencyFormatter.format(carpetRevenue), color: const Color(0xFF7C3AED)),
      (label: state.tr('showerSubtotal'), detail: '$showerCount ${state.tr("showerUsers")}', amount: CurrencyFormatter.format(showerRevenue), color: const Color(0xFF0284C7)),
      if (tipsTotal > 0)
        (label: state.tr('washerTipsSubtotal'), detail: '100% Washers', amount: CurrencyFormatter.format(tipsTotal), color: Colors.amber.shade900),
    ];

    final isMobile = ResponsiveLayout.isMobile(context);
    if (isMobile) {
      return Column(
        children: rows.map((r) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: r.color)),
                    const SizedBox(height: 2),
                    Text(r.detail, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(r.amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: r.color)),
            ],
          ),
        )).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
        columnSpacing: 18,
        horizontalMargin: 12,
        columns: [
          DataColumn(label: Text(state.tr('categoryColLabel'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          DataColumn(label: Text(state.tr('countColLabel'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          DataColumn(label: Text(state.tr('amountColLabel'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
        ],
        rows: rows
            .map((r) => DataRow(cells: [
                  DataCell(Text(r.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: r.color))),
                  DataCell(Text(r.detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                  DataCell(Text(r.amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: r.color))),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildCollectionsTable({
    required BuildContext context,
    required dynamic state,
    required double grossRevenue,
    required double vatDeducted,
    required double cashRevenue,
    required double digitalRevenue,
    required double commissionDeducted,
    required double netStationProfit,
    required double totalCashDeposited,
    required int carCount,
    required int carpetCount,
    required int depositCount,
  }) {
    final rows = [
      (label: state.tr('totalRevenue'), detail: '$carCount Cars • $carpetCount Carpets', amount: CurrencyFormatter.format(grossRevenue), color: AppColors.primary),
      (label: state.tr('vatDeduction15Label'), detail: '15% Wash & Delivery VAT', amount: '- ${CurrencyFormatter.format(vatDeducted)}', color: Colors.deepPurple),
      (label: state.tr('cashCollected'), detail: state.tr('cashCollected'), amount: CurrencyFormatter.format(cashRevenue), color: AppColors.cashGreen),
      (label: state.tr('digitalPay'), detail: 'Telebirr / CBE / Bank', amount: CurrencyFormatter.format(digitalRevenue), color: AppColors.telebirrBlue),
      (label: state.tr('washerCommissionDeducted'), detail: state.tr('disburseCommission'), amount: '- ${CurrencyFormatter.format(commissionDeducted)}', color: AppColors.oromiaGold),
      if (!widget.isCashierMode)
        (label: state.tr('netStationProfit'), detail: state.tr('afterPayrollCuts'), amount: CurrencyFormatter.format(netStationProfit), color: AppColors.statusCompleted),
      (label: state.tr('bankDepositsLog'), detail: '$depositCount Deposits', amount: CurrencyFormatter.format(totalCashDeposited), color: Colors.indigo),
    ];

    final isMobile = ResponsiveLayout.isMobile(context);
    if (isMobile) {
      return Column(
        children: rows.map((r) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.cardBorder, width: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: r.color)),
                    const SizedBox(height: 2),
                    Text(r.detail, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(r.amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: r.color)),
            ],
          ),
        )).toList(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
        columnSpacing: 18,
        horizontalMargin: 12,
        columns: [
          DataColumn(label: Text(state.tr('categoryColLabel'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          DataColumn(label: Text(state.tr('countColLabel'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
          DataColumn(label: Text(state.tr('amountColLabel'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12))),
        ],
        rows: rows
            .map((r) => DataRow(cells: [
                  DataCell(Text(r.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: r.color))),
                  DataCell(Text(r.detail, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                  DataCell(Text(r.amount, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5, color: r.color))),
                ]))
            .toList(),
      ),
    );
  }

  Widget _buildDailyClosingsTableCard(
    BuildContext context,
    dynamic state,
    List<DailyFinancialClosing> closings,
  ) {
    return _buildTabularSectionCard(
      title: state.tr('closingAndFinancialReports'),
      badge: '${closings.length} Shift Reports',
      icon: Icons.fact_check_rounded,
      accentColor: AppColors.statusCompleted,
      table: closings.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No closed shifts recorded in this time range.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : ResponsiveLayout.isMobile(context)
              ? Column(
                  children: closings.map((c) {
                    final dateStr =
                        '${c.closingDate.year}-${c.closingDate.month.toString().padLeft(2, '0')}-${c.closingDate.day.toString().padLeft(2, '0')}';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(dateStr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('${c.shiftType.toUpperCase()} • ${c.cashierName}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Gross: ${CurrencyFormatter.formatShort(c.grossRevenue)} (${c.carsWashedCount} cars)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Text('Cash: ${CurrencyFormatter.formatShort(c.cashRevenue)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.cashGreen)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Digital: ${CurrencyFormatter.formatShort(c.digitalRevenue)}', style: const TextStyle(fontSize: 11.5, color: AppColors.telebirrBlue, fontWeight: FontWeight.w600)),
                              Text('Comm: -${CurrencyFormatter.formatShort(c.commissionPool)}', style: const TextStyle(fontSize: 11.5, color: AppColors.oromiaGold, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bank Dep: ${CurrencyFormatter.formatShort(c.cashDeposited)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.indigo)),
                              TextButton(
                                onPressed: () => _showClosingDetailModal(context, c),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
                                child: const Text('View Details →', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                columnSpacing: 14,
                horizontalMargin: 12,
                columns: [
                  const DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Shift / Cashier', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Cars', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Gross', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Cash', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Digital', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Comm.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  if (!widget.isCashierMode)
                    const DataColumn(label: Text('Net', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Bank Dep.', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  const DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                ],
                rows: closings.map((c) {
                  final dateStr =
                      '${c.closingDate.year}-${c.closingDate.month.toString().padLeft(2, '0')}-${c.closingDate.day.toString().padLeft(2, '0')}';
                  return DataRow(cells: [
                    DataCell(Text(dateStr, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primary))),
                    DataCell(Text('${c.shiftType.toUpperCase()} • ${c.cashierName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
                    DataCell(Text('${c.carsWashedCount}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                    DataCell(Text(CurrencyFormatter.formatShort(c.grossRevenue), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary))),
                    DataCell(Text(CurrencyFormatter.formatShort(c.cashRevenue), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.cashGreen))),
                    DataCell(Text(CurrencyFormatter.formatShort(c.digitalRevenue), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.telebirrBlue))),
                    DataCell(Text('- ${CurrencyFormatter.formatShort(c.commissionPool)}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.oromiaGold))),
                    if (!widget.isCashierMode)
                      DataCell(Text(CurrencyFormatter.formatShort(c.netStationProfit), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.statusCompleted))),
                    DataCell(Text(CurrencyFormatter.formatShort(c.cashDeposited), style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Colors.indigo))),
                    DataCell(
                      TextButton(
                        onPressed: () => _showClosingDetailModal(context, c),
                        child: const Text('Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildBankDepositsTableCard(
    BuildContext context,
    dynamic state,
    List<BankDepositRecord> deposits,
  ) {
    return _buildTabularSectionCard(
      title: state.tr('bankDepositsLog'),
      badge: '${deposits.length} Deposits',
      icon: Icons.account_balance_rounded,
      accentColor: Colors.indigo,
      table: deposits.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No bank deposits recorded in this date range.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            )
          : ResponsiveLayout.isMobile(context)
              ? Column(
                  children: deposits.map((d) {
                    final isAccountB = d.accountKey == 'account_b';
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder, width: 0.8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAccountB ? 'Account B (Awash)' : 'Account A (CBE)', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Colors.indigo)),
                              Text(CurrencyFormatter.format(d.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.cashGreen)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('Slip Ref: ${d.referenceSlipNumber} • By ${d.cashierName}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(d.depositedAt.toString().substring(0, 16), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                              TextButton.icon(
                                onPressed: () => _showReceiptSlipModal(context, d),
                                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                                icon: const Icon(Icons.image_outlined, size: 13),
                                label: Text(state.tr('viewDepositReceipt'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(AppColors.surfaceVariant),
                columnSpacing: 14,
                horizontalMargin: 12,
                columns: const [
                  DataColumn(label: Text('Account', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  DataColumn(label: Text('Slip Ref', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  DataColumn(label: Text('By', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  DataColumn(label: Text('Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                  DataColumn(label: Text('Receipt', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5))),
                ],
                rows: deposits.map((d) {
                  final isAccountB = d.accountKey == 'account_b';
                  return DataRow(cells: [
                    DataCell(Text(isAccountB ? 'Account B (Awash)' : 'Account A (CBE)', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700))),
                    DataCell(Text(d.referenceSlipNumber, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600))),
                    DataCell(Text(d.cashierName, style: const TextStyle(fontSize: 11.5))),
                    DataCell(Text(d.depositedAt.toString().substring(0, 16), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))),
                    DataCell(Text(CurrencyFormatter.format(d.amount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.cashGreen))),
                    DataCell(
                      TextButton.icon(
                        onPressed: () => _showReceiptSlipModal(context, d),
                        icon: const Icon(Icons.image_outlined, size: 13),
                        label: Text(state.tr('viewDepositReceipt'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
    );
  }

  void _showClosingDetailModal(BuildContext context, DailyFinancialClosing c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text(
              'Shift Closing: ${c.closingDate.year}-${c.closingDate.month}-${c.closingDate.day}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: SizedBox(
          width: math.min(480.0, MediaQuery.sizeOf(ctx).width - 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cashier Confirmed: ${c.cashierName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Closed At: ${c.closedAt.toString().substring(0, 16)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const Divider(height: 18),
                _buildModalStatRow('Daily Gross Revenue:', CurrencyFormatter.format(c.grossRevenue), isBold: true, color: AppColors.primary),
                _buildModalStatRow('  • Cash Revenue:', CurrencyFormatter.format(c.cashRevenue)),
                _buildModalStatRow('  • Digital Channels:', CurrencyFormatter.format(c.digitalRevenue)),
                _buildModalStatRow('Washer Commission (15%):', '- ${CurrencyFormatter.format(c.commissionPool)}', color: AppColors.oromiaGold),
                if (!widget.isCashierMode)
                  _buildModalStatRow('Net Station Profit:', CurrencyFormatter.format(c.netStationProfit), isBold: true, color: AppColors.statusCompleted),
                _buildModalStatRow('Deposited to Bank:', CurrencyFormatter.format(c.cashDeposited), color: Colors.indigo),
                _buildModalStatRow('Remaining Drawer Cash:', CurrencyFormatter.format(c.cashRemaining)),
                const Divider(height: 18),
                const Text('Washer Dividend Payouts:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                const SizedBox(height: 6),
                ...c.washerDividends.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('• ${e.key}', style: const TextStyle(fontSize: 12)),
                      Text(CurrencyFormatter.format(e.value), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.oromiaGold)),
                    ],
                  ),
                )),
                if (c.notes != null) ...[
                  const Divider(height: 18),
                  Text('Notes: ${c.notes}', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildModalStatRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isBold ? FontWeight.w800 : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color ?? AppColors.textPrimary)),
        ],
      ),
    );
  }

  void _showReceiptSlipModal(BuildContext context, BankDepositRecord d) {
    final fallbackInfo = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.verified_rounded, size: 48, color: AppColors.cashGreen),
        const SizedBox(height: 8),
        Text(
          'Official Deposit Slip: ${d.referenceSlipNumber}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          'Amount: ${CurrencyFormatter.format(d.amount)}',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.cashGreen),
        ),
        const SizedBox(height: 2),
        Text(
          'Deposited to: ${d.accountName}',
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Colors.indigo, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Bank Slip: ${d.referenceSlipNumber}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        content: SizedBox(
          width: math.min(440.0, MediaQuery.sizeOf(ctx).width - 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: ReceiptImageHelper.buildImage(d.receiptScreenshot, fallback: fallbackInfo),
                ),
              ),
              const SizedBox(height: 12),
              Text('Deposited By: ${d.cashierName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Date: ${d.depositedAt.toString().substring(0, 16)}', style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              if (d.notes != null) ...[
                const SizedBox(height: 4),
                Text('Notes: ${d.notes}', style: const TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
