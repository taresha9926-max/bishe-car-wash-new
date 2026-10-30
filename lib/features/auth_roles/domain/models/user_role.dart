import 'package:flutter/material.dart';
import 'package:bishe_car_wash/core/localization/app_strings.dart';

enum UserRole {
  customer,
  cashier,
  storekeeper,
  accountant,
  admin;

  String localizedName(String langCode) {
    final lang = AppLanguage.fromCode(langCode);
    switch (this) {
      case UserRole.customer:
        return AppStrings.get('customerRole', lang);
      case UserRole.cashier:
        return AppStrings.get('cashierRole', lang);
      case UserRole.storekeeper:
        return AppStrings.get('storekeeperRole', lang);
      case UserRole.accountant:
        return AppStrings.get('accountantRole', lang);
      case UserRole.admin:
        return AppStrings.get('adminRole', lang);
    }
  }

  String get displayName => localizedName('EN');

  String get description {
    switch (this) {
      case UserRole.customer:
        return 'Book Station or Mobile Van wash & track live status';
      case UserRole.cashier:
        return 'Gate entries, assign Bay 1, Bay 2 or Van, process Cash & Telebirr';
      case UserRole.storekeeper:
        return 'Manage fixed assets, consumables stock & daily washer team handovers';
      case UserRole.accountant:
        return 'Audit cashier closings, bank deposit slips, washer commissions & P&L';
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
      case UserRole.storekeeper:
        return Icons.inventory_2_rounded;
      case UserRole.accountant:
        return Icons.account_balance_wallet_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }
}
