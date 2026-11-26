import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/currency_formatter.dart';

/// Professional Cash Flow Statement (Direct Method) Card
/// Visualizes cash movements across Operating, Investing and Financing activities
class FinancialCashFlowCard extends StatelessWidget {
  final dynamic state;
  final bool isMobile;
  final double cashFromCarWash;
  final double cashFromCarpet;
  final double cashFromShower;
  final double digitalCollections;
  final double suppliesPaid;
  final double commissionsPaid;
  final double pettyCashPaid;
  final double rentPaid;
  final int rangeDays;

  const FinancialCashFlowCard({
    super.key,
    required this.state,
    required this.isMobile,
    required this.cashFromCarWash,
    required this.cashFromCarpet,
    required this.cashFromShower,
    required this.digitalCollections,
    required this.suppliesPaid,
    required this.commissionsPaid,
    required this.pettyCashPaid,
    required this.rentPaid,
    this.rangeDays = 1,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Operating Cash Inflows & Outflows
    final totalOperatingInflows = cashFromCarWash + cashFromCarpet + cashFromShower + digitalCollections;
    final totalOperatingOutflows = suppliesPaid + commissionsPaid + pettyCashPaid + rentPaid;
    final netOperatingCashFlow = totalOperatingInflows - totalOperatingOutflows;

    // 2. Investing Cash Outflows (Machinery maintenance & minor equipment replacement)
    final capexEquipment = (state.dailyMachineryDepreciation as double? ?? 180.0) * rangeDays * 0.4;
    final netInvestingCashFlow = -capexEquipment;

    // 3. Financing Cash Flow (Owner distributions / drawings after obligations)
    final ownerDistributions = netOperatingCashFlow > 0 ? netOperatingCashFlow * 0.25 : 0.0;
    final netFinancingCashFlow = -ownerDistributions;

    // 4. Net Change in Cash
    final netChangeInCash = netOperatingCashFlow + netInvestingCashFlow + netFinancingCashFlow;
    const openingCash = 15000.0; // Baseline working capital cash float
    final closingCash = openingCash + netChangeInCash;

    return Container(
      padding: EdgeInsets.all(isMobile ? 14 : 18),
      decoration: BoxDecoration(
        color: const Color(0xFF10131C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.statusReady.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.statusReady.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.sync_alt_rounded, color: AppColors.statusReady, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr('cashFlowTitle'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      state.tr('cashFlowSub'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (netChangeInCash >= 0 ? AppColors.statusReady : AppColors.statusCancelled).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  netChangeInCash >= 0 ? '+ CASH SURPLUS' : '- CASH DEFICIT',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: netChangeInCash >= 0 ? AppColors.statusReady : AppColors.statusCancelled,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 12),

          // 1. CFO: OPERATING CASH FLOW
          _buildSectionHeader(state.tr('cfoHeader'), netOperatingCashFlow, Colors.tealAccent.shade700),
          const SizedBox(height: 6),
          _buildSubRow('• ${state.tr("cashFromCarWash")}', '+ ${CurrencyFormatter.format(cashFromCarWash)}'),
          _buildSubRow('• ${state.tr("cashFromCarpet")}', '+ ${CurrencyFormatter.format(cashFromCarpet)}'),
          _buildSubRow('• ${state.tr("cashFromShower")}', '+ ${CurrencyFormatter.format(cashFromShower)}'),
          _buildSubRow('• ${state.tr("digitalCollections")}', '+ ${CurrencyFormatter.format(digitalCollections)}'),
          _buildSubRow('• ${state.tr("outflowSupplies")}', '- ${CurrencyFormatter.format(suppliesPaid)}', isNegative: true),
          _buildSubRow('• ${state.tr("outflowCommissions")}', '- ${CurrencyFormatter.format(commissionsPaid)}', isNegative: true),
          _buildSubRow('• ${state.tr("outflowPettyCash")}', '- ${CurrencyFormatter.format(pettyCashPaid)}', isNegative: true),
          _buildSubRow('• ${state.tr("outflowRent")}', '- ${CurrencyFormatter.format(rentPaid)}', isNegative: true),
          _buildCategoryTotal(state.tr('netCfo'), netOperatingCashFlow),
          const Divider(height: 14, color: AppColors.cardBorder),

          // 2. CFI: INVESTING CASH FLOW
          _buildSectionHeader(state.tr('cfiHeader'), netInvestingCashFlow, Colors.amber.shade600),
          const SizedBox(height: 6),
          _buildSubRow('• ${state.tr("capexEquipment")}', '- ${CurrencyFormatter.format(capexEquipment)}', isNegative: true),
          _buildCategoryTotal(state.tr('netCfi'), netInvestingCashFlow),
          const Divider(height: 14, color: AppColors.cardBorder),

          // 3. CFF: FINANCING CASH FLOW
          _buildSectionHeader(state.tr('cffHeader'), netFinancingCashFlow, Colors.purpleAccent.shade400),
          const SizedBox(height: 6),
          _buildSubRow('• ${state.tr("ownerDrawings")}', '- ${CurrencyFormatter.format(ownerDistributions)}', isNegative: true),
          _buildCategoryTotal(state.tr('netCff'), netFinancingCashFlow),
          const Divider(height: 14, color: AppColors.cardBorder),

          // 4. SUMMARY RECONCILIATION
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF06070B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                _buildSummaryLine(state.tr('openingCash'), CurrencyFormatter.format(openingCash), Colors.white70),
                const SizedBox(height: 4),
                _buildSummaryLine(
                  state.tr('netChangeInCash'),
                  '${netChangeInCash >= 0 ? "+" : ""}${CurrencyFormatter.format(netChangeInCash)}',
                  netChangeInCash >= 0 ? AppColors.statusReady : AppColors.statusCancelled,
                  isBold: true,
                ),
                const Divider(height: 12, color: AppColors.cardBorder),
                _buildSummaryLine(
                  state.tr('closingCash'),
                  CurrencyFormatter.format(closingCash),
                  Colors.white,
                  isLarge: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
            ),
          ),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTotal(String label, double amount) {
    final isPos = amount >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          Text(
            '${isPos ? "+" : ""}${CurrencyFormatter.format(amount)}',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: isPos ? AppColors.statusReady : AppColors.statusCancelled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubRow(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, left: 10, right: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isNegative ? Colors.orange.shade400 : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(String label, String value, Color color, {bool isBold = false, bool isLarge = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 13.5 : 12,
              fontWeight: isLarge || isBold ? FontWeight.w800 : FontWeight.w600,
              color: isLarge ? color : AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isLarge ? 16 : (isBold ? 13 : 12),
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }
}
