import 'package:bishe_car_wash/core/localization/app_strings.dart';

enum StaffRole {
  washer,
  cashier,
  admin,
  leadDetailer;

  String localizedName(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case StaffRole.washer:
        return AppStrings.get('roleWasher', lang);
      case StaffRole.cashier:
        return AppStrings.get('roleCashier', lang);
      case StaffRole.admin:
        return AppStrings.get('roleAdmin', lang);
      case StaffRole.leadDetailer:
        return AppStrings.get('roleLeadDetailer', lang);
    }
  }

  String get displayName => localizedName('EN');
}

class StaffMember {
  final String id;
  final String name;
  final String phone;
  final StaffRole role;
  final double baseSalaryMonthlyETB; // Staff base salary managed by admin
  final double commissionRate;        // e.g. 0.15 for 15%
  final bool isAvailable;
  final int completedWashesCount;
  final double totalCommissionEarnedETB;

  const StaffMember({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.baseSalaryMonthlyETB,
    this.commissionRate = 0.15,
    this.isAvailable = true,
    this.completedWashesCount = 0,
    this.totalCommissionEarnedETB = 0.0,
  });

  StaffMember copyWith({
    String? id,
    String? name,
    String? phone,
    StaffRole? role,
    double? baseSalaryMonthlyETB,
    double? commissionRate,
    bool? isAvailable,
    int? completedWashesCount,
    double? totalCommissionEarnedETB,
  }) {
    return StaffMember(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      baseSalaryMonthlyETB: baseSalaryMonthlyETB ?? this.baseSalaryMonthlyETB,
      commissionRate: commissionRate ?? this.commissionRate,
      isAvailable: isAvailable ?? this.isAvailable,
      completedWashesCount: completedWashesCount ?? this.completedWashesCount,
      totalCommissionEarnedETB: totalCommissionEarnedETB ?? this.totalCommissionEarnedETB,
    );
  }
}
