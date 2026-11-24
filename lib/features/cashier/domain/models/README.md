# Lib > Features > Cashier > Domain > Models

## Overview
Domain entities representing incoming bank SMS transactions, PayGuard sentinel configurations, and shower records.

## Interface
- [bank_incoming_transaction.dart:BankIncomingTransaction] Class `BankIncomingTransaction`
- [sentinel_config.dart:SentinelConfig] Class `SentinelConfig`
- [shower_record.dart:ShowerRecord] Class `ShowerRecord`

## Invariants
- [bank_incoming_transaction.dart:immutability] Immutable value contract enforced via const constructors
- [sentinel_config.dart:immutability] Immutable value contract enforced via const constructors
- [shower_record.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- None

## Verification
- Run: `flutter test`
