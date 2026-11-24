# Lib > Features > Inventory > Presentation > Screens

## Overview
Storekeeper dashboard providing stock balance views, re-order alerts, equipment status, and daily handover logging.

## Interface
- [storekeeper_dashboard_screen.dart:StorekeeperDashboardScreen] Class `StorekeeperDashboardScreen`
- [storekeeper_dashboard_screen.dart:_StorekeeperDashboardScreenState] Class `_StorekeeperDashboardScreenState`

## Invariants
- [storekeeper_dashboard_screen.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [storekeeper_dashboard_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
