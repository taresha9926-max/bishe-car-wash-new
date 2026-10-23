import 'package:bishe_car_wash/features/booking_service/domain/models/bay_station.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/payment_info.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_package.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/wash_status.dart';

enum BookingOrigin {
  walkIn,
  phoneCall,
  onlineCustomer;

  String get label {
    switch (this) {
      case BookingOrigin.walkIn:
        return 'Physical Gate Walk-in';
      case BookingOrigin.phoneCall:
        return 'Phone Call Reservation';
      case BookingOrigin.onlineCustomer:
        return 'Online Customer Booking';
    }
  }
}

class WashBooking {
  final String id;
  final String customerName;
  final String customerPhone;
  final ServiceType serviceType;
  final String? deliveryLocation;
  final CarType carType;
  final String licensePlate;
  final WashPackage package;
  final WashStatus status;
  final BayType? assignedBay;
  final List<String> assignedWasherNames; // Exactly 2 washers when assigned
  final PaymentInfo payment;
  final BookingOrigin origin;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final DateTime? completedAt;
  final bool commissionLogged;

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
    this.assignedWasherNames = const [],
    required this.payment,
    this.origin = BookingOrigin.onlineCustomer,
    required this.createdAt,
    this.scheduledTime,
    this.completedAt,
    this.commissionLogged = false,
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
    List<String>? assignedWasherNames,
    PaymentInfo? payment,
    BookingOrigin? origin,
    DateTime? createdAt,
    DateTime? scheduledTime,
    DateTime? completedAt,
    bool? commissionLogged,
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
      assignedWasherNames: assignedWasherNames ?? this.assignedWasherNames,
      payment: payment ?? this.payment,
      origin: origin ?? this.origin,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      completedAt: completedAt ?? this.completedAt,
      commissionLogged: commissionLogged ?? this.commissionLogged,
    );
  }
}
