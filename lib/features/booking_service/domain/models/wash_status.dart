import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/constants/app_colors.dart';

enum WashStatus {
  pending,
  confirmed,
  assignedToBay,
  washing,
  drying,
  readyForPickup,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case WashStatus.pending:
        return 'Pending Approval';
      case WashStatus.confirmed:
        return 'Confirmed';
      case WashStatus.assignedToBay:
        return 'Queued in Bay';
      case WashStatus.washing:
        return 'Washing in Progress';
      case WashStatus.drying:
        return 'Drying & Detailing';
      case WashStatus.readyForPickup:
        return 'Ready for Pickup';
      case WashStatus.completed:
        return 'Completed';
      case WashStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case WashStatus.pending:
        return AppColors.statusPending;
      case WashStatus.confirmed:
        return AppColors.statusConfirmed;
      case WashStatus.assignedToBay:
        return const Color(0xFF6366F1); // Indigo
      case WashStatus.washing:
        return AppColors.statusWashing;
      case WashStatus.drying:
        return AppColors.statusDrying;
      case WashStatus.readyForPickup:
        return AppColors.statusReady;
      case WashStatus.completed:
        return AppColors.statusCompleted;
      case WashStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }

  IconData get icon {
    switch (this) {
      case WashStatus.pending:
        return Icons.hourglass_top_rounded;
      case WashStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case WashStatus.assignedToBay:
        return Icons.garage_rounded;
      case WashStatus.washing:
        return Icons.water_drop_rounded;
      case WashStatus.drying:
        return Icons.air_rounded;
      case WashStatus.readyForPickup:
        return Icons.car_repair_rounded;
      case WashStatus.completed:
        return Icons.verified_rounded;
      case WashStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  int get stepIndex {
    switch (this) {
      case WashStatus.pending:
        return 0;
      case WashStatus.confirmed:
        return 1;
      case WashStatus.assignedToBay:
        return 2;
      case WashStatus.washing:
        return 3;
      case WashStatus.drying:
        return 4;
      case WashStatus.readyForPickup:
        return 5;
      case WashStatus.completed:
        return 6;
      case WashStatus.cancelled:
        return -1;
    }
  }

  bool get isOngoing =>
      this != WashStatus.completed &&
      this != WashStatus.cancelled &&
      this != WashStatus.pending;
}
