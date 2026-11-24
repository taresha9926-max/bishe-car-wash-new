# Lib > Features > Cashier > Presentation > Widgets

## Overview
Cashier UI components for active queue tiles, live bay status cards, station money tabs, and intake forms.

## Interface
- [staff_intake_helpers.dart:StaffNegotiatedPriceCard] Class `StaffNegotiatedPriceCard`
- [staff_intake_helpers.dart:StaffWasherPickerCard] Class `StaffWasherPickerCard`
- [staff_intake_helpers.dart:StaffDeliveryModeSelector] Class `StaffDeliveryModeSelector`
- [station_money_tab.dart:StationMoneyTab] Class `StationMoneyTab`
- [station_money_tab.dart:_StationMoneyTabState] Class `_StationMoneyTabState`
- [station_queue_tab.dart:PrimaryIntakeActionRow] Class `PrimaryIntakeActionRow`
- [station_queue_tab.dart:StationQueueTab] Class `StationQueueTab`
- [station_queue_tab.dart:_StationQueueTabState] Class `_StationQueueTabState`
- [station_queue_tab.dart:QueueStageFilter] Enum `QueueStageFilter`
- [station_queue_tab.dart:getActiveDivisionQueue] Top-level function `getActiveDivisionQueue()`

## Invariants
- [staff_intake_helpers.dart:immutability] Immutable value contract enforced via const constructors
- [station_money_tab.dart:immutability] Immutable value contract enforced via const constructors
- [station_queue_tab.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [station_money_tab.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [station_queue_tab.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
