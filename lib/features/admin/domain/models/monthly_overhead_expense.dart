/// Represents a recurring monthly overhead expense (rent, utilities, salaries, taxes)
/// for the BISHE Car Wash station, which is accrued on a daily basis (Monthly ÷ 30).
class MonthlyOverheadExpense {
  final String id;
  final String name;
  final String nameAmharic;
  final String nameOromo;
  final double monthlyAmountEtb;
  final String category; // 'Rent', 'Utilities', 'Payroll', 'Taxes', 'Operational'
  final bool isDefault;

  const MonthlyOverheadExpense({
    required this.id,
    required this.name,
    required this.nameAmharic,
    required this.nameOromo,
    required this.monthlyAmountEtb,
    this.category = 'Operational',
    this.isDefault = false,
  });

  /// The exact daily operational cost accrued in the daily P&L statement.
  double get dailyAccrualEtb => monthlyAmountEtb / 30.0;

  MonthlyOverheadExpense copyWith({
    String? id,
    String? name,
    String? nameAmharic,
    String? nameOromo,
    double? monthlyAmountEtb,
    String? category,
    bool? isDefault,
  }) {
    return MonthlyOverheadExpense(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAmharic: nameAmharic ?? this.nameAmharic,
      nameOromo: nameOromo ?? this.nameOromo,
      monthlyAmountEtb: monthlyAmountEtb ?? this.monthlyAmountEtb,
      category: category ?? this.category,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAmharic': nameAmharic,
    'nameOromo': nameOromo,
    'monthlyAmountEtb': monthlyAmountEtb,
    'category': category,
    'isDefault': isDefault,
  };

  factory MonthlyOverheadExpense.fromJson(Map<String, dynamic> json) {
    return MonthlyOverheadExpense(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Expense',
      nameAmharic: json['nameAmharic'] as String? ?? '',
      nameOromo: json['nameOromo'] as String? ?? '',
      monthlyAmountEtb: (json['monthlyAmountEtb'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Operational',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
