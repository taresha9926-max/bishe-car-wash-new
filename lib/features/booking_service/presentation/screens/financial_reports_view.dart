import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../admin/domain/models/bank_deposit_record.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../domain/models/payment_info.dart';
import '../../domain/models/wash_booking.dart';
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

  String get displayName => 'Today';
}

class FinancialReportsView extends StatefulWidget {
  final bool isEmbedded;

  const FinancialReportsView({super.key, this.isEmbedded = false});

  @override
  State<FinancialReportsView> createState() => _FinancialReportsViewState();
}

class _FinancialReportsViewState extends State<FinancialReportsView> {
  FinancialReportFilter _periodFilter = FinancialReportFilter.today;
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDesktop = ResponsiveLayout.isDesktop(context);

    final now = DateTime.now();
    DateTime rangeStart;
    DateTime rangeEnd = now;

    switch (_periodFilter) {
      case FinancialReportFilter.today:
        rangeStart = DateTime(now.year, now.month, now.day);
        break;
      case FinancialReportFilter.yesterday:
        final y = now.subtract(const Duration(days: 1));
        rangeStart = DateTime(y.year, y.month, y.day);
        rangeEnd = DateTime(y.year, y.month, y.day, 23, 59, 59);
        break;
      case FinancialReportFilter.thisWeek:
        final monday = now.subtract(Duration(days: now.weekday - 1));
        rangeStart = DateTime(monday.year, monday.month, monday.day);
        break;
      case FinancialReportFilter.thisMonth:
        rangeStart = DateTime(now.year, now.month, 1);
        break;
      case FinancialReportFilter.customRange:
        if (_customRange != null) {
          rangeStart = _customRange!.start;
          rangeEnd = DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day, 23, 59, 59);
        } else {
          rangeStart = DateTime(now.year, now.month, now.day);
        }
        break;
    }

    // Filter paid bookings in the period
    final periodBookings = state.bookings.where((b) {
      if (!b.payment.isPaid) return false;
      return (b.createdAt.isAfter(rangeStart) || b.createdAt.isAtSameMomentAs(rangeStart)) &&
          (b.createdAt.isBefore(rangeEnd) || b.createdAt.isAtSameMomentAs(rangeEnd));
    }).toList();

    // Financial Metrics for the period
    final grossRevenue = periodBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final cashRevenue = periodBookings
        .where((b) => b.payment.method == PaymentMethod.cash)
        .fold<double>(0.0, (sum, b) => sum + b.totalPrice);
    final digitalRevenue = grossRevenue - cashRevenue;
    final commissionDeducted = grossRevenue * state.teamCommissionRate;
    final netStationProfit = grossRevenue - commissionDeducted;

    // Filter bank deposits in period
    final periodDeposits = state.bankDeposits.where((d) {
      return (d.depositedAt.isAfter(rangeStart) || d.depositedAt.isAtSameMomentAs(rangeStart)) &&
          (d.depositedAt.isBefore(rangeEnd) || d.depositedAt.isAtSameMomentAs(rangeEnd));
    }).toList();
    final totalCashDeposited = periodDeposits.fold<double>(0.0, (sum, d) => sum + d.amount);

    // Filter daily closings in period
    final periodClosings = state.dailyFinancialClosings.where((c) {
      return (c.closingDate.isAfter(rangeStart) || c.closingDate.isAtSameMomentAs(rangeStart)) &&
          (c.closingDate.isBefore(rangeEnd) || c.closingDate.isAtSameMomentAs(rangeEnd));
    }).toList();

    final bodyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Time Filter Chips
        _buildFilterBar(context, state),
        const SizedBox(height: 14),

        // 2. Financial KPI Grid
        _buildKPIGrid(
          state: state,
          grossRevenue: grossRevenue,
          cashRevenue: cashRevenue,
          digitalRevenue: digitalRevenue,
          commissionDeducted: commissionDeducted,
          netStationProfit: netStationProfit,
          totalCashDeposited: totalCashDeposited,
          completedCars: periodBookings.length,
          isMobile: isMobile,
          isDesktop: isDesktop,
        ),
        const SizedBox(height: 18),

        // 3. Daily Closing Summaries Table
        _buildDailyClosingsSection(context, state, periodClosings, isMobile),
        const SizedBox(height: 18),

        // 5. Cash Bank Deposits Log (Owner Accounts A & B)
        _buildBankDepositsSection(context, periodDeposits, isMobile, state),
        const SizedBox(height: 18),

        // 6. Washer Payroll Policy (Weekly Commission + Monthly Salary)
        _buildWasherPayrollSection(state, isMobile),
        const SizedBox(height: 30),
      ],
    );

    if (widget.isEmbedded) {
      return bodyContent;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(state.tr('financialReports'), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 28 : (isMobile ? 14 : 20),
              vertical: 16,
            ),
            child: bodyContent,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, dynamic state) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: FinancialReportFilter.values.map((filter) {
          final isSelected = filter == _periodFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                filter == FinancialReportFilter.customRange && _customRange != null
                    ? '${_customRange!.start.month}/${_customRange!.start.day} - ${_customRange!.end.month}/${_customRange!.end.day}'
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
                  if (picked != null) {
                    setState(() {
                      _periodFilter = filter;
                      _customRange = picked;
                    });
                  }
                } else {
                  setState(() {
                    _periodFilter = filter;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKPIGrid({
    required dynamic state,
    required double grossRevenue,
    required double cashRevenue,
    required double digitalRevenue,
    required double commissionDeducted,
    required double netStationProfit,
    required double totalCashDeposited,
    required int completedCars,
    required bool isMobile,
    required bool isDesktop,
  }) {
    final items = [
      (
        title: state.tr('totalRevenue'),
        value: CurrencyFormatter.format(grossRevenue),
        sub: '$completedCars ${state.tr('carsWashed')}',
        icon: Icons.account_balance_wallet_rounded,
        color: AppColors.primary,
      ),
      (
        title: state.tr('washerCommissionDeducted'),
        value: CurrencyFormatter.format(commissionDeducted),
        sub: state.tr('disburseCommission'),
        icon: Icons.stars_rounded,
        color: AppColors.oromiaGold,
      ),
      (
        title: state.tr('netStationProfit'),
        value: CurrencyFormatter.format(netStationProfit),
        sub: state.tr('netStationProfit'),
        icon: Icons.verified_rounded,
        color: AppColors.statusCompleted,
      ),
      (
        title: state.tr('cashCollected'),
        value: CurrencyFormatter.format(cashRevenue),
        sub: state.tr('cashCollected'),
        icon: Icons.payments_rounded,
        color: AppColors.cashGreen,
      ),
      (
        title: state.tr('digitalPay'),
        value: CurrencyFormatter.format(digitalRevenue),
        sub: 'Telebirr, CBE, BoA, Awash...',
        icon: Icons.phone_android_rounded,
        color: AppColors.telebirrBlue,
      ),
      (
        title: state.tr('bankDepositsLog'),
        value: CurrencyFormatter.format(totalCashDeposited),
        sub: state.tr('bankDepositsLog'),
        icon: Icons.account_balance_rounded,
        color: Colors.indigo,
      ),
    ];

    final crossAxisCount = isDesktop ? 3 : (isMobile ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: isMobile ? 1.45 : 1.7,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ),
                  Icon(item.icon, color: item.color, size: 18),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: isMobile ? 14.5 : 16, fontWeight: FontWeight.w900, color: item.color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDailyClosingsSection(
    BuildContext context,
    dynamic state,
    List<DailyFinancialClosing> closings,
    bool isMobile,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.fact_check_rounded, color: AppColors.statusCompleted, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    state.tr('closingAndFinancialReports'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${closings.length} Shift Reports',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (closings.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'No closed shifts recorded in this time range.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Column(
              children: closings.map((c) => _buildClosingItemCard(context, c, isMobile)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildClosingItemCard(BuildContext context, DailyFinancialClosing c, bool isMobile) {
    final dateStr = '${c.closingDate.year}-${c.closingDate.month.toString().padLeft(2, '0')}-${c.closingDate.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      dateStr,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'by ${c.cashierName}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showClosingDetailModal(context, c),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View Details', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildClosingSubStat('Gross Revenue', CurrencyFormatter.format(c.grossRevenue), AppColors.primary),
              ),
              Expanded(
                child: _buildClosingSubStat('Commission', '- ${CurrencyFormatter.format(c.commissionPool)}', AppColors.oromiaGold),
              ),
              Expanded(
                child: _buildClosingSubStat('Net Profit', CurrencyFormatter.format(c.netStationProfit), AppColors.statusCompleted),
              ),
              if (!isMobile)
                Expanded(
                  child: _buildClosingSubStat('Bank Deposit', CurrencyFormatter.format(c.cashDeposited), Colors.indigo),
                ),
            ],
          ),
          if (c.notes != null && c.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Remarks: ${c.notes}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildClosingSubStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        const SizedBox(height: 1),
        Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color)),
      ],
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
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cashier Confirmed: ${c.cashierName}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                Text('Closed At: ${c.closedAt.toString().substring(0, 16)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const Divider(height: 18),
                _buildModalStatRow('Daily Gross Revenue:', CurrencyFormatter.format(c.grossRevenue), isBold: true, color: AppColors.primary),
                _buildModalStatRow('  • Cash Handover:', CurrencyFormatter.format(c.cashRevenue)),
                _buildModalStatRow('  • Digital Channels:', CurrencyFormatter.format(c.digitalRevenue)),
                _buildModalStatRow('Washer Commission (15%):', '- ${CurrencyFormatter.format(c.commissionPool)}', color: AppColors.oromiaGold),
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

  Widget _buildBankDepositsSection(BuildContext context, List<BankDepositRecord> deposits, bool isMobile, dynamic state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_rounded, color: Colors.indigo, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    state.tr('bankDepositsLog'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Text(
                '${deposits.length} Deposits',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.indigo),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (deposits.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'No bank deposits recorded in this date range.',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            Column(
              children: deposits.map((d) => _buildDepositItemCard(context, d, isMobile, state)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDepositItemCard(BuildContext context, BankDepositRecord d, bool isMobile, dynamic state) {
    final isAccountB = d.accountKey == 'account_b';
    final accountColor = isAccountB ? const Color(0xFFEA580C) : AppColors.cbeBirrPurple;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accountColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.account_balance_rounded, color: accountColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accountColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isAccountB ? 'ACCOUNT B (AWASH)' : 'ACCOUNT A (CBE)',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: accountColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Slip: ${d.referenceSlipNumber}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${d.bankName} • Acc: ${d.accountNumber}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Deposited by ${d.cashierName} on ${d.depositedAt.toString().substring(0, 16)}',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(d.amount),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.cashGreen),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _showReceiptSlipModal(context, d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.indigo),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.image_outlined, size: 12, color: Colors.indigo),
                      const SizedBox(width: 4),
                      Text(state.tr('viewDepositReceipt'), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Colors.indigo)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReceiptSlipModal(BuildContext context, BankDepositRecord d) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.receipt_long_rounded, color: Colors.indigo, size: 22),
            const SizedBox(width: 8),
            Text('Bank Slip: ${d.referenceSlipNumber}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          ],
        ),
        content: SizedBox(
          width: 440,
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
                child: d.receiptScreenshot != null && d.receiptScreenshot!.startsWith('data:image')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(d.receiptScreenshot!, fit: BoxFit.cover),
                      )
                    : Column(
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

  Widget _buildWasherPayrollSection(dynamic state, bool isMobile) {
    final weeklyCommissions = state.weeklyWasherCommissions as Map<String, double>;
    final weeklyPool = state.weeklyTotalCommissionPool as double;
    final monthlySalary = state.monthlyTotalBaseSalary as double;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.schedule_rounded, color: AppColors.oromiaGold, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Washer Payroll Policy (Weekly Commission • Monthly Salary)',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Washers receive team wash commission WEEKLY, while their contracted base salary is paid MONTHLY.',
            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.oromiaGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.oromiaGold.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Week Commission Accrual', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(weeklyPool), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.oromiaGold)),
                      const SizedBox(height: 2),
                      const Text('Paid Every Sunday Evening', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Total Monthly Base Salary Pool', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text(CurrencyFormatter.format(monthlySalary), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      const SizedBox(height: 2),
                      const Text('Paid Monthly on 30th', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Washer Weekly Commission Breakdown:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: weeklyCommissions.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Text(
                  '${e.key}: ${CurrencyFormatter.format(e.value)}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
