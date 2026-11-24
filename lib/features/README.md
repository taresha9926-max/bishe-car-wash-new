# Lib > Features

## Overview
Modular business feature packages organized into clean architecture layers (Domain, Data, Presentation).

## Subdirectories & Boundaries
- [admin](./admin/README.md): Administrative control panel for station revenue tracking, price matrix adjustments, staff salary/commission management, and audit logs.
- [auth_roles](./auth_roles/README.md): Role routing, multi-persona navigation, and secure staff PIN authentication for Cashier, Admin, Operational Manager, and Storekeeper roles.
- [booking_service](./booking_service/README.md): Core business domain managing wash bookings, bay station assignments, vehicle pricing, and reactive state coordination.
- [cashier](./cashier/README.md): Cashier and gate operational desk feature for vehicle check-in, bay assignment, payment processing, and shift handovers.
- [customer](./customer/README.md): Customer self-service booking portal, pricing estimator, and live 6-stage wash tracking interface.
- [inventory](./inventory/README.md): Warehouse inventory management, chemical container tracking, fixed asset maintenance, and storekeeper shift handovers.
- [manager](./manager/README.md): Operational management desk providing full operational symmetry with the Cashier desk during night shifts and supervisory oversight.
- [welcome](./welcome/README.md): Entrance splash portal, customer welcome screen, TikTok marketing video showcase, and customer feedback collection.
