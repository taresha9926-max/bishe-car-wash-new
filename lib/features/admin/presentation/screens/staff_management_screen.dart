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
        title: const Text('Staff & Salaries Management'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Staff', style: TextStyle(fontWeight: FontWeight.w700)),
        onPressed: () => _showAddStaffDialog(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Salary Overview Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payroll & Washer Incentive Rules',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Washers receive a fixed base monthly salary plus an automatic commission percentage for every car wash they successfully complete.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Staff Roster & Payroll',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  '${staffList.length} Team Members',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...staffList.map((member) => _buildStaffCard(context, member)),

            const SizedBox(height: 70), // Spacing for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffMember member) {
    final commissionPercent = (member.commissionRate * 100).toStringAsFixed(0);

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
                      '${member.role.displayName} • ${member.phone}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 20),
                tooltip: 'Edit Salary & Commission',
                onPressed: () => _showEditSalaryDialog(context, member),
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
                    const Text('BASE MONTHLY SALARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      CurrencyFormatter.format(member.baseSalaryMonthlyETB),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('COMMISSION RATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '$commissionPercent% per car',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.oromiaGold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Total Earnings & Completed Washes Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completed Washes: ${member.completedWashesCount}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                Text(
                  'Commissions Earned: ${CurrencyFormatter.formatShort(member.totalCommissionEarnedETB)}',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.statusReady),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSalaryDialog(BuildContext context, StaffMember member) {
    final salaryController = TextEditingController(text: member.baseSalaryMonthlyETB.toStringAsFixed(0));
    final rateController = TextEditingController(text: (member.commissionRate * 100).toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Salary: ${member.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: salaryController,
              label: 'Base Monthly Salary (ETB)',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.payments_outlined,
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: rateController,
              label: 'Commission Rate Percentage (%)',
              hint: 'e.g. 15 for 15%',
              keyboardType: TextInputType.number,
              prefixIcon: Icons.percent,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newSalary = double.tryParse(salaryController.text.trim());
              final newRatePct = double.tryParse(rateController.text.trim());

              if (newSalary != null && newRatePct != null) {
                final state = AppStateProvider.read(context);
                await state.updateStaffSalary(
                  staffId: member.id,
                  baseSalary: newSalary,
                  commissionRate: newRatePct / 100.0,
                );
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.statusCompleted,
                      content: Text('Updated salary for ${member.name}'),
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showAddStaffDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+251 9');
    final salaryCtrl = TextEditingController(text: '5000');
    final rateCtrl = TextEditingController(text: '15');
    StaffRole selectedRole = StaffRole.washer;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Team Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextField(controller: nameCtrl, label: 'Full Name', hint: 'e.g. Chala Desta'),
                const SizedBox(height: 10),
                CustomTextField(controller: phoneCtrl, label: 'Phone', keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                const Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                DropdownButton<StaffRole>(
                  isExpanded: true,
                  value: selectedRole,
                  items: StaffRole.values.map((r) {
                    return DropdownMenuItem<StaffRole>(
                      value: r,
                      child: Text(r.displayName),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(controller: salaryCtrl, label: 'Base Salary (ETB)', keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                CustomTextField(controller: rateCtrl, label: 'Commission Rate (%)', keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final sal = double.tryParse(salaryCtrl.text.trim()) ?? 5000.0;
                final rate = (double.tryParse(rateCtrl.text.trim()) ?? 15.0) / 100.0;

                final state = AppStateProvider.read(context);
                await state.addNewStaff(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  role: selectedRole,
                  baseSalary: sal,
                  commissionRate: rate,
                );

                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.statusCompleted,
                      content: Text('New staff member added!'),
                    ),
                  );
                }
              },
              child: const Text('Add Staff'),
            ),
          ],
        ),
      ),
    );
  }
}
