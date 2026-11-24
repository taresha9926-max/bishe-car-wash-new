# Lib > Features > Booking_Service > Data

## Overview
Data access layer responsible for persisting wash bookings and synchronizing station state.

## Subdirectories & Boundaries
- [datasources](./datasources/README.md): Data sources providing seed models and fallback fixtures for local development and station operations.
- [repositories](./repositories/README.md): Concrete repository implementations interfacing with Supabase REST endpoints and local state fallbacks.
