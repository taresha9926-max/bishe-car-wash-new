import '../../../../core/localization/app_strings.dart';

/// Retail merchandise & car-care items sold directly to station customers.
class RetailItem {
  final String id;
  final String name;
  final String nameAmharic;
  final String nameOromoo;
  final String category;
  final double sellingPriceEtb;
  final double unitCostEtb;
  final int currentStock;
  final int minThreshold;
  final bool isActive;

  const RetailItem({
    required this.id,
    required this.name,
    required this.nameAmharic,
    this.nameOromoo = '',
    this.category = 'Retail Sales',
    required this.sellingPriceEtb,
    this.unitCostEtb = 0.0,
    this.currentStock = 0,
    this.minThreshold = 3,
    this.isActive = true,
  });

  bool get isLowStock => currentStock <= minThreshold;

  String localizedName(dynamic lang) {
    final resolved = lang is AppLanguage
        ? lang
        : AppLanguage.fromCode(lang?.toString() ?? 'EN');
    switch (resolved) {
      case AppLanguage.am:
        return nameAmharic.isNotEmpty ? nameAmharic : name;
      case AppLanguage.om:
        return nameOromoo.isNotEmpty ? nameOromoo : name;
      case AppLanguage.en:
        return name;
    }
  }

  RetailItem copyWith({
    String? id,
    String? name,
    String? nameAmharic,
    String? nameOromoo,
    String? category,
    double? sellingPriceEtb,
    double? unitCostEtb,
    int? currentStock,
    int? minThreshold,
    bool? isActive,
  }) {
    return RetailItem(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAmharic: nameAmharic ?? this.nameAmharic,
      nameOromoo: nameOromoo ?? this.nameOromoo,
      category: category ?? this.category,
      sellingPriceEtb: sellingPriceEtb ?? this.sellingPriceEtb,
      unitCostEtb: unitCostEtb ?? this.unitCostEtb,
      currentStock: currentStock ?? this.currentStock,
      minThreshold: minThreshold ?? this.minThreshold,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAmharic': nameAmharic,
    'nameOromoo': nameOromoo,
    'category': category,
    'sellingPriceEtb': sellingPriceEtb,
    'unitCostEtb': unitCostEtb,
    'currentStock': currentStock,
    'minThreshold': minThreshold,
    'isActive': isActive,
  };

  factory RetailItem.fromJson(Map<String, dynamic> json) {
    return RetailItem(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Item',
      nameAmharic: json['nameAmharic']?.toString() ?? '',
      nameOromoo: json['nameOromoo']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Retail Sales',
      sellingPriceEtb: (json['sellingPriceEtb'] as num?)?.toDouble() ?? 0.0,
      unitCostEtb: (json['unitCostEtb'] as num?)?.toDouble() ?? 0.0,
      currentStock: (json['currentStock'] as num?)?.toInt() ?? 0,
      minThreshold: (json['minThreshold'] as num?)?.toInt() ?? 3,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Official Bishe Station retail merchandise price list.
  static List<RetailItem> getDefaultOfficialItems() => const [
    RetailItem(
      id: 'RTL-001',
      name: 'Dash board cream',
      nameAmharic: 'ዳሽ ቦርድ ክሬም',
      nameOromoo: 'Kireemii Daashboordii',
      category: 'Care & Detailing',
      sellingPriceEtb: 1800.0,
    ),
    RetailItem(
      id: 'RTL-002',
      name: 'Car Perfume Gold Infusion',
      nameAmharic: 'የመኪና ሽቶ',
      nameOromoo: 'Shittoo Konkolaataa Gold Infusion',
      category: 'Care & Detailing',
      sellingPriceEtb: 1000.0,
    ),
    RetailItem(
      id: 'RTL-003',
      name: 'Foaming Tire Cleaner Darkener spray',
      nameAmharic: 'የአረፋ ጎማ ማጽጃ',
      nameOromoo: 'Qulqulleessaa Gommaa',
      category: 'Care & Detailing',
      sellingPriceEtb: 1200.0,
    ),
    RetailItem(
      id: 'RTL-004',
      name: 'Dog skin (Wsha koda)',
      nameAmharic: 'የውሻ ቆዳ',
      nameOromoo: 'Gogaa Saree (Wusha Qoda)',
      category: 'Care & Detailing',
      sellingPriceEtb: 1000.0,
    ),
    RetailItem(
      id: 'RTL-005',
      name: 'Microfiber towel/dryer big',
      nameAmharic: 'ማይክሮፋይበር ፎጣ ትልቅ',
      nameOromoo: 'Foothaa Maaykiroofaayibarii Guddaa',
      category: 'Microfiber towel',
      sellingPriceEtb: 1200.0,
    ),
    RetailItem(
      id: 'RTL-006',
      name: 'Microfiber towel medium',
      nameAmharic: 'ማይክሮፋይበር ፎጣ መካከለኛ',
      nameOromoo: 'Foothaa Maaykiroofaayibarii Giddugaleessaa',
      category: 'Microfiber towel',
      sellingPriceEtb: 1100.0,
    ),
    RetailItem(
      id: 'RTL-007',
      name: 'Microfiber towel small',
      nameAmharic: 'ማይክሮፋይበር ፎጣ ትንሽ',
      nameOromoo: 'Foothaa Maaykiroofaayibarii Xiqqaa',
      category: 'Microfiber towel',
      sellingPriceEtb: 900.0,
    ),
  ];
}
