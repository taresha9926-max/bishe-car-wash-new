enum StaffRole {
  washer,
  cashier,
  admin,
  leadDetailer;

  String get displayName {
    switch (this) {
      case StaffRole.washer:
        return 'Car Washer';
      case StaffRole.cashier:
        return 'Cashier';
      case StaffRole.admin:
        return 'Admin / Manager';
      case StaffRole.leadDetailer:
        return 'Lead Detailer';
    }
  }
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
