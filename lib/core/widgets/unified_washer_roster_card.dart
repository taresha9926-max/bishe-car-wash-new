import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/utils/currency_formatter.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_member.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';
import 'package:bishe_car_wash/features/cashier/presentation/screens/weekly_commission_report_dialog.dart';

/// Unified washer roster and commission pool section shared between
/// Cashier and Accountant dashboards.
class UnifiedWasherRosterCard extends StatelessWidget {
  final bool isMobile;

  const UnifiedWasherRosterCard({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final washers = state.availableWashers;
    final pool = state.teamCommissionPoolTodayETB;
    final dividends = state.washerDividendsToday;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.oromiaGold.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: AppColors.oromiaGold.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header with Title & Action Buttons
          _buildHeader(context, state, pool),
          const SizedBox(height: 12),

          // 2. Pool ETB Summary & Attendance Metric Chips
          _buildPoolMetricsBanner(state, pool),
          const SizedBox(height: 10),

          // 3. Distribution Safeguard Notice
          _buildSafeguardNotice(),
          const SizedBox(height: 12),

          // 4. Roster List with Live Dividend Calculation & Attendance Switches
          const Text(
            'Washer Crew Attendance & Live Dividend Share:',
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          ...washers.map((w) {
            final isPresent = state.isWasherPresentToday(w.id);
            final div = dividends[w.id];

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isPresent
                      ? AppColors.statusCompleted.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isPresent
                        ? AppColors.statusCompleted.withValues(alpha: 0.12)
                        : Colors.red.withValues(alpha: 0.12),
                    child: Text(
                      w.name.isNotEmpty ? w.name[0] : 'W',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: isPresent ? AppColors.statusCompleted : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                w.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                div?.customTierName ?? 'Tier ${w.skillSeniorityLevel}',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isPresent
                                    ? AppColors.statusCompleted.withValues(alpha: 0.12)
                                    : Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isPresent ? 'ON DUTY' : 'ABSENT',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: isPresent ? AppColors.statusCompleted : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            Text(
                              'Base: ${(w.commissionRate * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                            const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                            Text(
                              isPresent && div != null
                                  ? '${div.percentageShare.toStringAsFixed(1)}% Share • ${CurrencyFormatter.format(div.earnedETB)}'
                                  : 'Absent (0 ETB)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isPresent ? AppColors.oromiaGold : Colors.red,
                              ),
                            ),
                            if (w.phone.isNotEmpty) ...[
                              const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                              Text(
                                w.phone,
                                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isPresent,
                    activeThumbColor: AppColors.statusCompleted,
                    onChanged: (val) {
                      state.setWasherAttendance(w.id, val);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic state, double pool) {
    final titleWidget = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.oromiaGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.tr('dailyWasherCommissionPool'),
                style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              Text(
                '${state.presentWashersCount} of ${state.totalWashersCount} Washers on Duty • 15% Gross Pool • Shift: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );

    final actions = [
      OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.statusCompleted,
          side: const BorderSide(color: AppColors.statusCompleted),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: const Icon(Icons.done_all_rounded, size: 15),
        label: const Text('Mark All Present', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
        onPressed: () {
          state.markAllWashersPresent();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('All washers marked present for today.'),
              backgroundColor: AppColors.statusCompleted,
            ),
          );
        },
      ),
      const SizedBox(width: 6),
      OutlinedButton.icon(
        onPressed: () => WeeklyCommissionReportDialog.show(context),
        icon: const Icon(Icons.assignment_turned_in_rounded, size: 14),
        label: Text(
          state.tr('reportWeeklyCommission'),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        ),
      ),
      const SizedBox(width: 6),
      ElevatedButton.icon(
        onPressed: (pool > 0 && !state.isDailyCommissionDisbursedToday)
            ? () => _showDisburseCommissionDialog(context, state, pool, state.presentWashersCount)
            : null,
        icon: Icon(
          state.isDailyCommissionDisbursedToday ? Icons.check_circle_rounded : Icons.payments_rounded,
          size: 14,
        ),
        label: Text(
          state.isDailyCommissionDisbursedToday
              ? (isMobile ? 'Disbursed' : 'Disbursed Today (${CurrencyFormatter.format(pool)})')
              : state.tr('disburseCommission'),
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: state.isDailyCommissionDisbursedToday ? Colors.grey.shade400 : AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          elevation: 0,
        ),
      ),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(children: actions),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: titleWidget),
        const SizedBox(width: 12),
        Row(mainAxisSize: MainAxisSize.min, children: actions),
      ],
    );
  }

  Widget _buildPoolMetricsBanner(dynamic state, double pool) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.oromiaGold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.oromiaGold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Earned Commission Pool Today:',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                CurrencyFormatter.format(pool),
                style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.oromiaGold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Real Amount of Commission Earned:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              Text(
                CurrencyFormatter.format(pool),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.statusCompleted.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.statusCompleted.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.statusCompleted, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${state.presentWashersCount} Present',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.statusCompleted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${state.totalWashersCount - state.presentWashersCount} Absent',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Colors.redAccent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.groups_rounded, color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        '${state.totalWashersCount} Total',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: AppColors.textPrimary),
                      ),
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

  Widget _buildSafeguardNotice() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, size: 14, color: Colors.blue),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              '100% of the commission pool is distributed strictly among washers on duty today. Absent washers receive 0 ETB, and their share is automatically redistributed proportionally to active washers.',
              style: TextStyle(fontSize: 10.5, color: Colors.blueGrey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showDisburseCommissionDialog(BuildContext context, dynamic state, double pool, int washerCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.stars_rounded, color: AppColors.oromiaGold, size: 24),
            SizedBox(width: 8),
            Text('Disburse Commission Pool', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Confirm distribution of ${CurrencyFormatter.format(pool)} team commission dividends among the $washerCount washer(s) on duty today according to their percentage share (summing to 100%)?',
          style: const TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              state.markDailyCommissionDisbursed();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Team commission pool recorded and distributed successfully!'),
                  backgroundColor: AppColors.statusReady,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Confirm Disbursement', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}
