import 'package:bishe_car_wash/features/auth_roles/domain/models/user_role.dart';

class StaffCredential {
  final String id;
  final String username;
  final String pin;
  final UserRole role; // cashier or admin
  final String fullName;
  final bool isActive;

  const StaffCredential({
    required this.id,
    required this.username,
    required this.pin,
    required this.role,
    required this.fullName,
    this.isActive = true,
  });

  StaffCredential copyWith({
    String? id,
    String? username,
    String? pin,
    UserRole? role,
    String? fullName,
    bool? isActive,
  }) {
    return StaffCredential(
      id: id ?? this.id,
      username: username ?? this.username,
      pin: pin ?? this.pin,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      isActive: isActive ?? this.isActive,
    );
  }
}
