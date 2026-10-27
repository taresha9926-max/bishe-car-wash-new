import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';

enum CarType {
  automobile,
  minibus,
  truck;

  String localizedName(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case CarType.automobile:
        return AppStrings.get('automobile', lang);
      case CarType.minibus:
        return AppStrings.get('minibus', lang);
      case CarType.truck:
        return AppStrings.get('truck', lang);
    }
  }

  String localizedSubLabel(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case CarType.automobile:
        return AppStrings.get('automobileSub', lang);
      case CarType.minibus:
        return AppStrings.get('minibusSub', lang);
      case CarType.truck:
        return AppStrings.get('truckSub', lang);
    }
  }

  String get displayName => localizedName('EN');
  String get subLabel => localizedSubLabel('EN');

  IconData get icon {
    switch (this) {
      case CarType.automobile:
        return Icons.directions_car_rounded;
      case CarType.minibus:
        return Icons.directions_bus_rounded;
      case CarType.truck:
        return Icons.local_shipping_rounded;
    }
  }
}
