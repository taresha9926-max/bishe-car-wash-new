import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';

class ShowerRecord {
  final String id;
  final int userCount;
  final double unitPrice; // ETB per person
  final double totalAmount; // userCount * unitPrice
  final PaymentMethod paymentMethod;
  final DateTime recordedAt;
  final String recordedBy;
  final String? notes;

  const ShowerRecord({
    required this.id,
    required this.userCount,
    required this.unitPrice,
    required this.totalAmount,
    this.paymentMethod = PaymentMethod.cash,
    required this.recordedAt,
    required this.recordedBy,
    this.notes,
  });

  bool get isCash => paymentMethod == PaymentMethod.cash;
  bool get isDigital => paymentMethod != PaymentMethod.cash;
}
