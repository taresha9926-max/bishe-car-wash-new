import 'package:flutter/material.dart';
import '../../../../core/localization/app_strings.dart';

enum ServiceType {
  walkInStation,
  atHomeMobile,
  valetPickUp,
  phoneCallBooking;

  String localizedName(String langCode, {bool isCarpet = false}) {
    final lang = AppLanguage.fromCode(langCode);
    if (isCarpet) {
      switch (this) {
        case ServiceType.walkInStation:
          return AppStrings.get('carpetStationService', lang);
        case ServiceType.atHomeMobile:
          return AppStrings.get('carpetHomeTitle', lang);
        case ServiceType.valetPickUp:
          return AppStrings.get('carpetValetTitle', lang);
        case ServiceType.phoneCallBooking:
          return AppStrings.get('servicePhoneCall', lang);
      }
    }
    switch (this) {
      case ServiceType.walkInStation:
        return AppStrings.get('serviceWalkIn', lang);
      case ServiceType.atHomeMobile:
        return AppStrings.get('serviceAtHome', lang);
      case ServiceType.valetPickUp:
        return AppStrings.get('serviceValetPickUp', lang);
      case ServiceType.phoneCallBooking:
        return AppStrings.get('servicePhoneCall', lang);
    }
  }

  String localizedCapacity(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case ServiceType.walkInStation:
        return AppStrings.get('serviceWalkInCapacity', lang);
      case ServiceType.atHomeMobile:
        return AppStrings.get('serviceAtHomeCapacity', lang);
      case ServiceType.valetPickUp:
        return AppStrings.get('serviceValetCapacity', lang);
      case ServiceType.phoneCallBooking:
        return AppStrings.get('servicePhoneCapacity', lang);
    }
  }

  String localizedDescription(String langCode, {bool isCarpet = false}) {
    final lang = AppLanguage.fromCode(langCode);
    if (isCarpet) {
      switch (this) {
        case ServiceType.walkInStation:
          return AppStrings.get('carpetStationSub', lang);
        case ServiceType.atHomeMobile:
          return AppStrings.get('carpetHomeSub', lang);
        case ServiceType.valetPickUp:
          return AppStrings.get('carpetValetSub', lang);
        case ServiceType.phoneCallBooking:
          return AppStrings.get('servicePhoneDesc', lang);
      }
    }
    switch (this) {
      case ServiceType.walkInStation:
        return AppStrings.get('serviceWalkInDesc', lang);
      case ServiceType.atHomeMobile:
        return AppStrings.get('serviceAtHomeDesc', lang);
      case ServiceType.valetPickUp:
        return AppStrings.get('serviceValetDesc', lang);
      case ServiceType.phoneCallBooking:
        return AppStrings.get('servicePhoneDesc', lang);
    }
  }

  String get displayName => localizedName('EN');
  String get capacityNotice => localizedCapacity('EN');
  String get description => localizedDescription('EN');

  IconData get icon {
    switch (this) {
      case ServiceType.walkInStation:
        return Icons.local_car_wash_rounded;
      case ServiceType.atHomeMobile:
        return Icons.rv_hookup_rounded;
      case ServiceType.valetPickUp:
        return Icons.car_rental_rounded;
      case ServiceType.phoneCallBooking:
        return Icons.phone_in_talk_rounded;
    }
  }

  bool get requiresLocation => this == ServiceType.atHomeMobile || this == ServiceType.valetPickUp;
}
