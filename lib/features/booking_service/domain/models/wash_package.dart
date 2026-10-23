import 'car_type.dart';

class WashPackage {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final Map<CarType, double> pricingByCarType;
  final List<String> features;

  const WashPackage({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.pricingByCarType,
    required this.features,
  });

  double getPriceFor(CarType carType) {
    return pricingByCarType[carType] ?? 300.0;
  }

  WashPackage copyWith({
    String? id,
    String? name,
    String? description,
    int? durationMinutes,
    Map<CarType, double>? pricingByCarType,
    List<String>? features,
  }) {
    return WashPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      pricingByCarType: pricingByCarType != null
          ? Map<CarType, double>.from(pricingByCarType)
          : Map<CarType, double>.from(this.pricingByCarType),
      features: features ?? this.features,
    );
  }

  WashPackage updatePrice(CarType carType, double newPrice) {
    final updatedPrices = Map<CarType, double>.from(pricingByCarType);
    updatedPrices[carType] = newPrice;
    return copyWith(pricingByCarType: updatedPrices);
  }
}
