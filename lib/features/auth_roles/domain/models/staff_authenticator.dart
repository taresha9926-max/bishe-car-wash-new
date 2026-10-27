import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';

/// Deep authentication module encapsulating staff credential verification,
/// fallback defaults, and role access policies.
class StaffAuthenticator {
  static const String defaultAdminPin = '1234';
  static const String defaultCashierPin = '0000';

  /// Verifies entered PIN against hardcoded deployment defaults or active credentials.
  static bool authenticate({
    required UserRole role,
    required String enteredPin,
    required List<StaffCredential> credentials,
  }) {
    if (role == UserRole.customer) return true;
    final pin = enteredPin.trim();
    if (pin.isEmpty) return false;

    // shortcut: hardcoded admin (1234) and cashier (0000) PINs for deployment phase, upgrade to dynamic salted hashing post-launch
    if (role == UserRole.admin && pin == defaultAdminPin) return true;
    if (role == UserRole.cashier && pin == defaultCashierPin) return true;

    final match = credentials.where((c) => c.role == role && c.isActive);
    return match.any((c) => c.pin.trim() == pin);
  }
}
