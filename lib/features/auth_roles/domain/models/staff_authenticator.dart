import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';

/// Deep authentication module encapsulating staff credential verification
/// and role access policies. Strictly enforces Super Admin authority and database credentials.
class StaffAuthenticator {
  static const String defaultAdminPin = '4450';
  static const String defaultCashierPin = '2233';
  static const String defaultManagerPin = '7788';
  static const String defaultAccountantPin = '3344';
  static const String defaultStorekeeperPin = '3344';

  /// Verifies entered PIN against active database credentials, or default PINs if unconfigured.
  static bool authenticate({
    required UserRole role,
    required String enteredPin,
    required List<StaffCredential> credentials,
  }) {
    if (role == UserRole.customer) return true;
    final pin = enteredPin.trim();
    if (pin.isEmpty) return false;

    final roleCredentials = credentials.where((c) => c.role == role && c.isActive).toList();

    // If active credentials exist in the system for this role, ONLY those exact credentials are valid
    if (roleCredentials.isNotEmpty) {
      return roleCredentials.any((c) => _secureCompare(c.pin.trim(), pin));
    }

    // Default PIN fallback only if no active credentials exist in the system for that role
    switch (role) {
      case UserRole.admin:
        return _secureCompare(pin, defaultAdminPin);
      case UserRole.cashier:
        return _secureCompare(pin, defaultCashierPin);
      case UserRole.manager:
        return _secureCompare(pin, defaultManagerPin);
      case UserRole.accountant:
        return _secureCompare(pin, defaultAccountantPin);
      case UserRole.storekeeper:
        return _secureCompare(pin, defaultStorekeeperPin);
      case UserRole.customer:
        return true;
    }
  }

  /// Constant-time comparison to prevent timing analysis attacks on PIN verification.
  static bool _secureCompare(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
