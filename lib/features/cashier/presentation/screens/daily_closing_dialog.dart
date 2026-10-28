import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class DailyClosingDialog extends StatefulWidget {
  const DailyClosingDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const DailyClosingDialog(),
    );
  }

  @override
  State<DailyClosingDialog> createState() => _DailyClosingDialogState();
}

class _DailyClosingDialogState extends State<DailyClosingDialog> {
  final _cashierNameController = TextEditingController(text: 'Abebech Tadesse');
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cashierNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final gross = state.totalRevenueTodayETB;
    final cash = state.totalCashRevenueETB;
    final digital = state.totalDigitalRevenueETB;
    final comm = state.teamCommissionPoolTodayETB;
    final net = gross - comm;
    final deposited = state.totalCashDepositedTodayETB;
    final remainingCash = state.undepositedCashTodayETB;
    final dividends = state.washerDividendsToday;
    final isAlreadyClosed = state.isTodayClosed;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.fact_check_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Financial Closing',
                            style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isAlreadyClosed ? 'Shift Already Closed & Confirmed' : 'End of day transaction reconciliation',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isAlreadyClosed ? AppColors.statusCompleted : AppColors.textSecondary,
                              fontWeight: isAlreadyClosed ? FontWeight.w700 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // KPI Summary Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildClosingRow('Daily Gross Revenue:', CurrencyFormatter.format(gross), isBold: true, valueColor: AppColors.primary),
                    const Divider(height: 16),
                    _buildClosingRow('  • Cash Handover at Gate:', CurrencyFormatter.format(cash), valueColor: AppColors.cashGreen),
                    const SizedBox(height: 4),
                    _buildClosingRow('  • Digital Channels Total:', CurrencyFormatter.format(digital), valueColor: AppColors.telebirrBlue),
                    const Divider(height: 16),
                    _buildClosingRow('Washer Commission (15% Pool):', '- ${CurrencyFormatter.format(comm)}', isBold: true, valueColor: AppColors.oromiaGold),
                    const SizedBox(height: 4),
                    _buildClosingRow('Remaining Station Net Profit:', CurrencyFormatter.format(net), isBold: true, valueColor: AppColors.statusCompleted),
                    const Divider(height: 16),
                    _buildClosingRow('Cash Deposited to Bank (A/B):', CurrencyFormatter.format(deposited), valueColor: Colors.indigo),
                    const SizedBox(height: 4),
                    _buildClosingRow('Cash Balance in Drawer:', CurrencyFormatter.format(remainingCash), isBold: true, valueColor: remainingCash > 0 ? AppColors.primary : AppColors.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Digital Channels Breakdown
              const Text(
                'Digital Channels Received Breakdown:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildDigitalChannelsGrid(state),
              const SizedBox(height: 16),

              // Washer Commission Distribution
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Washer Commission Disbursement (100%):',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${state.presentWashersCount} On Duty',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.oromiaGold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: dividends.isEmpty
                    ? const Center(
                        child: Text('No active washers on duty.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      )
                    : Column(
                        children: dividends.values.map((div) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      div.isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                      size: 14,
                                      color: div.isPresent ? AppColors.statusCompleted : Colors.red,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      div.washerName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: div.isPresent ? FontWeight.w700 : FontWeight.w500,
                                        color: div.isPresent ? AppColors.textPrimary : AppColors.textMuted,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceVariant,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        div.customTierName ?? '',
                                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  div.isPresent
                                      ? '${div.percentageShare.toStringAsFixed(1)}% • ${CurrencyFormatter.format(div.earnedETB)}'
                                      : 'Absent (0 ETB)',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: div.isPresent ? AppColors.oromiaGold : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // Cashier Name & Notes
              CustomTextField(
                controller: _cashierNameController,
                label: 'Closing Cashier Name',
                hint: 'Cashier confirming closing',
                prefixIcon: Icons.badge_rounded,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _notesController,
                label: 'Daily Closing Remarks / Notes',
                hint: 'e.g. All vehicles washed and accounted for, cash counted.',
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 20),

              // Action Buttons
              CustomButton(
                text: isAlreadyClosed ? 'Re-confirm / Update Daily Closing' : 'Confirm & Lock Daily Closing',
                icon: Icons.check_circle_outline_rounded,
                backgroundColor: AppColors.cashGreen,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleClosingConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClosingRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 13.5 : 12,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDigitalChannelsGrid(dynamic state) {
    final methodRevenue = state.getRevenueByPaymentMethod();
    final methodCounts = state.getTransactionCountByPaymentMethod();

    final channels = [
      (label: 'Telebirr', amt: methodRevenue[PaymentMethod.telebirr] ?? 0.0, cnt: methodCounts[PaymentMethod.telebirr] ?? 0, color: AppColors.telebirrBlue),
      (label: 'CBE Birr', amt: methodRevenue[PaymentMethod.cbeBirr] ?? 0.0, cnt: methodCounts[PaymentMethod.cbeBirr] ?? 0, color: AppColors.cbeBirrPurple),
      (label: 'Bank of Abyssinia', amt: methodRevenue[PaymentMethod.bankOfAbyssinia] ?? 0.0, cnt: methodCounts[PaymentMethod.bankOfAbyssinia] ?? 0, color: const Color(0xFFF59E0B)),
      (label: 'Awash Bank', amt: methodRevenue[PaymentMethod.awashBank] ?? 0.0, cnt: methodCounts[PaymentMethod.awashBank] ?? 0, color: const Color(0xFFEA580C)),
      (label: 'Dashen Bank', amt: methodRevenue[PaymentMethod.dashenBank] ?? 0.0, cnt: methodCounts[PaymentMethod.dashenBank] ?? 0, color: const Color(0xFF0284C7)),
      (label: 'Other Banks', amt: methodRevenue[PaymentMethod.otherBankTransfer] ?? 0.0, cnt: methodCounts[PaymentMethod.otherBankTransfer] ?? 0, color: Colors.indigo),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: channels.map((c) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: c.amt > 0 ? c.color.withOpacity(0.08) : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: c.amt > 0 ? c.color.withOpacity(0.3) : AppColors.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                c.label,
                style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: c.amt > 0 ? c.color : AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                '${CurrencyFormatter.formatShort(c.amt)} (${c.cnt})',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: c.amt > 0 ? AppColors.textPrimary : AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleClosingConfirm() async {
    final cashierName = _cashierNameController.text.trim().isNotEmpty
        ? _cashierNameController.text.trim()
        : 'Cashier On Duty';

    setState(() => _isSubmitting = true);

    try {
      final state = AppStateProvider.read(context);
      final closing = await state.confirmDailyClosing(
        cashierName: cashierName,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily closing report confirmed for ${CurrencyFormatter.format(closing.grossRevenue)} gross revenue! Admin dashboard notified.'),
            backgroundColor: AppColors.statusReady,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error confirming daily closing: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
