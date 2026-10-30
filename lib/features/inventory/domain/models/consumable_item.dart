class ConsumableItem {
  final String id;
  final String name;
  final String nameAmharic;
  final String category;
  final String unit;
  final double currentStock;
  final double minThreshold;
  final double unitCostEtb;
  final bool isDailyHandoverItem;
  final bool isDecommissioned;
  final String? decommissionReason;

  const ConsumableItem({
    required this.id,
    required this.name,
    required this.nameAmharic,
    required this.category,
    required this.unit,
    required this.currentStock,
    this.minThreshold = 5.0,
    this.unitCostEtb = 0.0,
    this.isDailyHandoverItem = true,
    this.isDecommissioned = false,
    this.decommissionReason,
  });

  bool get isLowStock => currentStock <= minThreshold;

  ConsumableItem copyWith({
    String? id,
    String? name,
    String? nameAmharic,
    String? category,
    String? unit,
    double? currentStock,
    double? minThreshold,
    double? unitCostEtb,
    bool? isDailyHandoverItem,
    bool? isDecommissioned,
    String? decommissionReason,
  }) {
    return ConsumableItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAmharic: nameAmharic ?? this.nameAmharic,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minThreshold: minThreshold ?? this.minThreshold,
      unitCostEtb: unitCostEtb ?? this.unitCostEtb,
      isDailyHandoverItem: isDailyHandoverItem ?? this.isDailyHandoverItem,
      isDecommissioned: isDecommissioned ?? this.isDecommissioned,
      decommissionReason: decommissionReason ?? this.decommissionReason,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAmharic': nameAmharic,
    'category': category,
    'unit': unit,
    'currentStock': currentStock,
    'minThreshold': minThreshold,
    'unitCostEtb': unitCostEtb,
    'isDailyHandoverItem': isDailyHandoverItem,
    'isDecommissioned': isDecommissioned,
    'decommissionReason': decommissionReason,
  };

  factory ConsumableItem.fromJson(Map<String, dynamic> json) {
    return ConsumableItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAmharic: json['nameAmharic'] as String? ?? '',
      category: json['category'] as String? ?? 'General Supplies',
      unit: json['unit'] as String? ?? 'Units',
      currentStock: (json['currentStock'] as num?)?.toDouble() ?? 0.0,
      minThreshold: (json['minThreshold'] as num?)?.toDouble() ?? 5.0,
      unitCostEtb: (json['unitCostEtb'] as num?)?.toDouble() ?? 0.0,
      isDailyHandoverItem: json['isDailyHandoverItem'] as bool? ?? true,
      isDecommissioned: json['isDecommissioned'] as bool? ?? false,
      decommissionReason: json['decommissionReason'] as String?,
    );
  }
}
