# Lib > Features > Booking_Service

## Overview
Core business domain managing wash bookings, bay station assignments, vehicle pricing, and reactive state coordination.

## Subdirectories & Boundaries
- [data](./data/README.md): Data access layer responsible for persisting wash bookings and synchronizing station state.
- [domain](./domain/README.md): Enterprise business entities, aggregates, and repository contracts for car wash operations.
- [presentation](./presentation/README.md): Presentation layer coordinating reactive station state, vehicle queues, and financial summary reporting.
