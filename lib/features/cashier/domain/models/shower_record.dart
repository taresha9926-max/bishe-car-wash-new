import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';

class ShowerRecord {
  final String id;
  final int userCount;
  final double unitPrice; // ETB per person
  final double totalAmount; // userCount * unitPrice
  final PaymentMethod paymentMethod;
  final DateTime recordedAt;
  final String recordedBy;
  final String recordedByRole; // 'cashier' or 'operationalManager'
  final String? receiptScreenshot;
  final String? transactionRef;
  final String? notes;

  const ShowerRecord({
    required this.id,
    required this.userCount,
    required this.unitPrice,
    required this.totalAmount,
    this.paymentMethod = PaymentMethod.cash,
    required this.recordedAt,
    required this.recordedBy,
    this.recordedByRole = 'cashier',
    this.receiptScreenshot,
    this.transactionRef,
    this.notes,
  });

  bool get isCash => paymentMethod == PaymentMethod.cash;
  bool get isDigital => paymentMethod != PaymentMethod.cash;

  ShowerRecord copyWith({
    String? id,
    int? userCount,
    double? unitPrice,
    double? totalAmount,
    PaymentMethod? paymentMethod,
    DateTime? recordedAt,
    String? recordedBy,
    String? recordedByRole,
    String? receiptScreenshot,
    String? transactionRef,
    String? notes,
  }) {
    return ShowerRecord(
      id: id ?? this.id,
      userCount: userCount ?? this.userCount,
      unitPrice: unitPrice ?? this.unitPrice,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      recordedAt: recordedAt ?? this.recordedAt,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedByRole: recordedByRole ?? this.recordedByRole,
      receiptScreenshot: receiptScreenshot ?? this.receiptScreenshot,
      transactionRef: transactionRef ?? this.transactionRef,
      notes: notes ?? this.notes,
    );
  }
}
