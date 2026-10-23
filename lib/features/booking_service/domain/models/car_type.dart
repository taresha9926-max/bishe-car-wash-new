import 'package:flutter/material.dart';

enum CarType {
  automobile,
  minibus,
  truck;

  String get displayName {
    switch (this) {
      case CarType.automobile:
        return 'Automobile';
      case CarType.minibus:
        return 'Minibus';
      case CarType.truck:
        return 'Truck / SUV';
    }
  }

  String get subLabel {
    switch (this) {
      case CarType.automobile:
        return 'Sedan, Hatchback, Compact';
      case CarType.minibus:
        return 'Toyota HiAce, Dolphin, 12-16 seats';
      case CarType.truck:
        return 'Pickup, Heavy SUV, Light Truck';
    }
  }

  IconData get icon {
    switch (this) {
      case CarType.automobile:
        return Icons.directions_car_rounded;
      case CarType.minibus:
        return Icons.airport_shuttle_rounded;
      case CarType.truck:
        return Icons.local_shipping_rounded;
    }
  }
}
