import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';

enum BayType {
  bay1,
  bay2,
  mobileVan;

  String localizedName(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case BayType.bay1:
        return AppStrings.get('bay1Name', lang);
      case BayType.bay2:
        return AppStrings.get('bay2Name', lang);
      case BayType.mobileVan:
        return AppStrings.get('bayVanName', lang);
    }
  }

  String get displayName => localizedName('EN');

  String get shortName {
    switch (this) {
      case BayType.bay1:
        return 'Bay 1';
      case BayType.bay2:
        return 'Bay 2';
      case BayType.mobileVan:
        return 'Van 1';
    }
  }

  Color get color {
    switch (this) {
      case BayType.bay1:
        return AppColors.bay1Color;
      case BayType.bay2:
        return AppColors.bay2Color;
      case BayType.mobileVan:
        return AppColors.mobileVanColor;
    }
  }

  IconData get icon {
    switch (this) {
      case BayType.bay1:
      case BayType.bay2:
        return Icons.garage_rounded;
      case BayType.mobileVan:
        return Icons.airport_shuttle_rounded;
    }
  }
}

enum BayStatus {
  vacant,
  occupied,
  maintenance;

  String get displayName {
    switch (this) {
      case BayStatus.vacant:
        return 'Available';
      case BayStatus.occupied:
        return 'Busy Washing';
      case BayStatus.maintenance:
        return 'Offline';
    }
  }

  Color get color {
    switch (this) {
      case BayStatus.vacant:
        return AppColors.statusReady;
      case BayStatus.occupied:
        return AppColors.statusWashing;
      case BayStatus.maintenance:
        return AppColors.statusCancelled;
    }
  }
}

class StationBay {
  final BayType type;
  final BayStatus status;
  final String? activeBookingId;
  final String? activeLicensePlate;
  final String? assignedWasherName;
  final DateTime? startedAt;

  const StationBay({
    required this.type,
    this.status = BayStatus.vacant,
    this.activeBookingId,
    this.activeLicensePlate,
    this.assignedWasherName,
    this.startedAt,
  });

  bool get isVacant => status == BayStatus.vacant;
  bool get isOccupied => status == BayStatus.occupied;

  StationBay copyWith({
    BayType? type,
    BayStatus? status,
    String? activeBookingId,
    String? activeLicensePlate,
    String? assignedWasherName,
    DateTime? startedAt,
    bool clearActive = false,
  }) {
    return StationBay(
      type: type ?? this.type,
      status: status ?? this.status,
      activeBookingId: clearActive ? null : (activeBookingId ?? this.activeBookingId),
      activeLicensePlate: clearActive ? null : (activeLicensePlate ?? this.activeLicensePlate),
      assignedWasherName: clearActive ? null : (assignedWasherName ?? this.assignedWasherName),
      startedAt: clearActive ? null : (startedAt ?? this.startedAt),
    );
  }
}
