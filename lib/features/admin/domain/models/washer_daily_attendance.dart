class WasherDailyAttendance {
  final String id;
  final String washerId;
  final String washerName;
  final DateTime date;
  final bool isPresent;
  final bool isExcused;
  final int carsWashedCount;
  final double commissionEarnedETB;
  final String? notes;

  const WasherDailyAttendance({
    required this.id,
    required this.washerId,
    required this.washerName,
    required this.date,
    required this.isPresent,
    this.isExcused = false,
    this.carsWashedCount = 0,
    this.commissionEarnedETB = 0.0,
    this.notes,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'washerId': washerId,
    'washerName': washerName,
    'date': date.toIso8601String(),
    'isPresent': isPresent,
    'isExcused': isExcused,
    'carsWashedCount': carsWashedCount,
    'commissionEarnedETB': commissionEarnedETB,
    'notes': notes,
  };

  factory WasherDailyAttendance.fromMap(Map<String, dynamic> map) => WasherDailyAttendance(
    id: map['id'] ?? '',
    washerId: map['washerId'] ?? '',
    washerName: map['washerName'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    isPresent: map['isPresent'] ?? true,
    isExcused: map['isExcused'] ?? false,
    carsWashedCount: map['carsWashedCount'] ?? 0,
    commissionEarnedETB: (map['commissionEarnedETB'] as num?)?.toDouble() ?? 0.0,
    notes: map['notes'],
  );
}
