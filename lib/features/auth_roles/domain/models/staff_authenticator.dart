import 'package:bishe_car_wash/features/admin/domain/models/staff_credential.dart';
import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';

/// Deep authentication module encapsulating staff credential verification
/// and role access policies. Strictly enforces Super Admin authority and database credentials.
class StaffAuthenticator {
  static const String defaultAdminPin = '1234';

  /// Verifies entered PIN strictly against active credentials.
  /// Cashier, Manager, Storekeeper, and Accountant MUST be created by the Super Admin.
  /// Hardcoded fallback PINs (0000, 7788, etc.) are strictly disallowed.
  static bool authenticate({
    required UserRole role,
    required String enteredPin,
    required List<StaffCredential> credentials,
  }) {
    if (role == UserRole.customer) return true;
    final pin = enteredPin.trim();
    if (pin.isEmpty) return false;

    final roleCredentials = credentials.where((c) => c.role == role && c.isActive).toList();

    // If active credentials exist for this role, ONLY those exact credentials are valid
    if (roleCredentials.isNotEmpty) {
      return roleCredentials.any((c) => c.pin.trim() == pin);
    }

    // Initial Super Admin bootstrap fallback ONLY if the credentials list has no active admin record
    if (role == UserRole.admin) {
      final hasAdmin = credentials.any((c) => c.role == UserRole.admin && c.isActive);
      if (!hasAdmin && pin == defaultAdminPin) return true;
    }

    // Cashier, Manager, Storekeeper, Accountant MUST be created by Super Admin.
    // Zero hardcoded bypasses allowed.
    return false;
  }
}
