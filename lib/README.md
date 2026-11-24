# Lib

## Overview
Root Flutter Dart application package implementing clean architecture across core foundations and modular business feature domains.

## Interface
### Subdirectories
- [core](./core/README.md): Shared foundational infrastructure providing design tokens, trilingual localization, asynchronous integrations, utility helpers, and base UI widgets.
- [features](./features/README.md): Modular business feature packages organized into clean architecture layers (Domain, Data, Presentation).

### Public Symbols
- [main.dart:BisheCarWashApp] Class `BisheCarWashApp`
- [main.dart:main] Top-level function `main()`

## Invariants
- [main.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- None

## Verification
- Run: `flutter test`
