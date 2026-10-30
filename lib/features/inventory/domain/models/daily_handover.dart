enum HandoverStatus {
  active,
  completed;

  String get displayName => this == HandoverStatus.active ? 'Active Handover' : 'Completed';
}

class DailyHandover {
  final String id;
  final DateTime date;
  final String washerTeamLeaderName;
  final Map<String, double> issuedQuantities; // itemId -> issued
  final Map<String, double> returnedQuantities; // itemId -> returned
  final Map<String, double> consumedQuantities; // itemId -> net consumed
  final HandoverStatus status;
  final DateTime checkedOutAt;
  final DateTime? checkedInAt;
  final int carsWashedDuringShift;
  final String notes;

  const DailyHandover({
    required this.id,
    required this.date,
    required this.washerTeamLeaderName,
    required this.issuedQuantities,
    this.returnedQuantities = const {},
    this.consumedQuantities = const {},
    this.status = HandoverStatus.active,
    required this.checkedOutAt,
    this.checkedInAt,
    this.carsWashedDuringShift = 0,
    this.notes = '',
  });

  DailyHandover copyWith({
    String? id,
    DateTime? date,
    String? washerTeamLeaderName,
    Map<String, double>? issuedQuantities,
    Map<String, double>? returnedQuantities,
    Map<String, double>? consumedQuantities,
    HandoverStatus? status,
    DateTime? checkedOutAt,
    DateTime? checkedInAt,
    int? carsWashedDuringShift,
    String? notes,
  }) {
    return DailyHandover(
      id: id ?? this.id,
      date: date ?? this.date,
      washerTeamLeaderName: washerTeamLeaderName ?? this.washerTeamLeaderName,
      issuedQuantities: issuedQuantities ?? this.issuedQuantities,
      returnedQuantities: returnedQuantities ?? this.returnedQuantities,
      consumedQuantities: consumedQuantities ?? this.consumedQuantities,
      status: status ?? this.status,
      checkedOutAt: checkedOutAt ?? this.checkedOutAt,
      checkedInAt: checkedInAt ?? this.checkedInAt,
      carsWashedDuringShift: carsWashedDuringShift ?? this.carsWashedDuringShift,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'washerTeamLeaderName': washerTeamLeaderName,
    'issuedQuantities': issuedQuantities,
    'returnedQuantities': returnedQuantities,
    'consumedQuantities': consumedQuantities,
    'status': status.name,
    'checkedOutAt': checkedOutAt.toIso8601String(),
    'checkedInAt': checkedInAt?.toIso8601String(),
    'carsWashedDuringShift': carsWashedDuringShift,
    'notes': notes,
  };

  factory DailyHandover.fromJson(Map<String, dynamic> json) {
    Map<String, double> parseMap(dynamic mapObj) {
      if (mapObj is! Map) return {};
      return mapObj.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
    }

    return DailyHandover(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      washerTeamLeaderName: json['washerTeamLeaderName'] as String? ?? 'Washer Team Leader',
      issuedQuantities: parseMap(json['issuedQuantities']),
      returnedQuantities: parseMap(json['returnedQuantities']),
      consumedQuantities: parseMap(json['consumedQuantities']),
      status: HandoverStatus.values.firstWhere(
        (s) => s.name == (json['status'] as String?),
        orElse: () => HandoverStatus.active,
      ),
      checkedOutAt: DateTime.parse(json['checkedOutAt'] as String),
      checkedInAt: json['checkedInAt'] != null ? DateTime.tryParse(json['checkedInAt'] as String) : null,
      carsWashedDuringShift: json['carsWashedDuringShift'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}
