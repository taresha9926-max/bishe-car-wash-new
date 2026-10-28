import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../admin/domain/models/staff_member.dart';
import '../../../booking_service/presentation/state/app_state_provider.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final staffList = state.staff;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.tr('staffManagementTitle')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: Text(state.tr('addStaff'), style: const TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showAddStaffDialog(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Team Commission Pooling Banner
            _buildTeamCommissionCard(context, state),
            const SizedBox(height: 14),

            // Washers Commission 100% Allocation Status Banner
            Builder(builder: (context) {
              final washers = staffList.where((s) => s.role == StaffRole.washer).toList();
              final totalWasherCommission = washers.fold<double>(0.0, (sum, w) => sum + (w.commissionRate * 100));
              final is100Percent = (totalWasherCommission - 100.0).abs() < 0.05;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: is100Percent ? Colors.green.withOpacity(0.08) : Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: is100Percent ? Colors.green.withOpacity(0.4) : Colors.amber.shade700,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      is100Percent ? Icons.check_circle_rounded : Icons.info_rounded,
                      color: is100Percent ? Colors.green : Colors.amber.shade800,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Commission Allocation: ${totalWasherCommission.toStringAsFixed(1)}% / 100.0%',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: is100Percent ? Colors.green.shade900 : Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            is100Percent
                                ? 'Full 100% of the team commission pool is distributed across ${washers.length} active washers.'
                                : 'Assigned commission shares should sum to 100.0%. Edit individual washer percentages below.',
                            style: TextStyle(fontSize: 11, color: is100Percent ? Colors.green.shade800 : Colors.brown),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 14),

            Text(
              state.tr('activeWashers'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),

            ...staffList.map((member) => _buildStaffCard(context, state, member)),

            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, dynamic state, StaffMember member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // Top row: Avatar, Name, Role, Edit Button
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Text(
                  member.name.substring(0, 1),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      '${member.role.localizedName(state.currentLang)} • ${member.phone}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                    tooltip: 'Edit Salary & Commission',
                    onPressed: () => _showEditSalaryDialog(context, member),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                    tooltip: 'Delete Staff Member',
                    onPressed: () => _showDeleteStaffDialog(context, member),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Compensation Breakdown
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(state.tr('baseMonthlySalary'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(member.baseSalaryMonthlyETB),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Commission Share', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${(member.commissionRate * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.secondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Dividend", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(state.washerDividendsToday[member.id]?.earnedETB ?? 0.0),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCommissionCard(BuildContext context, dynamic state) {
    final poolETB = state.teamCommissionPoolTodayETB;
    final ratePercent = (state.teamCommissionRate * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.groups_rounded, color: AppColors.statusCompleted, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${state.tr("teamCommissionPool")} ($ratePercent%)',
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                ],
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.edit, size: 14, color: AppColors.primary),
                label: Text(state.tr('updateRate'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary)),
                onPressed: () => _showEditCommissionRateDialog(context, state),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            state.tr('dividendBySeniority'),
            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Today's Revenue", style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(state.totalRevenueTodayETB),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Pooled ($ratePercent%)', style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(poolETB),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.statusCompleted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Team Size', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(
                      '${state.availableWashers.length} Washers',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditCommissionRateDialog(BuildContext context, dynamic state) {
    final controller = TextEditingController(text: (state.teamCommissionRate * 100).toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(state.tr('teamRateLabel')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Commission Percentage (%)',
                hintText: 'e.g. 15',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            onPressed: () {
              final parsed = double.tryParse(controller.text.trim());
              if (parsed != null && parsed >= 0 && parsed <= 100) {
                state.setTeamCommissionRate(parsed / 100.0);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.statusCompleted,
                    content: Text('Team Commission Rate set to ${parsed.toStringAsFixed(0)}%'),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(state.tr('updateRate')),
          ),
        ],
      ),
    );
  }

  void _showEditSalaryDialog(BuildContext context, StaffMember member) {
    final state = AppStateProvider.read(context);
    final salaryCtrl = TextEditingController(text: member.baseSalaryMonthlyETB.toStringAsFixed(0));
    final commissionCtrl = TextEditingController(text: (member.commissionRate * 100).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('${state.tr("staffPayroll")}: ${member.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: salaryCtrl,
              label: state.tr('baseMonthlySalary'),
              hint: 'e.g. 4500',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: commissionCtrl,
              label: member.role == StaffRole.washer
                  ? 'Washer Commission Share (%)'
                  : '${state.tr("commissionRate")} (%)',
              hint: 'e.g. 15',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text(state.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              final newSalary = double.tryParse(salaryCtrl.text.trim()) ?? member.baseSalaryMonthlyETB;
              final newCommissionPercent = double.tryParse(commissionCtrl.text.trim()) ?? (member.commissionRate * 100);

              Navigator.pop(dialogCtx);
              await state.updateStaffSalary(
                staffId: member.id,
                baseSalary: newSalary,
                commissionRate: newCommissionPercent / 100.0,
              );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Updated salary for ${member.name}'),
                    backgroundColor: AppColors.statusCompleted,
                  ),
                );
              }
            },
            child: Text(state.tr('save')),
          ),
        ],
      ),
    );
  }

  void _showDeleteStaffDialog(BuildContext context, StaffMember member) {
    final state = AppStateProvider.read(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete ${member.name}?'),
        content: Text(
          state.isSuperAdmin
              ? 'Are you sure you want to remove this staff member (${member.role.name}) from the system?'
              : 'As a secondary admin, this deletion request will be submitted to the Super Admin for confirmation.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await state.deleteStaffMember(member.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.isSuperAdmin
                          ? 'Staff member ${member.name} deleted.'
                          : 'Deletion request for ${member.name} submitted for Super Admin approval.',
                    ),
                    backgroundColor: state.isSuperAdmin ? AppColors.statusCompleted : AppColors.secondary,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final state = AppStateProvider.read(context);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+251 9');
    final salaryCtrl = TextEditingController(text: '4200');
    final commissionCtrl = TextEditingController(text: '15');
    StaffRole selectedRole = StaffRole.washer;
    int selectedSeniority = 2;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(state.tr('addStaff')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(
                  controller: nameCtrl,
                  label: 'Full Name',
                  hint: 'e.g. Tolosa Desta',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 10),
                Text(state.tr('customerRole'), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButtonFormField<StaffRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: StaffRole.values.map((r) {
                    return DropdownMenuItem(value: r, child: Text(r.localizedName(state.currentLang)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: phoneCtrl,
                  label: state.tr('customerPhone'),
                  hint: '+251 91 234 5678',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_android,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: salaryCtrl,
                  label: state.tr('baseMonthlySalary'),
                  hint: 'e.g. 4200',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.payments_outlined,
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: commissionCtrl,
                  label: selectedRole == StaffRole.washer
                      ? 'Assigned Commission Share (%)'
                      : '${state.tr("commissionRate")} (%)',
                  hint: '15',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.percent,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                final salary = double.tryParse(salaryCtrl.text.trim()) ?? 4200;
                final comm = (double.tryParse(commissionCtrl.text.trim()) ?? 15) / 100.0;

                Navigator.pop(dialogCtx);
                await state.addStaffMember(
                  name: name,
                  phone: phoneCtrl.text.trim(),
                  role: selectedRole,
                  baseSalary: salary,
                  commissionRate: comm,
                  skillSeniorityLevel: selectedSeniority,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isSuperAdmin
                            ? 'New staff member added: $name'
                            : 'Staff addition request for $name submitted for Super Admin approval.',
                      ),
                      backgroundColor: state.isSuperAdmin ? AppColors.statusCompleted : AppColors.secondary,
                    ),
                  );
                }
              },
              child: Text(state.tr('addStaff')),
            ),
          ],
        ),
      ),
    );
  }
}
