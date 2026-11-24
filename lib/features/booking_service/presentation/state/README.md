# Lib > Features > Booking_Service > Presentation > State

## Overview
Reactive state notifier and InheritedNotifier provider driving immediate UI updates across all station screens.

## Interface
- [app_state_notifier.dart:AppStateNotifier] Class `AppStateNotifier`
- [app_state_notifier.dart:ActiveServiceDivision] Enum `ActiveServiceDivision`
- [app_state_provider.dart:AppStateProvider] Class `AppStateProvider`

## Invariants
- [app_state_notifier.dart:immutability] Immutable value contract enforced via const constructors
- [app_state_provider.dart:assert] Invariant check: `provider != null`
- [app_state_provider.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [app_state_notifier.dart:notifyListeners] State Broadcast: Emits reactive UI state updates via `ChangeNotifier.notifyListeners()`

## Verification
- Run: `flutter test`
