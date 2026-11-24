# Lib > Features > Booking_Service > Data > Repositories

## Overview
Concrete repository implementations interfacing with Supabase REST endpoints and local state fallbacks.

## Interface
- [supabase_wash_repository_impl.dart:SupabaseWashRepositoryImpl] Class `SupabaseWashRepositoryImpl`
- [wash_repository_impl.dart:WashRepositoryImpl] Class `WashRepositoryImpl`

## Invariants
- [supabase_wash_repository_impl.dart:immutability] Immutable value contract enforced via const constructors
- [wash_repository_impl.dart:immutability] Immutable value contract enforced via const constructors

## Side Effects
- [supabase_wash_repository_impl.dart:http] Network I/O: Dispatches asynchronous HTTP network requests via `package:http`

## Verification
- Run: `flutter test`
