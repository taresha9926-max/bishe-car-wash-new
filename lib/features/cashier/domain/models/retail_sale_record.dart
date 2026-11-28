import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';

/// Represents a direct retail merchandise sale recorded at the Cashier or
/// Operational Manager desk (0% VAT, 0% washer commission, tracked in COGS).
class RetailSaleRecord {
  final String id;
  final String itemId;
  final String itemName;
  final int quantity;
  final double unitPrice; // Selling price ETB per unit
  final double unitCost; // Purchase cost ETB per unit at time of sale
  final double totalAmount; // quantity * unitPrice
  final PaymentMethod paymentMethod;
  final DateTime recordedAt;
  final String recordedBy;
  final String recordedByRole; // 'cashier' or 'operationalManager'
  final String? customerName;
  final String? customerPhone;
  final String? transactionRef;
  final String? receiptScreenshot;
  final String? notes;

  const RetailSaleRecord({
    required this.id,
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
    this.unitCost = 0.0,
    required this.totalAmount,
    this.paymentMethod = PaymentMethod.cash,
    required this.recordedAt,
    required this.recordedBy,
    this.recordedByRole = 'cashier',
    this.customerName,
    this.customerPhone,
    this.transactionRef,
    this.receiptScreenshot,
    this.notes,
  });

  bool get isCash => paymentMethod == PaymentMethod.cash;
  bool get isDigital => paymentMethod != PaymentMethod.cash;
  double get totalCost => quantity * unitCost;

  RetailSaleRecord copyWith({
    String? id,
    String? itemId,
    String? itemName,
    int? quantity,
    double? unitPrice,
    double? unitCost,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    DateTime? recordedAt,
    String? recordedBy,
    String? recordedByRole,
    String? customerName,
    String? customerPhone,
    String? transactionRef,
    String? receiptScreenshot,
    String? notes,
  }) {
    return RetailSaleRecord(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitCost: unitCost ?? this.unitCost,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedByRole: recordedByRole ?? this.recordedByRole,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      transactionRef: transactionRef ?? this.transactionRef,
      receiptScreenshot: receiptScreenshot ?? this.receiptScreenshot,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'itemName': itemName,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'unitCost': unitCost,
    'totalAmount': totalAmount,
    'paymentMethod': paymentMethod.name,
    'recordedAt': recordedAt.toIso8601String(),
    'recordedBy': recordedBy,
    'recordedByRole': recordedByRole,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'transactionRef': transactionRef,
    'receiptScreenshot': receiptScreenshot,
    'notes': notes,
  };

  factory RetailSaleRecord.fromJson(Map<String, dynamic> json) {
    final methodStr = json['paymentMethod']?.toString() ?? 'cash';
    final method = PaymentMethod.values.where((m) => m.name == methodStr).firstOrNull ?? PaymentMethod.cash;
    return RetailSaleRecord(
      id: json['id']?.toString() ?? '',
      itemId: json['itemId']?.toString() ?? '',
      itemName: json['itemName']?.toString() ?? 'Item',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      unitCost: (json['unitCost'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: method,
      recordedAt: DateTime.tryParse(json['recordedAt']?.toString() ?? '') ?? DateTime.now(),
      recordedBy: json['recordedBy']?.toString() ?? 'Cashier',
      recordedByRole: json['recordedByRole']?.toString() ?? 'cashier',
      customerName: json['customerName']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      transactionRef: json['transactionRef']?.toString(),
      receiptScreenshot: json['receiptScreenshot']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
