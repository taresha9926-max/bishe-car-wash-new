# Lib > Features > Customer > Presentation > Widgets

## Overview
Customer UI widgets including vehicle category selectors, live progress steppers, negotiable price chips, and station availability cards.

## Interface
- [car_type_selector.dart:CarTypeSelector] Class `CarTypeSelector`
- [live_wash_stepper.dart:LiveWashStepper] Class `LiveWashStepper`
- [live_wash_stepper.dart:_PulsingHaloRing] Class `_PulsingHaloRing`
- [live_wash_stepper.dart:_PulsingHaloRingState] Class `_PulsingHaloRingState`
- [negotiable_price_badge.dart:NegotiablePriceBadge] Class `NegotiablePriceBadge`
- [station_type_card.dart:StationTypeCard] Class `StationTypeCard`

## Invariants
- [car_type_selector.dart:immutability] Immutable value contract enforced via const constructors
- [live_wash_stepper.dart:immutability] Immutable value contract enforced via const constructors
- [negotiable_price_badge.dart:immutability] Immutable value contract enforced via const constructors
- [station_type_card.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- None

## Verification
- Run: `flutter test`
