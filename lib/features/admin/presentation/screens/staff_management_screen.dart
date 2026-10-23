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
                  Text(
                    state.tr('staffPayroll'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.tr('staffPayrollSub'),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

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
                    Text(state.tr('baseMonthlySalary'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
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
                    Text(state.tr('commissionRate'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${(member.commissionRate * 100).toStringAsFixed(0)}% per car',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.statusCompleted),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('WASHES TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '${member.completedWashesCount} cars',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary),
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
              label: '${state.tr("commissionRate")} (%)',
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

  void _showAddStaffDialog(BuildContext context) {
    final state = AppStateProvider.read(context);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController(text: '+251 9');
    final salaryCtrl = TextEditingController(text: '4200');
    final commissionCtrl = TextEditingController(text: '15');
    StaffRole selectedRole = StaffRole.washer;

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
                  label: '${state.tr("commissionRate")} (%)',
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
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New staff member added: $name'),
                      backgroundColor: AppColors.statusCompleted,
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
