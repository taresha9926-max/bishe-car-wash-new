enum AssetCondition {
  operational,
  needsService,
  underRepair,
  decommissioned;

  String get displayName {
    switch (this) {
      case AssetCondition.operational:
        return 'Operational';
      case AssetCondition.needsService:
        return 'Needs Service';
      case AssetCondition.underRepair:
        return 'Under Repair';
      case AssetCondition.decommissioned:
        return 'Decommissioned';
    }
  }
}

class FixedAsset {
  final String id;
  final String name;
  final String nameAmharic;
  final String category;
  final String serialNumber;
  final String assignedLocation;
  final AssetCondition condition;
  final String? decommissionReason;
  final DateTime? lastServicedDate;
  final int quantity;
  final String notes;

  const FixedAsset({
    required this.id,
    required this.name,
    required this.nameAmharic,
    required this.category,
    required this.serialNumber,
    required this.assignedLocation,
    this.condition = AssetCondition.operational,
    this.decommissionReason,
    this.lastServicedDate,
    this.quantity = 1,
    this.notes = '',
  });

  FixedAsset copyWith({
    String? id,
    String? name,
    String? nameAmharic,
    String? category,
    String? serialNumber,
    String? assignedLocation,
    AssetCondition? condition,
    String? decommissionReason,
    DateTime? lastServicedDate,
    int? quantity,
    String? notes,
  }) {
    return FixedAsset(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAmharic: nameAmharic ?? this.nameAmharic,
      category: category ?? this.category,
      serialNumber: serialNumber ?? this.serialNumber,
      assignedLocation: assignedLocation ?? this.assignedLocation,
      condition: condition ?? this.condition,
      decommissionReason: decommissionReason ?? this.decommissionReason,
      lastServicedDate: lastServicedDate ?? this.lastServicedDate,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAmharic': nameAmharic,
    'category': category,
    'serialNumber': serialNumber,
    'assignedLocation': assignedLocation,
    'condition': condition.name,
    'decommissionReason': decommissionReason,
    'lastServicedDate': lastServicedDate?.toIso8601String(),
    'quantity': quantity,
    'notes': notes,
  };

  factory FixedAsset.fromJson(Map<String, dynamic> json) {
    return FixedAsset(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAmharic: json['nameAmharic'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      serialNumber: json['serialNumber'] as String? ?? 'SN-BISHE',
      assignedLocation: json['assignedLocation'] as String? ?? 'Station',
      condition: AssetCondition.values.firstWhere(
        (c) => c.name == (json['condition'] as String?),
        orElse: () => AssetCondition.operational,
      ),
      decommissionReason: json['decommissionReason'] as String?,
      lastServicedDate: json['lastServicedDate'] != null
          ? DateTime.tryParse(json['lastServicedDate'] as String)
          : null,
      quantity: json['quantity'] as int? ?? 1,
      notes: json['notes'] as String? ?? '',
    );
  }
}
