import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

class WashBooking {
  final String id;
  final String customerName;
  final String customerPhone;
  final ServiceType serviceType;
  final String? deliveryLocation; // Bishoftu street/landmark for mobile van
  final CarType carType;
  final String licensePlate;
  final WashPackage package;
  final WashStatus status;
  final BayType? assignedBay;
  final String? assignedWasherId;
  final String? assignedWasherName;
  final PaymentInfo payment;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final DateTime? completedAt;
  final bool commissionLogged;
  final bool isPhoneBooking;
  final String? gpsCoordinates;

  const WashBooking({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    required this.serviceType,
    this.deliveryLocation,
    required this.carType,
    required this.licensePlate,
    required this.package,
    this.status = WashStatus.pending,
    this.assignedBay,
    this.assignedWasherId,
    this.assignedWasherName,
    required this.payment,
    required this.createdAt,
    this.scheduledTime,
    this.completedAt,
    this.commissionLogged = false,
    this.isPhoneBooking = false,
    this.gpsCoordinates,
  });

  double get totalPrice => package.getPriceFor(carType);

  WashBooking copyWith({
    String? id,
    String? customerName,
    String? customerPhone,
    ServiceType? serviceType,
    String? deliveryLocation,
    CarType? carType,
    String? licensePlate,
    WashPackage? package,
    WashStatus? status,
    BayType? assignedBay,
    String? assignedWasherId,
    String? assignedWasherName,
    PaymentInfo? payment,
    DateTime? createdAt,
    DateTime? scheduledTime,
    DateTime? completedAt,
    bool? commissionLogged,
    bool? isPhoneBooking,
    String? gpsCoordinates,
  }) {
    return WashBooking(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      serviceType: serviceType ?? this.serviceType,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      carType: carType ?? this.carType,
      licensePlate: licensePlate ?? this.licensePlate,
      package: package ?? this.package,
      status: status ?? this.status,
      assignedBay: assignedBay ?? this.assignedBay,
      assignedWasherId: assignedWasherId ?? this.assignedWasherId,
      assignedWasherName: assignedWasherName ?? this.assignedWasherName,
      payment: payment ?? this.payment,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedAt: completedAt ?? this.completedAt,
      commissionLogged: commissionLogged ?? this.commissionLogged,
      isPhoneBooking: isPhoneBooking ?? this.isPhoneBooking,
      gpsCoordinates: gpsCoordinates ?? this.gpsCoordinates,
    );
  }
}
