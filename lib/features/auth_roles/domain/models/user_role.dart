import 'package:flutter/material.dart';

enum UserRole {
  customer,
  cashier,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.cashier:
        return 'Cashier';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Book Station or Mobile Van wash & track live status';
      case UserRole.cashier:
        return 'Gate entries, assign Bay 1, Bay 2 or Van, process Cash & Telebirr';
      case UserRole.admin:
        return 'Control pricing, manage staff salaries & automatic commission logs';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.customer:
        return Icons.person_rounded;
      case UserRole.cashier:
        return Icons.point_of_sale_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }
}
