import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class WeeklyCommissionReportDialog extends StatefulWidget {
  const WeeklyCommissionReportDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const WeeklyCommissionReportDialog(),
    );
  }

  @override
  State<WeeklyCommissionReportDialog> createState() => _WeeklyCommissionReportDialogState();
}

class _WeeklyCommissionReportDialogState extends State<WeeklyCommissionReportDialog> {
  final _cashierController = TextEditingController(text: 'Abebech Tadesse');
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _cashierController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final weeklyPool = state.weeklyTotalCommissionPool;
    final washerCommissions = state.weeklyWasherCommissions;
    final isMobile = MediaQuery.sizeOf(context).width < 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540),
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
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.oromiaGold.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.tr('weeklyCommissionReportTitle'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            state.tr('disburseWeeklyCommission'),
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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

              // Pool Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.oromiaGold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.oromiaGold.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      state.tr('weeklyCommissionAccrual'),
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    Text(
                      CurrencyFormatter.format(weeklyPool),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.oromiaGold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Breakdown of each washer's weekly commission
              Text(
                state.tr('staffPayroll'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: washerCommissions.isEmpty
                    ? Center(
                        child: Text(state.tr('noRecords'), style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                      )
                    : Column(
                        children: washerCommissions.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.statusCompleted),
                                    const SizedBox(width: 6),
                                    Text(
                                      e.key,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                                Text(
                                  CurrencyFormatter.format(e.value),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.oromiaGold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
              ),
              const SizedBox(height: 14),

              // Cashier Name & Notes
              CustomTextField(
                controller: _cashierController,
                label: state.tr('closingCashierName'),
                hint: 'Cashier submitting weekly report',
                prefixIcon: Icons.badge_rounded,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: _notesController,
                label: state.tr('closingRemarks'),
                hint: 'e.g. Verified and approved weekly washer payout.',
                prefixIcon: Icons.edit_note_rounded,
              ),
              const SizedBox(height: 18),

              // Submit Button
              CustomButton(
                text: state.tr('reportWeeklyCommissionToAdmin'),
                icon: Icons.send_rounded,
                backgroundColor: AppColors.primary,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleSubmitReport,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmitReport() async {
    final cashierName = _cashierController.text.trim().isNotEmpty
        ? _cashierController.text.trim()
        : 'Cashier On Duty';

    setState(() => _isSubmitting = true);

    try {
      final state = AppStateProvider.read(context);
      final report = await state.submitWeeklyCommissionReportToAdmin(
        cashierName: cashierName,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${state.tr("weeklyReportSuccess")} (${CurrencyFormatter.format(report.totalWeeklyPool)})',
            ),
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
            content: Text('Error submitting weekly report: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
