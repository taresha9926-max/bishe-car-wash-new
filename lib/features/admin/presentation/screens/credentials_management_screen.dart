import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class CredentialsManagementScreen extends StatefulWidget {
  const CredentialsManagementScreen({super.key});

  @override
  State<CredentialsManagementScreen> createState() => _CredentialsManagementScreenState();
}

class _CredentialsManagementScreenState extends State<CredentialsManagementScreen> {
  void _showEditCashierPhoneDialog(BuildContext context) {
    final state = AppStateProvider.read(context);
    final phoneController = TextEditingController(text: state.cashierSmsPhone);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.sms_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Cashier SMS Phone Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This phone number is used to dispatch automated completion SMS messages to customers when their wash is finished.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Cashier Phone Number',
                prefixIcon: const Icon(Icons.phone_android_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final newPhone = phoneController.text.trim();
              if (newPhone.isNotEmpty) {
                state.setCashierSmsPhone(newPhone);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cashier SMS Gateway Phone updated to $newPhone'),
                    backgroundColor: AppColors.statusReady,
                  ),
                );
              }
            },
            child: const Text('Save Phone'),
          ),
        ],
      ),
    );
  }

  void _showEditPinDialog(BuildContext context, StaffCredential cred) {
    final state = AppStateProvider.read(context);
    final pinController = TextEditingController(text: cred.pin);
    final nameController = TextEditingController(text: cred.fullName);
    bool obscure = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('${state.tr("editPin")} (${cred.role.localizedName(state.currentLang)})'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: state.tr('staffDisplayName'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: pinController,
                obscureText: obscure,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: state.tr('securityPin'),
                  counterText: '',
                  prefixIcon: const Icon(Icons.pin, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                    onPressed: () => setDialogState(() => obscure = !obscure),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(state.tr('cancel')),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPin = pinController.text.trim();
                final newName = nameController.text.trim();
                if (newPin.isEmpty) return;

                final state = AppStateProvider.of(context);
                await state.updateStaffCredential(
                  id: cred.id,
                  pin: newPin,
                  fullName: newName.isEmpty ? cred.fullName : newName,
                );
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isSuperAdmin
                            ? '${state.tr("savePin")}: ${cred.username}'
                            : 'PIN change request for ${cred.username} submitted for Super Admin approval.',
                      ),
                      backgroundColor: state.isSuperAdmin ? AppColors.statusCompleted : AppColors.secondary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(state.tr('savePin')),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCredentialDialog(BuildContext context, StaffCredential cred) {
    final state = AppStateProvider.read(context);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete PIN for ${cred.fullName}?'),
        content: Text(
          state.isSuperAdmin
              ? 'Are you sure you want to delete this credential (@${cred.username})? This user will no longer be able to log in.'
              : 'As a secondary admin, this deletion request will be submitted to the Super Admin for confirmation.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: Text(state.tr('cancel'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await state.deleteStaffCredential(cred.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.isSuperAdmin
                          ? 'Credential for @${cred.username} deleted.'
                          : 'Deletion of @${cred.username} submitted for Super Admin approval.',
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

  void _showAddCredentialDialog(BuildContext context) {
    final state = AppStateProvider.read(context);
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final pinCtrl = TextEditingController();
    UserRole selectedRole = UserRole.cashier;
    bool obscure = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Assign New Staff PIN'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                DropdownButtonFormField<UserRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: UserRole.cashier, child: Text('Cashier')),
                    DropdownMenuItem(value: UserRole.storekeeper, child: Text('Storekeeper')),
                    DropdownMenuItem(value: UserRole.accountant, child: Text('Accountant')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('Secondary Admin')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedRole = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'e.g. Dawit Kebede',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: usernameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Username (System Identifier)',
                    hintText: 'e.g. dawit_cashier',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: pinCtrl,
                  obscureText: obscure,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: InputDecoration(
                    labelText: 'Security PIN (4-6 Digits)',
                    counterText: '',
                    prefixIcon: const Icon(Icons.pin, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setDialogState(() => obscure = !obscure),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(state.tr('cancel'))),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final username = usernameCtrl.text.trim();
                final pin = pinCtrl.text.trim();
                if (name.isEmpty || username.isEmpty || pin.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid name, username, and at least 4-digit PIN.')),
                  );
                  return;
                }

                Navigator.pop(ctx);
                await state.addStaffCredential(
                  role: selectedRole,
                  username: username,
                  fullName: name,
                  pin: pin,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.isSuperAdmin
                            ? 'Assigned PIN for @$username successfully.'
                            : 'New PIN for @$username submitted for Super Admin approval.',
                      ),
                      backgroundColor: state.isSuperAdmin ? AppColors.statusCompleted : AppColors.secondary,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              child: const Text('Assign PIN'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final credentials = state.credentials;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          state.tr('staffPinsTitle'),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: credentials.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.security_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.tr('staffPinsDesc'),
                          style: TextStyle(fontSize: 12.5, color: Colors.blueGrey.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Cashier SMS Dispatch Gateway Phone Configuration
                Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.sms_rounded, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.tr('smsGatewayPhone'),
                                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                state.cashierSmsPhone,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Personal phone package used to dispatch customer completion SMS',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
                          tooltip: 'Edit SMS Phone',
                          onPressed: () => _showEditCashierPhoneDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),
                ...credentials.map((cred) {
                  final isAdmin = cred.role == UserRole.admin;
                  final color = isAdmin ? AppColors.primary : AppColors.secondary;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(cred.role.icon, color: color, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      cred.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        cred.role.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Username: @${cred.username} • PIN: ${cred.pin.replaceAll(RegExp(r'.'), '•')} (${cred.pin})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () => _showEditPinDialog(context, cred),
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text(state.tr('changePin')),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: color,
                                  side: BorderSide(color: color.withOpacity(0.4)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                tooltip: 'Delete PIN',
                                onPressed: () => _showDeleteCredentialDialog(context, cred),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Assign PIN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddCredentialDialog(context),
      ),
    );
  }
}
