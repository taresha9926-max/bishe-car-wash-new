# Lib > Features > Admin > Presentation > Screens

## Overview
Administrative screens for executive dashboards, accountant reconciliations, commission logs, credential management, pricing matrix, and staff rosters.

## Interface
- [accountant_dashboard_screen.dart:AccountantDashboardScreen] Class `AccountantDashboardScreen`
- [accountant_dashboard_screen.dart:_AccountantDashboardScreenState] Class `_AccountantDashboardScreenState`
- [admin_dashboard_screen.dart:_AdminActionItem] Class `_AdminActionItem`
- [admin_dashboard_screen.dart:AdminDashboardScreen] Class `AdminDashboardScreen`
- [admin_dashboard_screen.dart:_AdminDashboardScreenState] Class `_AdminDashboardScreenState`
- [admin_dashboard_screen.dart:AdminTimeFilter] Enum `AdminTimeFilter`
- [commission_logs_screen.dart:CommissionLogsScreen] Class `CommissionLogsScreen`
- [commission_logs_screen.dart:_CommissionLogsScreenState] Class `_CommissionLogsScreenState`
- [credentials_management_screen.dart:CredentialsManagementScreen] Class `CredentialsManagementScreen`
- [credentials_management_screen.dart:_CredentialsManagementScreenState] Class `_CredentialsManagementScreenState`
- [pricing_management_screen.dart:PricingManagementScreen] Class `PricingManagementScreen`
- [pricing_management_screen.dart:_PricingManagementScreenState] Class `_PricingManagementScreenState`
- [staff_management_screen.dart:StaffManagementScreen] Class `StaffManagementScreen`

## Invariants
- [accountant_dashboard_screen.dart:immutability] Immutable value contract enforced via const constructors
- [admin_dashboard_screen.dart:immutability] Immutable value contract enforced via const constructors
- [commission_logs_screen.dart:immutability] Immutable value contract enforced via const constructors
- [credentials_management_screen.dart:immutability] Immutable value contract enforced via const constructors
- [pricing_management_screen.dart:immutability] Immutable value contract enforced via const constructors
- [staff_management_screen.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [accountant_dashboard_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [admin_dashboard_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [credentials_management_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [pricing_management_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [staff_management_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
