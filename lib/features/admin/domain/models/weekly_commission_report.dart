class WeeklyCommissionReport {
  final String id;
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final DateTime reportedAt;
  final String cashierName;
  final double totalWeeklyPool;
  final Map<String, double> washerCommissions; // washer name -> ETB
  final String? notes;
  final bool isSubmitted;
  final bool isDisbursed;
  final DateTime? disbursedAt;

  const WeeklyCommissionReport({
    required this.id,
    required this.weekStartDate,
    required this.weekEndDate,
    required this.reportedAt,
    required this.cashierName,
    required this.totalWeeklyPool,
    required this.washerCommissions,
    this.notes,
    this.isSubmitted = true,
    this.isDisbursed = false,
    this.disbursedAt,
  });

  WeeklyCommissionReport copyWith({
    String? id,
    DateTime? weekStartDate,
    DateTime? weekEndDate,
    DateTime? reportedAt,
    String? cashierName,
    double? totalWeeklyPool,
    Map<String, double>? washerCommissions,
    String? notes,
    bool? isSubmitted,
    bool? isDisbursed,
    DateTime? disbursedAt,
  }) {
    return WeeklyCommissionReport(
      id: id ?? this.id,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      reportedAt: reportedAt ?? this.reportedAt,
      cashierName: cashierName ?? this.cashierName,
      totalWeeklyPool: totalWeeklyPool ?? this.totalWeeklyPool,
      washerCommissions: washerCommissions ?? this.washerCommissions,
      notes: notes ?? this.notes,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isDisbursed: isDisbursed ?? this.isDisbursed,
      disbursedAt: disbursedAt ?? this.disbursedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weekStartDate': weekStartDate.toIso8601String(),
      'weekEndDate': weekEndDate.toIso8601String(),
      'reportedAt': reportedAt.toIso8601String(),
      'cashierName': cashierName,
      'totalWeeklyPool': totalWeeklyPool,
      'washerCommissions': washerCommissions,
      'notes': notes,
      'isSubmitted': isSubmitted,
      'isDisbursed': isDisbursed,
      'disbursedAt': disbursedAt?.toIso8601String(),
    };
  }

  factory WeeklyCommissionReport.fromMap(Map<String, dynamic> map) {
    return WeeklyCommissionReport(
      id: map['id'] ?? '',
      weekStartDate: DateTime.tryParse(map['weekStartDate'] ?? '') ?? DateTime.now(),
      weekEndDate: DateTime.tryParse(map['weekEndDate'] ?? '') ?? DateTime.now(),
      reportedAt: DateTime.tryParse(map['reportedAt'] ?? '') ?? DateTime.now(),
      cashierName: map['cashierName'] ?? 'Cashier',
      totalWeeklyPool: (map['totalWeeklyPool'] as num?)?.toDouble() ?? 0.0,
      washerCommissions: Map<String, double>.from(map['washerCommissions'] ?? {}),
      notes: map['notes'],
      isSubmitted: map['isSubmitted'] ?? true,
      isDisbursed: map['isDisbursed'] ?? false,
      disbursedAt: map['disbursedAt'] != null ? DateTime.tryParse(map['disbursedAt']) : null,
    );
  }
}
