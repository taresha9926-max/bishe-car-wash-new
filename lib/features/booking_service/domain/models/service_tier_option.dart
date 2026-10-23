import 'package:bishe_car_wash/features/booking_service/domain/models/car_type.dart';
import 'package:bishe_car_wash/features/booking_service/domain/models/service_type.dart';

class ServiceTierOption {
  final ServiceType serviceType;
  final CarType carType;
  final String label;
  final double defaultPrice;

  const ServiceTierOption({
    required this.serviceType,
    required this.carType,
    required this.label,
    required this.defaultPrice,
  });

  static const List<ServiceTierOption> allOptions = [
    ServiceTierOption(
      serviceType: ServiceType.walkInStation,
      carType: CarType.automobile,
      label: 'Walk-in Bay - Type A (Automobile) — 300 ETB',
      defaultPrice: 300.0,
    ),
    ServiceTierOption(
      serviceType: ServiceType.walkInStation,
      carType: CarType.minibus,
      label: 'Walk-in Bay - Type B (Minibus) — 450 ETB',
      defaultPrice: 450.0,
    ),
    ServiceTierOption(
      serviceType: ServiceType.walkInStation,
      carType: CarType.truck,
      label: 'Walk-in Bay - Type C (Truck/Heavy) — 700 ETB',
      defaultPrice: 700.0,
    ),
    ServiceTierOption(
      serviceType: ServiceType.atHomeMobile,
      carType: CarType.automobile,
      label: 'At-Home Mobile Van - Type A (Automobile) — 500 ETB',
      defaultPrice: 500.0,
    ),
    ServiceTierOption(
      serviceType: ServiceType.atHomeMobile,
      carType: CarType.minibus,
      label: 'At-Home Mobile Van - Type B (Minibus) — 700 ETB',
      defaultPrice: 700.0,
    ),
    ServiceTierOption(
      serviceType: ServiceType.atHomeMobile,
      carType: CarType.truck,
      label: 'At-Home Mobile Van - Type C (Truck/Heavy) — 1,050 ETB',
      defaultPrice: 1050.0,
    ),
  ];
}
