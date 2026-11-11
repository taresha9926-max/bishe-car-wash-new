import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/auto_care_assets.dart';
import '../utils/currency_formatter.dart';

/// Shared period-filtered Profit & Loss (P&L) financial statement card used across
/// Admin Overview & Cash and Consolidated Financial Reports.
class FinancialPnlStatementCard extends StatelessWidget {
  final dynamic state;
  final bool isMobile;
  final String? periodSubtitle;
  final double totalRevenue;
  final double commissionPool;
  final double totalPettyCash;
  final double totalSupplies;

  const FinancialPnlStatementCard({
    super.key,
    required this.state,
    required this.isMobile,
    this.periodSubtitle,
    required this.totalRevenue,
    required this.commissionPool,
    required this.totalPettyCash,
    required this.totalSupplies,
  });

  @override
  Widget build(BuildContext context) {
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
                      periodSubtitle ?? state.tr('pnlStatementSub'),
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
          _buildRow(state.tr('grossRevenueRow'), CurrencyFormatter.format(totalRevenue), Colors.green.shade800, isHeader: true),
          const SizedBox(height: 6),
          _buildRow(state.tr('cogsRow'), '- ${CurrencyFormatter.format(cogs)}', Colors.orange.shade900, isHeader: true),
          _buildSubRow('• ${state.tr("washerCommissionSub")}', '- ${CurrencyFormatter.format(commissionPool)}'),
          _buildSubRow('• ${state.tr("consumablesSub")}', '- ${CurrencyFormatter.format(totalSupplies)}'),
          const Divider(height: 12),
          _buildRow(state.tr('grossOperatingProfitRow'), CurrencyFormatter.format(grossProfit), grossProfit >= 0 ? Colors.green.shade700 : Colors.red, isBold: true),
          const SizedBox(height: 8),
          _buildRow(state.tr('opexRow'), '- ${CurrencyFormatter.format(totalPettyCash)}', Colors.deepOrange.shade900, isHeader: true),
          _buildSubRow('• ${state.tr("pettyCashOpexSub")}', '- ${CurrencyFormatter.format(totalPettyCash)}'),
          const Divider(thickness: 1.5, height: 16),
          _buildRow(state.tr('netOperatingProfitRow'), CurrencyFormatter.format(netOperatingProfit), netOperatingProfit >= 0 ? Colors.teal.shade800 : Colors.red, isBold: true, isLarge: true),
          const Divider(height: 16),
          _buildRow(state.tr('salaryReserveRow'), CurrencyFormatter.format(monthlySalaryObligation), Colors.blueGrey, isHeader: true),
          const SizedBox(height: 4),
          _buildRow(state.tr('netRetainedProfitRow'), CurrencyFormatter.format(netRetainedProfit), netRetainedProfit >= 0 ? Colors.indigo.shade800 : Colors.red, isBold: true),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color, {bool isHeader = false, bool isBold = false, bool isLarge = false}) {
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

  Widget _buildSubRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary))),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
