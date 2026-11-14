import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../admin/domain/models/daily_financial_closing.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/screens/financial_reports_view.dart';
import '../../../booking_service/presentation/screens/vehicle_history_screen.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';
import '../screens/bank_deposit_dialog.dart';
import '../screens/daily_closing_dialog.dart';
import '../screens/petty_cash_dialog.dart';

/// Shared Station Money & Shift Closing workbench used by both Cashier
/// (day shift closing, no custody carry) and Operational Manager
/// (night shift closing, day custody carry, minus Cashier-only Public Shower).
class StationMoneyTab extends StatefulWidget {
  final bool isManager;
  final bool isMobile;
  final VoidCallback onSwitchToTeamTab;

  const StationMoneyTab({
    super.key,
    required this.isManager,
    required this.isMobile,
    required this.onSwitchToTeamTab,
  });

  @override
  State<StationMoneyTab> createState() => _StationMoneyTabState();
}

class _StationMoneyTabState extends State<StationMoneyTab> {
  bool _isDigitalBreakdownExpanded = false;
  bool _showShiftReports = false;

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final undepositedCash = state.undepositedCashTodayETB;
    final cashierDrawerCash = state.cashierDrawerBalanceETB as double;
    final managerCustodyCash = state.managerCustodyCashETB as double;
    final activeDrawerCash = widget.isManager
        ? (managerCustodyCash > 0 ? managerCustodyCash : undepositedCash)
        : cashierDrawerCash;
    final pendingCashierOtp = state.pendingCashierHandover ?? state.pendingCashierAdminHandover;
    final pendingNightOtp = state.pendingAdminNightHandover;
    final latestDayClosing = state.latestDayClosing;
    final isDayClosed = state.isTodayDayShiftClosed;
    final isNightClosed = state.isTodayNightShiftClosed;
    final isClosed = widget.isManager ? isNightClosed : isDayClosed;
    final activePendingOtp = widget.isManager ? pendingNightOtp : pendingCashierOtp;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Ambiguity-free Physical Cash in Drawer Focus Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(widget.isMobile ? 14 : 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      state.tr('physicalCashInDrawer'),
                      style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.tr('filterToday'),
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.format(activeDrawerCash),
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
              ),
              if (!widget.isManager && isDayClosed) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    state.tr('drawerEmptyHandedOver'),
                    style: const TextStyle(color: Color(0xFFFCD34D), fontSize: 11, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 2. Station Today KPI Strip
        _buildShiftSummaryBanner(state, widget.isMobile),
        const SizedBox(height: 12),

        // 3. Closing & Financial Actions (Bank Deposit, Petty Cash, Prerequisite-Gated Shift Closing) + Digital Breakdown
        _buildFinancialActionDesk(
          context,
          state,
          widget.isMobile,
          activePendingOtp,
          latestDayClosing,
          isClosed,
        ),
        const SizedBox(height: 16),

        // 5. Safe Today/Filtered Paid Receipts History (No bulk-delete danger for Cashier/Manager)
        Text(
          state.isCarpetDivisionActive ? state.tr('carpetWashHistoryTitle') : state.tr('carWashHistoryTitle'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        VehicleHistoryScreen(
          isEmbedded: true,
          isCarpetFilter: state.isCarpetDivisionActive,
          allowClearAll: false,
        ),
        const SizedBox(height: 14),

        // 6. Shift Closing Logs & Bank Deposits (Admin net profit / salary hidden for floor staff)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  onTap: () => setState(() => _showShiftReports = !_showShiftReports),
                  leading: const Icon(Icons.summarize_rounded, color: AppColors.primary),
                  title: Text(
                    state.tr('dailyFinancialReportsTab'),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  trailing: Icon(
                    _showShiftReports ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ),
              if (_showShiftReports)
                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: FinancialReportsView(isEmbedded: true, isCashierMode: true),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShiftSummaryBanner(dynamic state, bool isMobile) {
    final commissionTitle = state.tr('commissionShort');
    final commissionSub = '${(state.teamCommissionRate * 100).toInt()}% (${state.presentWashersCount} ${state.tr("dutyWorkers")})';
    final revenueSub = state.isCarpetDivisionActive
        ? '${state.carpetWashBookings.where((b) => b.payment.isPaid).length} ${state.tr("myCarpetCleanings")}'
        : '${state.totalCompletedCarsToday} ${state.tr("carsWashed")}';

    final cols = [
      _buildKPIColumn(state.tr('todayRevenue'), CurrencyFormatter.formatShort(state.totalRevenueTodayETB), revenueSub, AppColors.primary, isMobile),
      _buildKPIColumn(state.tr('digitalPay'), CurrencyFormatter.formatShort(state.totalDigitalRevenueETB), state.tr('digitalPayments'), AppColors.telebirrBlue, isMobile),
      _buildKPIColumn(state.tr('cashCollected'), CurrencyFormatter.formatShort(state.totalCashRevenueETB), state.tr('atFrontDesk'), AppColors.cashGreen, isMobile),
      _buildKPIColumn(commissionTitle, CurrencyFormatter.formatShort(state.teamCommissionPoolTodayETB as double), commissionSub, AppColors.oromiaGold, isMobile),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: isMobile
          ? Column(
              children: [
                Row(children: [Expanded(child: cols[0]), const SizedBox(width: 8), Expanded(child: cols[1])]),
                const Divider(height: 16, color: AppColors.cardBorder),
                Row(children: [Expanded(child: cols[2]), const SizedBox(width: 8), Expanded(child: cols[3])]),
              ],
            )
          : Row(
              children: [
                Expanded(child: cols[0]),
                Container(width: 1, height: 36, color: AppColors.cardBorder),
                Expanded(child: cols[1]),
                Container(width: 1, height: 36, color: AppColors.cardBorder),
                Expanded(child: cols[2]),
                Container(width: 1, height: 36, color: AppColors.cardBorder),
                Expanded(child: cols[3]),
              ],
            ),
    );
  }

  Widget _buildKPIColumn(String title, String value, String sub, Color color, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 11 : 11.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: TextStyle(fontSize: isMobile ? 15.5 : 17, fontWeight: FontWeight.w900, color: color),
          ),
        ),
        const SizedBox(height: 1),
        Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: isMobile ? 10 : 10.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Future<void> _onClosingPressed(BuildContext context, dynamic state, bool isClosed) async {
    if (!isClosed && (state.requiresDailyCommissionDisbursementBeforeClosing as bool)) {
      final pool = state.undisbursedCommissionPoolTodayETB as double;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.lock_clock_rounded, color: Color(0xFFD97706), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.tr('commissionDisburseRequiredTitle'),
                  style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.tr('commissionDisburseRequiredDesc'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        state.tr('remainingCommissionPool'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(pool),
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(state.tr('cancel')),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                widget.onSwitchToTeamTab();
              },
              icon: const Icon(Icons.groups_rounded, size: 16),
              label: Text(state.tr('goToTeamAndDisburse'), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await state.disburseAndReportDailyCommissionToAdmin(
                  cashierName: state.activeStaffFullName ?? (widget.isManager ? 'Dawit Manager' : 'Cashier'),
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.tr('dailyCommissionDisbursedReported')),
                      backgroundColor: AppColors.statusCompleted,
                    ),
                  );
                  DailyClosingDialog.show(context, isManagerClosing: widget.isManager);
                }
              },
              icon: const Icon(Icons.payments_rounded, size: 16),
              label: Text(state.tr('disburseNowAndUnlockClosing'), style: const TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      );
      return;
    }

    DailyClosingDialog.show(context, isManagerClosing: widget.isManager);
  }

  Widget _buildFinancialActionDesk(
    BuildContext context,
    dynamic state,
    bool isMobile,
    dynamic pendingHandover,
    DailyFinancialClosing? latestDayClosing,
    bool isClosed,
  ) {
    final methodRevenue = state.getRevenueByPaymentMethod() as Map<PaymentMethod, double>;
    final methodCounts = state.getTransactionCountByPaymentMethod() as Map<PaymentMethod, int>;
    final undepositedCash = state.undepositedCashTodayETB as double;
    final cashRevenue = methodRevenue[PaymentMethod.cash] ?? 0.0;
    final cashCount = methodCounts[PaymentMethod.cash] ?? 0;

    final digitalProviders = [
      (method: PaymentMethod.telebirr, label: state.tr('payTelebirr'), color: AppColors.telebirrBlue),
      (method: PaymentMethod.cbeBirr, label: state.tr('payCbeBirr'), color: AppColors.cbeBirrPurple),
      (method: PaymentMethod.bankOfAbyssinia, label: state.tr('payBankOfAbyssinia'), color: const Color(0xFFF59E0B)),
      (method: PaymentMethod.awashBank, label: state.tr('payAwashBank'), color: const Color(0xFFEA580C)),
      (method: PaymentMethod.dashenBank, label: state.tr('payDashenBank'), color: const Color(0xFF0284C7)),
      (method: PaymentMethod.otherBankTransfer, label: state.tr('payBank'), color: Colors.indigo),
    ];

    double digitalRevenue = 0.0;
    int digitalCount = 0;
    for (final p in digitalProviders) {
      digitalRevenue += methodRevenue[p.method] ?? 0.0;
      digitalCount += methodCounts[p.method] ?? 0;
    }

    final needsDisburse = !isClosed && (state.requiresDailyCommissionDisbursementBeforeClosing as bool);

    final closingTitle = pendingHandover != null
        ? 'OTP: [ ${pendingHandover.handoverOtp} ]'
        : (isClosed
            ? (widget.isManager ? state.tr('nightClosingConfirmed') : state.tr('dailyClosingConfirmed'))
            : (widget.isManager ? state.tr('initiateNightShiftClosing') : state.tr('confirmDailyClosing')));

    final closingSubtitle = pendingHandover != null
        ? state.tr('viewVoucher')
        : (isClosed
            ? state.tr('shiftLockedLabel')
            : (needsDisburse
                ? state.tr('commissionDisburseRequiredTitle')
                : state.tr('reconcileAndCloseShift')));

    final cashierCanDeposit = !isClosed && pendingHandover == null && (state.cashierDrawerBalanceETB as double) > 0.01;
    final managerCanDeposit = (state.managerCustodyCashETB as double) > 0.01 || (state.undepositedCashTodayETB as double) > 0.01;
    final canDeposit = widget.isManager ? managerCanDeposit : cashierCanDeposit;

    final depositSubtitle = widget.isManager
        ? CurrencyFormatter.formatShort((state.managerCustodyCashETB as double) > 0
            ? (state.managerCustodyCashETB as double)
            : (state.undepositedCashTodayETB as double))
        : ((isClosed || pendingHandover != null)
            ? state.tr('drawerEmptyHandedOver')
            : CurrencyFormatter.formatShort(state.cashierDrawerBalanceETB as double));

    final actions = [
      _buildDeskActionButton(
        onPressed: canDeposit ? () => BankDepositDialog.show(context) : null,
        color: Colors.indigo,
        icon: Icons.account_balance_rounded,
        title: state.tr('depositCashToBank'),
        subtitle: depositSubtitle,
      ),
      _buildDeskActionButton(
        onPressed: () => PettyCashDialog.show(context),
        color: Colors.deepOrange,
        icon: Icons.outbox_rounded,
        title: state.tr('logPettyCash'),
        subtitle: CurrencyFormatter.formatShort(state.todayPettyCashExpensesETB as double),
      ),
      _buildDeskActionButton(
        onPressed: () => _onClosingPressed(context, state, isClosed),
        color: pendingHandover != null
            ? const Color(0xFFD97706)
            : (isClosed
                ? AppColors.statusCompleted
                : (needsDisburse ? const Color(0xFFB45309) : AppColors.primary)),
        icon: (isClosed || pendingHandover != null)
            ? Icons.verified_rounded
            : (needsDisburse ? Icons.lock_clock_rounded : Icons.pin_rounded),
        title: closingTitle,
        subtitle: closingSubtitle,
      ),
    ];

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            SizedBox(width: double.infinity, child: actions[0]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: actions[1]),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: actions[2]),
          ] else
            Row(
              children: [
                Expanded(child: actions[0]),
                const SizedBox(width: 8),
                Expanded(child: actions[1]),
                const SizedBox(width: 8),
                Expanded(child: actions[2]),
              ],
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPaymentSummaryTile(
                  label: state.tr('cashCollected'),
                  value: '${CurrencyFormatter.formatShort(cashRevenue)} ($cashCount)',
                  color: AppColors.cashGreen,
                  icon: Icons.payments_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isDigitalBreakdownExpanded = !_isDigitalBreakdownExpanded),
                  borderRadius: BorderRadius.circular(10),
                  child: _buildPaymentSummaryTile(
                    label: state.tr('digitalMoneyTransfer'),
                    value: '${CurrencyFormatter.formatShort(digitalRevenue)} ($digitalCount)',
                    color: AppColors.telebirrBlue,
                    icon: Icons.phonelink_ring_rounded,
                    trailingIcon: _isDigitalBreakdownExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                  ),
                ),
              ),
            ],
          ),
          if (_isDigitalBreakdownExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: digitalProviders.map((c) {
                  final amt = methodRevenue[c.method] ?? 0.0;
                  final cnt = methodCounts[c.method] ?? 0;
                  final hasPayments = amt > 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: hasPayments ? c.color.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: hasPayments ? c.color.withValues(alpha: 0.35) : AppColors.cardBorder),
                    ),
                    child: Text(
                      '${c.label}: ${CurrencyFormatter.formatShort(amt)} ($cnt)',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: hasPayments ? c.color : AppColors.textMuted,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeskActionButton({
    required VoidCallback? onPressed,
    required Color color,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isEnabled = onPressed != null;
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: isEnabled ? Colors.white70 : Colors.white60)),
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? color : Colors.grey.shade400,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        disabledForegroundColor: Colors.white70,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
    );
  }

  Widget _buildPaymentSummaryTile({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    IconData? trailingIcon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ],
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, size: 18, color: color),
        ],
      ),
    );
  }
}
