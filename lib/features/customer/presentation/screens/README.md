# Lib > Features > Customer > Presentation > Screens

## Overview
Customer views for capacity monitoring, multi-step booking wizard, live visual progress stepper, and past booking receipts.

## Interface
- [booking_history_screen.dart:BookingHistoryScreen] Class `BookingHistoryScreen`
- [booking_history_screen.dart:_BookingHistoryScreenState] Class `_BookingHistoryScreenState`
- [customer_home_screen.dart:CustomerHomeScreen] Class `CustomerHomeScreen`
- [customer_home_screen.dart:_CustomerDivisionHubScreen] Class `_CustomerDivisionHubScreen`
- [customer_home_screen.dart:_CustomerDivisionHubScreenState] Class `_CustomerDivisionHubScreenState`
- [live_tracking_screen.dart:LiveTrackingScreen] Class `LiveTrackingScreen`
- [live_tracking_screen.dart:_LiveTrackingScreenState] Class `_LiveTrackingScreenState`
- [new_booking_screen.dart:NewBookingScreen] Class `NewBookingScreen`
- [new_booking_screen.dart:_NewBookingScreenState] Class `_NewBookingScreenState`

## Invariants
- [booking_history_screen.dart:immutability] Immutable value contract enforced via const constructors
- [customer_home_screen.dart:immutability] Immutable value contract enforced via const constructors
- [live_tracking_screen.dart:immutability] Immutable value contract enforced via const constructors
- [new_booking_screen.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [customer_home_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack
- [live_tracking_screen.dart:Timer] Background Task: Spawns recurring periodic background timer
- [new_booking_screen.dart:navigation] UI Navigation: Pushes modal dialogs or bottom sheets to navigator stack

## Verification
- Run: `flutter test`
