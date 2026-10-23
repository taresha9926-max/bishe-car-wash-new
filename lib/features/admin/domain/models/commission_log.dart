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
  final bool isSettled;
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
    this.commissionRate = 0.15,
    required this.commissionEarnedETB,
    this.isSettled = false,
    required this.completedAt,
  });

  CommissionLog copyWith({
    String? id,
    String? bookingId,
    String? washerId,
    String? washerName,
    String? carPlate,
    CarType? carType,
    String? servicePackageName,
    double? totalWashPriceETB,
    double? commissionRate,
    double? commissionEarnedETB,
    bool? isSettled,
    DateTime? completedAt,
  }) {
    return CommissionLog(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      washerId: washerId ?? this.washerId,
      washerName: washerName ?? this.washerName,
      carPlate: carPlate ?? this.carPlate,
      carType: carType ?? this.carType,
      servicePackageName: servicePackageName ?? this.servicePackageName,
      totalWashPriceETB: totalWashPriceETB ?? this.totalWashPriceETB,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionEarnedETB: commissionEarnedETB ?? this.commissionEarnedETB,
      isSettled: isSettled ?? this.isSettled,
      completedAt: completedAt ?? this.completedAt,
    );
  }

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
      'isSettled': isSettled,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}
