import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';
import 'package:bishe_car_wash/features/booking_service/presentation/state/app_state_provider.dart';

class RoleAuthDialog extends StatefulWidget {
  final UserRole targetRole;

  const RoleAuthDialog({super.key, required this.targetRole});

  static Future<bool> show(BuildContext context, UserRole targetRole) async {
    if (targetRole == UserRole.customer) return true;
    final res = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => RoleAuthDialog(targetRole: targetRole),
    );
    return res ?? false;
  }

  @override
  State<RoleAuthDialog> createState() => _RoleAuthDialogState();
}

class _RoleAuthDialogState extends State<RoleAuthDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscurePin = true;
  String? _error;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _verifyPin() {
    final state = AppStateProvider.of(context);
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _error = state.tr('enterPinPrompt'));
      return;
    }

    final isValid = state.authenticateRole(widget.targetRole, pin);
    if (isValid) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = state.tr('incorrectPin');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateProvider.of(context);
    final isCashier = widget.targetRole == UserRole.cashier;
    final title = '${widget.targetRole.localizedName(state.currentLang)} - ${state.tr("staffPins")}';
    final defaultHint = isCashier ? 'Default PIN: 0000' : 'Default PIN: 1234';

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCashier ? AppColors.secondary.withOpacity(0.12) : AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.targetRole.icon,
              color: isCashier ? AppColors.secondary : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the 4-digit PIN configured by Administrator to access the ${widget.targetRole.localizedName(state.currentLang)} view.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              autofocus: true,
              maxLength: 6,
              style: const TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 18),
              decoration: InputDecoration(
                labelText: state.tr('securityPin'),
                counterText: '',
                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility, size: 20),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                errorText: _error,
              ),
              onSubmitted: (_) => _verifyPin(),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                defaultHint,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(state.tr('cancel')),
        ),
        ElevatedButton(
          onPressed: _verifyPin,
          style: ElevatedButton.styleFrom(
            backgroundColor: isCashier ? AppColors.secondary : AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(state.tr('unlock')),
        ),
      ],
    );
  }
}
