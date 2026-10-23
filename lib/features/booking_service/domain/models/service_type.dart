import 'package:flutter/material.dart';

enum ServiceType {
  walkInStation,
  atHomeMobile;

  String get displayName {
    switch (this) {
      case ServiceType.walkInStation:
        return 'Walk-in Station';
      case ServiceType.atHomeMobile:
        return 'At-Home Mobile Service';
    }
  }

  String get capacityNotice {
    switch (this) {
      case ServiceType.walkInStation:
        return '2 Bays Available at Bishoftu Station';
      case ServiceType.atHomeMobile:
        return '1 Mobile Van Available (Bishoftu Area)';
    }
  }

  String get description {
    switch (this) {
      case ServiceType.walkInStation:
        return 'Drive in to our Bishoftu main facility with dedicated pressure washing bays.';
      case ServiceType.atHomeMobile:
        return 'Our fully equipped water-tank & power generator van comes right to your doorstep.';
    }
  }

  IconData get icon {
    switch (this) {
      case ServiceType.walkInStation:
        return Icons.local_car_wash_rounded;
      case ServiceType.atHomeMobile:
        return Icons.rv_hookup_rounded;
    }
  }
}
