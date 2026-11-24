# Lib > Features > Booking_Service > Domain > Models

## Overview
Core domain models for bay stations, car types, payment information, service packages, wash bookings, and lifecycle statuses.

## Interface
- [bay_station.dart:StationBay] Class `StationBay`
- [bay_station.dart:BayType] Enum `BayType`
- [bay_station.dart:BayStatus] Enum `BayStatus`
- [car_type.dart:CarType] Enum `CarType`
- [car_wash_service_item.dart:CarWashServiceItem] Class `CarWashServiceItem`
- [payment_info.dart:PaymentInfo] Class `PaymentInfo`
- [payment_info.dart:PaymentMethod] Enum `PaymentMethod`
- [service_type.dart:ServiceType] Enum `ServiceType`
- [wash_booking.dart:WashBooking] Class `WashBooking`
- [wash_dispatcher.dart:WashDispatcher] Class `WashDispatcher`
- [wash_package.dart:WashPackage] Class `WashPackage`
- [wash_status.dart:WashStatus] Enum `WashStatus`

## Invariants
- [bay_station.dart:immutability] Immutable value contract enforced via const constructors
- [car_wash_service_item.dart:immutability] Immutable value contract enforced via const constructors
- [payment_info.dart:immutability] Immutable value contract enforced via const constructors
- [wash_booking.dart:immutability] Immutable value contract enforced via const constructors
- [wash_package.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- None

## Verification
- Run: `flutter test`
