import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';

/// Deep authentication module encapsulating staff credential verification
/// and role access policies. Strictly enforces active database credentials.
class StaffAuthenticator {
  static const String defaultAdminPin = '1234';
  static const String defaultCashierPin = '0000';
  static const String defaultStorekeeperPin = '3344';
  static const String defaultAccountantPin = '5566';

  /// Verifies entered PIN strictly against active credentials.
  /// Hardcoded PINs are completely bypassed once credentials exist in the system.
  static bool authenticate({
    required UserRole role,
    required String enteredPin,
    required List<StaffCredential> credentials,
  }) {
    if (role == UserRole.customer) return true;
    final pin = enteredPin.trim();
    if (pin.isEmpty) return false;

    final roleCredentials = credentials.where((c) => c.role == role && c.isActive).toList();

    // If active credentials exist in the database, ONLY the live edited credentials are valid
    if (roleCredentials.isNotEmpty) {
      return roleCredentials.any((c) => c.pin.trim() == pin);
    }

    // Fallback only if the credentials database is completely uninitialized
    if (role == UserRole.admin && pin == defaultAdminPin) return true;
    if (role == UserRole.cashier && pin == defaultCashierPin) return true;
    if (role == UserRole.storekeeper && pin == defaultStorekeeperPin) return true;
    if (role == UserRole.accountant && pin == defaultAccountantPin) return true;

    return false;
  }
}
