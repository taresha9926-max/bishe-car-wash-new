# Lib > Core > Services

## Overview
Shared background and asynchronous services for AI executive assistance and bank receipt image OCR scanning.

## Interface
- [bishe_ai_executive_service.dart:StationWatchdogAlert] Class `StationWatchdogAlert`
- [bishe_ai_executive_service.dart:CustomerLoyaltyInfo] Class `CustomerLoyaltyInfo`
- [bishe_ai_executive_service.dart:BisheAiExecutiveService] Class `BisheAiExecutiveService`
- [bishe_ai_executive_service.dart:WatchdogSeverity] Enum `WatchdogSeverity`
- [bishe_ai_executive_service.dart:WatchdogCategory] Enum `WatchdogCategory`
- [receipt_ocr_service.dart:ReceiptOcrService] Class `ReceiptOcrService`
- [umami_analytics.dart:UmamiAnalytics] Class `UmamiAnalytics`

## Invariants
- [bishe_ai_executive_service.dart:immutability] Immutable value contract enforced via const constructors
- [receipt_ocr_service.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [receipt_ocr_service.dart:http] Network I/O: Dispatches asynchronous HTTP network requests via `package:http`

## Verification
- Run: `flutter test`
