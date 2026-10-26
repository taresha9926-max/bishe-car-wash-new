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
    if (lower.contains('silver') || lower.contains('basic')) return 'pkg_silver';
    if (lower.contains('gold') || lower.contains('polish')) return 'pkg_gold';
    if (lower.contains('plat_interior') || (lower.contains('platinum') && lower.contains('interior'))) return 'pkg_plat_interior';
    if (lower.contains('plat_ext_a') || (lower.contains('platinum') && lower.contains('a'))) return 'pkg_plat_ext_a';
    if (lower.contains('plat_ext_b') || (lower.contains('platinum') && lower.contains('b'))) return 'pkg_plat_ext_b';
    if (lower.contains('plat_ext_c') || (lower.contains('platinum') && lower.contains('c'))) return 'pkg_plat_ext_c';
    if (lower.contains('diamond_a') || (lower.contains('diamond') && lower.contains('a'))) return 'pkg_diamond_a';
    if (lower.contains('diamond_b') || (lower.contains('diamond') && lower.contains('b'))) return 'pkg_diamond_b';
    if (lower.contains('diamond_full') || (lower.contains('diamond') && lower.contains('full'))) return 'pkg_diamond_full';
    if (lower.contains('engine') || lower.contains('chemical')) return 'pkg_engine_chem';
    // Fallback aliases
    if (lower.contains('express') || lower.contains('0101')) return 'pkg_silver';
    if (lower.contains('standard') || lower.contains('0102')) return 'pkg_gold';
    if (lower.contains('executive')) return 'pkg_plat_interior';
    if (lower.contains('chassis')) return 'pkg_engine_chem';
    if (lower.contains('deluxe')) return 'pkg_diamond_full';
    if (lower.contains('van') || lower.contains('mobile')) return 'pkg_mobile';
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
