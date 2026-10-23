import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';

enum BayType {
  bay1,
  bay2,
  mobileVan;

  String get displayName {
    switch (this) {
      case BayType.bay1:
        return 'Bay 1 (Station)';
      case BayType.bay2:
        return 'Bay 2 (Station)';
      case BayType.mobileVan:
        return 'Mobile Van 1 (At-Home)';
    }
  }

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
        return 'Vacant';
      case BayStatus.occupied:
        return 'In Service';
      case BayStatus.maintenance:
        return 'Cleaning';
    }
  }

  Color get color {
    switch (this) {
      case BayStatus.vacant:
        return const Color(0xFF16A34A);
      case BayStatus.occupied:
        return const Color(0xFF2563EB);
      case BayStatus.maintenance:
        return const Color(0xFFEA580C);
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
