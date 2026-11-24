# Lib > Features > Inventory > Domain > Models

## Overview
Models representing consumable inventory items, daily shift handovers, fixed assets, and stock ledger transactions.

## Interface
- [consumable_item.dart:ConsumableItem] Class `ConsumableItem`
- [daily_handover.dart:DailyHandover] Class `DailyHandover`
- [daily_handover.dart:HandoverStatus] Enum `HandoverStatus`
- [fixed_asset.dart:FixedAsset] Class `FixedAsset`
- [fixed_asset.dart:AssetCondition] Enum `AssetCondition`
- [stock_transaction.dart:StockTransaction] Class `StockTransaction`

## Invariants
- [consumable_item.dart:immutability] Immutable value contract enforced via const constructors
- [daily_handover.dart:immutability] Immutable value contract enforced via const constructors
- [fixed_asset.dart:immutability] Immutable value contract enforced via const constructors
- [stock_transaction.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- None

## Verification
- Run: `flutter test`
