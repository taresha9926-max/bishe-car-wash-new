import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/auto_care_assets.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/domain/models/payment_info.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class DailyClosingDialog extends StatefulWidget {
  final bool isManagerClosing;
  const DailyClosingDialog({super.key, this.isManagerClosing = false});

  static Future<void> show(BuildContext context, {bool isManagerClosing = false}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => DailyClosingDialog(isManagerClosing: isManagerClosing),
    );
  }

  @override
  State<DailyClosingDialog> createState() => _DailyClosingDialogState();
}

class _DailyClosingDialogState extends State<DailyClosingDialog> {
  final _cashierNameController = TextEditingController(text: 'Staff On Duty');
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final active = AppStateProvider.read(context).activeStaffFullName;
    if (active != null && active.isNotEmpty) {
      _cashierNameController.text = active;
    } else {
      _cashierNameController.text = widget.isManagerClosing ? 'Dawit Manager' : 'Cashier On Duty';
    }
  }

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
    final petty = state.todayPettyCashExpensesETB;
    final remainingCash = state.undepositedCashTodayETB;
    final dividends = state.washerDividendsToday;
    final isAlreadyClosed = widget.isManagerClosing ? state.isTodayNightShiftClosed : state.isTodayDayShiftClosed;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 14 : 22),
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
                      AutoCareAssets.buildPhotoThumbnail(
                        imageUrl: widget.isManagerClosing ? AutoCareAssets.packageTireRimUrl : AutoCareAssets.welcomeHeroUrl,
                        width: 44,
                        height: 44,
                        borderRadius: 12,
                        fallbackIcon: Icons.fact_check_rounded,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isManagerClosing ? state.tr('nightClosingTitle') : state.tr('dailyClosing'),
                            style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            isAlreadyClosed
                                ? 'Shift Already Closed & Confirmed'
                                : (widget.isManagerClosing
                                    ? 'Night shift closing & total payout to Admin'
                                    : 'Day shift closing & handover to Operational Manager'),
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
                    _buildClosingRow(
                      widget.isManagerClosing ? 'Night Shift Gross Revenue:' : 'Daily Gross Revenue:',
                      CurrencyFormatter.format(gross),
                      isBold: true,
                      valueColor: AppColors.primary,
                    ),
                    const Divider(height: 16),
                    _buildClosingRow('  • Cash Collected at Station:', CurrencyFormatter.format(cash), valueColor: AppColors.cashGreen),
                    const SizedBox(height: 4),
                    _buildClosingRow('  • Digital Channels Total (Telebirr/CBE):', CurrencyFormatter.format(digital), valueColor: AppColors.telebirrBlue),
                    const Divider(height: 16),
                    _buildClosingRow(
                      widget.isManagerClosing ? 'Night Washer Commission (15% Pool):' : 'Day Washer Commission (15% Pool):',
                      '- ${CurrencyFormatter.format(comm)}',
                      isBold: true,
                      valueColor: AppColors.oromiaGold,
                    ),
                    const SizedBox(height: 4),
                    _buildClosingRow('Remaining Station Net Profit:', CurrencyFormatter.format(net), isBold: true, valueColor: AppColors.statusCompleted),
                    const Divider(height: 16),
                    if (widget.isManagerClosing) ...[
                      _buildClosingRow('Carried Cash from Cashier Handover:', CurrencyFormatter.format(state.managerCarriedCashETB), isBold: true, valueColor: Colors.indigo),
                      const SizedBox(height: 4),
                      _buildClosingRow('Night Shift Cash in Drawer:', CurrencyFormatter.format(remainingCash), valueColor: AppColors.cashGreen),
                      const Divider(height: 16),
                      _buildClosingRow('Total Physical Cash Handed to Admin:', CurrencyFormatter.format(state.managerCarriedCashETB + remainingCash), isBold: true, valueColor: AppColors.primary),
                    ] else ...[
                      _buildClosingRow('Petty Cash / Emergency Outflow:', CurrencyFormatter.format(petty), valueColor: Colors.deepOrange),
                      const SizedBox(height: 4),
                      _buildClosingRow('Cash Balance to Handover to Manager:', CurrencyFormatter.format(remainingCash), isBold: true, valueColor: remainingCash > 0 ? AppColors.primary : AppColors.textSecondary),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Digital Channels Breakdown
              Text(
                state.tr('moneyReceivedBreakdown'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              _buildDigitalChannelsGrid(state),
              const SizedBox(height: 16),

              // Washer Commission Distribution
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.tr('teamCommissionDistribution')}:',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
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

              // Staff Name & Notes
              CustomTextField(
                controller: _cashierNameController,
                label: widget.isManagerClosing ? 'Closing Manager Name' : 'Closing Cashier Name',
                hint: widget.isManagerClosing ? 'Manager confirming closing' : 'Cashier confirming closing',
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
              if (isAlreadyClosed)
                CustomButton(
                  text: 'Daily Closing Confirmed (Shift Locked)',
                  icon: Icons.lock_outline_rounded,
                  backgroundColor: Colors.grey.shade600,
                  isLoading: false,
                  onPressed: null,
                )
              else
                CustomButton(
                  text: state.tr('confirmDailyClosing'),
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
      (label: PaymentMethod.telebirr.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.telebirr] ?? 0.0, cnt: methodCounts[PaymentMethod.telebirr] ?? 0, color: AppColors.telebirrBlue),
      (label: PaymentMethod.cbeBirr.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.cbeBirr] ?? 0.0, cnt: methodCounts[PaymentMethod.cbeBirr] ?? 0, color: AppColors.cbeBirrPurple),
      (label: PaymentMethod.bankOfAbyssinia.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.bankOfAbyssinia] ?? 0.0, cnt: methodCounts[PaymentMethod.bankOfAbyssinia] ?? 0, color: const Color(0xFFF59E0B)),
      (label: PaymentMethod.awashBank.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.awashBank] ?? 0.0, cnt: methodCounts[PaymentMethod.awashBank] ?? 0, color: const Color(0xFFEA580C)),
      (label: PaymentMethod.dashenBank.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.dashenBank] ?? 0.0, cnt: methodCounts[PaymentMethod.dashenBank] ?? 0, color: const Color(0xFF0284C7)),
      (label: PaymentMethod.otherBankTransfer.localizedName(state.currentLanguage), amt: methodRevenue[PaymentMethod.otherBankTransfer] ?? 0.0, cnt: methodCounts[PaymentMethod.otherBankTransfer] ?? 0, color: Colors.indigo),
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
    final staffName = _cashierNameController.text.trim().isNotEmpty
        ? _cashierNameController.text.trim()
        : (widget.isManagerClosing ? 'Dawit Manager' : 'Cashier On Duty');

    setState(() => _isSubmitting = true);

    try {
      final state = AppStateProvider.read(context);
      final closing = await state.confirmDailyClosing(
        cashierName: staffName,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        shiftType: widget.isManagerClosing ? 'night' : 'day',
        closedByRole: widget.isManagerClosing ? 'manager' : 'cashier',
        handoverTo: widget.isManagerClosing ? 'Admin / Owner' : 'Operational Manager',
      );

      if (mounted) {
        Navigator.pop(context);
        final message = widget.isManagerClosing
            ? 'Night closing confirmed for ${CurrencyFormatter.format(closing.grossRevenue)}! Total cash handed to Admin.'
            : 'Day shift closing confirmed! Cash handover submitted to Operational Manager.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
            content: Text('Error confirming closing: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
