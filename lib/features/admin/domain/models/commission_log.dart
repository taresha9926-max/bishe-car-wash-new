import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';

class CommissionLog {
  final String id;
  final String bookingId;
  final String washerId;
  final String washerName;
  final String carPlate;
  final CarType carType;
  final String servicePackageName;
  final double totalWashPriceETB;
  final double commissionRate;
  final double commissionEarnedETB;
  final DateTime completedAt;

  const CommissionLog({
    required this.id,
    required this.bookingId,
    required this.washerId,
    required this.washerName,
    required this.carPlate,
    required this.carType,
    required this.servicePackageName,
    required this.totalWashPriceETB,
    required this.commissionRate,
    required this.commissionEarnedETB,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bookingId': bookingId,
      'washerId': washerId,
      'washerName': washerName,
      'carPlate': carPlate,
      'carType': carType.displayName,
      'servicePackageName': servicePackageName,
      'totalWashPriceETB': totalWashPriceETB,
      'commissionRate': commissionRate,
      'commissionEarnedETB': commissionEarnedETB,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
