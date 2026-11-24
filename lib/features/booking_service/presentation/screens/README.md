# Lib > Features > Booking_Service > Presentation > Screens

## Overview
Analytical views for vehicle service histories and cumulative financial reports.

## Interface
- [financial_reports_view.dart:FinancialReportsView] Class `FinancialReportsView`
- [financial_reports_view.dart:_FinancialReportsViewState] Class `_FinancialReportsViewState`
- [financial_reports_view.dart:FinancialReportFilter] Enum `FinancialReportFilter`
- [vehicle_history_screen.dart:VehicleHistoryScreen] Class `VehicleHistoryScreen`
- [vehicle_history_screen.dart:_VehicleHistoryScreenState] Class `_VehicleHistoryScreenState`
- [vehicle_history_screen.dart:HistoryDateFilter] Enum `HistoryDateFilter`

## Invariants
- [financial_reports_view.dart:immutability] Immutable value contract enforced via const constructors
- [vehicle_history_screen.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [financial_reports_view.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [vehicle_history_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
