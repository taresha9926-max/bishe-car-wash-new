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

  List<String> localizedFeatures(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    final key = _getPkgKey();
    if (key != null) {
      final list = AppStrings.getPackageFeatures(key, lang);
      if (list.isNotEmpty) return list;
    }
    return features;
  }

  String? _getPkgKey() {
    // 1. Exact match on known UUID suffix or ID string
    if (id.endsWith('0101') || id == 'pkg-silver') return 'pkg_silver';
    if (id.endsWith('0102') || id == 'pkg-gold') return 'pkg_gold';
    if (id.endsWith('0103') || id == 'pkg-plat-interior') return 'pkg_plat_interior';
    if (id.endsWith('0104') || id == 'pkg-plat-ext-a') return 'pkg_plat_ext_a';
    if (id.endsWith('0105') || id == 'pkg-plat-ext-b') return 'pkg_plat_ext_b';
    if (id.endsWith('0106') || id == 'pkg-plat-ext-c') return 'pkg_plat_ext_c';
    if (id.endsWith('0107') || id == 'pkg-diamond-a') return 'pkg_diamond_a';
    if (id.endsWith('0108') || id == 'pkg-diamond-b') return 'pkg_diamond_b';
    if (id.endsWith('0109') || id == 'pkg-diamond-full' || id == 'pkg-diamond-c') return 'pkg_diamond_full';
    if (id.endsWith('0110') || id == 'pkg-engine') return 'pkg_engine_chem';

    // 2. Strict name matching with boundary/suffix checks
    final n = name.toLowerCase();

    if (n.contains('diamond')) {
      if (n.contains('full') || n.contains('deluxe') || n.contains(' c') || n.contains('- c') || n.contains('level c') || n.contains('package c')) {
        return 'pkg_diamond_full';
      }
      if (n.contains(' b') || n.contains('- b') || n.contains('level b') || n.contains('package b')) {
        return 'pkg_diamond_b';
      }
      if (n.contains(' a') || n.contains('- a') || n.contains('level a') || n.contains('package a')) {
        return 'pkg_diamond_a';
      }
      return 'pkg_diamond_a';
    }

    if (n.contains('platinum') || n.contains('plat')) {
      if (n.contains('interior') || n.contains('cabin')) {
        return 'pkg_plat_interior';
      }
      if (n.contains(' c') || n.contains('- c') || n.contains('level c') || n.contains('ext_c') || n.contains('exterior c')) {
        return 'pkg_plat_ext_c';
      }
      if (n.contains(' b') || n.contains('- b') || n.contains('level b') || n.contains('ext_b') || n.contains('exterior b')) {
        return 'pkg_plat_ext_b';
      }
      if (n.contains(' a') || n.contains('- a') || n.contains('level a') || n.contains('ext_a') || n.contains('exterior a')) {
        return 'pkg_plat_ext_a';
      }
    }

    if (n.contains('silver') || n.contains('basic')) return 'pkg_silver';
    if (n.contains('gold') || n.contains('polish')) return 'pkg_gold';
    if (n.contains('engine') || n.contains('chemical') || n.contains('chassis') || n.contains('steam')) return 'pkg_engine_chem';

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
