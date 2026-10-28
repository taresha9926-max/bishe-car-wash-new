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
  });

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
    );
  }
}
