class StockTransaction {
  final String id;
  final DateTime date;
  final String itemId;
  final String itemName;
  final String type; // 'receiveStock', 'decommission', 'dailyConsumption', 'adjustment'
  final double quantity;
  final String unit;
  final double unitCostEtb;
  final double totalCostEtb;
  final String supplier;
  final String? invoiceScreenshot;
  final String recordedBy;
  final String notes;

  const StockTransaction({
    required this.id,
    required this.date,
    required this.itemId,
    required this.itemName,
    required this.type,
    required this.quantity,
    this.unit = 'Units',
    this.unitCostEtb = 0.0,
    this.totalCostEtb = 0.0,
    this.supplier = '',
    this.invoiceScreenshot,
    this.recordedBy = 'Storekeeper',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'itemId': itemId,
    'itemName': itemName,
    'type': type,
    'quantity': quantity,
    'unit': unit,
    'unitCostEtb': unitCostEtb,
    'totalCostEtb': totalCostEtb,
    'supplier': supplier,
    'invoice_screenshot': invoiceScreenshot,
    'recordedBy': recordedBy,
    'notes': notes,
  };

  factory StockTransaction.fromJson(Map<String, dynamic> json) {
    return StockTransaction(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      itemId: json['itemId'] as String? ?? '',
      itemName: json['itemName'] as String? ?? 'Item',
      type: json['type'] as String? ?? 'receiveStock',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'Units',
      unitCostEtb: (json['unitCostEtb'] as num?)?.toDouble() ?? 0.0,
      totalCostEtb: (json['totalCostEtb'] as num?)?.toDouble() ?? 0.0,
      supplier: json['supplier'] as String? ?? '',
      invoiceScreenshot: json['invoice_screenshot'] as String?,
      recordedBy: json['recordedBy'] as String? ?? 'Storekeeper',
      notes: json['notes'] as String? ?? '',
    );
  }
}
