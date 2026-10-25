import 'package:bishe_car_wash/core/localization/app_strings.dart';
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

  String localizedName(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    final key = _getPkgKey();
    if (key != null) {
      return AppStrings.get('${key}_name', lang);
    }
    return name;
  }

  String localizedDescription(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    final key = _getPkgKey();
    if (key != null) {
      return AppStrings.get('${key}_desc', lang);
    }
    return description;
  }

  String? _getPkgKey() {
    final lower = ('$id $name').toLowerCase();
    if (lower.contains('express') || lower.contains('0101')) return 'pkg_express';
    if (lower.contains('standard') || lower.contains('0102')) return 'pkg_standard';
    if (lower.contains('executive')) return 'pkg_executive';
    if (lower.contains('chassis') || lower.contains('engine flush')) return 'pkg_chassis';
    if (lower.contains('deluxe') || lower.contains('0103') || lower.contains('engine detail') || lower.contains('spa')) return 'pkg_deluxe';
    if (lower.contains('van') || lower.contains('mobile') || lower.contains('0104')) return 'pkg_mobile';
    return null;
  }

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
