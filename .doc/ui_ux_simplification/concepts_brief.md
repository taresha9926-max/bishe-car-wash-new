# UI/UX Simplification & Cognitive Decluttering: Dual-Gateway Concept Brief

* **Feature Concept:** Decouple the frontend into two dedicated gateways (Distraction-Free Public Customer Portal & Secure Staff Operations Console), relocate marketing video assets into a dedicated "Station Lounge & Ad Hub", keep live wash tracking focused on status telemetry, preserve all station backend contracts, and deliver three distinct prototype interaction models in an isolated sandbox before touching production code.
* **Author:** Tare (compiled via 7-lens Goldfish swarm synthesis)
* **Date:** 2026-11-24
* **Target Subsystem:** Bishe Car Wash Frontend Architecture (`lib/features/`, `lib/core/`)

---

## Overview

The Bishe Car Wash front-end architecture currently hosts competing user personas, operational tooling, and promotional assets within a single shared navigation surface. Customers entering the application encounter video reels, promotional carousels, floating AI concierge triggers, and visible administrative role selectors on desktop navigation rails.

This initiative executes a structural decoupling of the application into two dedicated gateways:
1. **Public Customer Portal (`/` or Default Gateway):** A distraction-free, single-purpose consumer interface dedicated exclusively to vehicle intake, transparent package pricing, booking submission, and live wash status tracking. All marketing video reels, promotional carousels, floating sheets, and internal role selectors are removed from the booking intake funnel.
2. **Staff Operations Console (`/staff` or Authenticated Desk Gateway):** A high-density, secure operational suite dedicated to Cashiers (Day Shift), Operational Managers (Night Shift), Storekeepers, Accountants, and Administrators, guarded by PIN/credential authentication.

### Strategic Relocation of Marketing & Advertising Assets
* **Station Lounge & Ad Hub Architecture:** Promotional video reels and marketing carousels are not deprecated or discarded. Instead, they are relocated into a dedicated "Station Lounge" destination. This serves two functions:
  1. *Immediate:* Customer brand engagement and entertainment outside the intake bottleneck.
  2. *Long-Term Pipeline:* An extensible advertising platform ready to host first-party promotional campaigns, partner ads, and car-care video reels as the company accumulates its own media library.
* **Focused Live Tracking Integrity:** The core Live Tracking screen remains focused on vehicle wash status telemetry (queue stage, assigned bay, washer staff, inspection readiness) without being crowded by promotional overlays.

### Core Safeguards Maintained
* **Zero Production Mutation During Ideation:** Exploration is restricted entirely to standalone prototype artifacts; no live production code or customer-facing screens are altered until a prototype is verified.
* **Hermetic Backend & Data Protection:** All live Supabase tables (`wash_bookings`, `daily_closings`, `commission_logs`, `bank_incoming_transactions`, `daily_handovers`) remain undisturbed. Zero mock data insertion, zero destructive deletions, and hermetic unit tests.
* **Day/Night Shift Complete Symmetry:** All cashier intake, SMS matching, commission logging, and handover capabilities remain 100% mirrored in the Operational Manager Desk.
* **Trilingual Completeness:** All customer and staff touchpoints maintain strict EN, OM, and AM translations via `state.tr('key')`.

---

## Multi-Lens Swarm Analysis

### 1. Design Critic (`egm-design`) — UX, Ergonomics & Cognitive Load
* **Intake Funnel Decompression:** Stripping promotional banners and extraneous widgets from the intake flow eliminates visual clutter by over 60%, allowing customers to book in under 30 seconds.
* **Progressive Disclosure:** Booking decisions follow a single linear path: *Vehicle Category -> Package Tier -> Contact Details -> Confirmation*. Secondary decisions (add-ons, fragrances, engine wash) become inline expansions rather than competing modal popups.
* **Outdoor Usability & Contrast:** At the Bishoftu station, devices operate under direct outdoor sunlight. Touch targets must exceed 48x48dp, contrast ratios must meet WCAG 2.1 AA (minimum 4.5:1 for body text, 7:1 for headings on dark backgrounds `0xFF0F172A`), and primary CTA buttons must span full width on viewports under 600px.
* **Localization Spacing:** Afaan Oromoo and Amharic strings expand label widths by 15%–30% compared to English. Button layouts must use flexible auto-wrapping or vertical stacking rather than fixed-width row containers to prevent text clipping.

### 2. Codebase Details (`egm-codebase-details`) — Internal Contracts & State
* **Seam Identification:** The monolithic switcher in `lib/features/auth_roles/presentation/screens/role_shell_screen.dart` currently mounts both `CustomerHomeScreen` and staff dashboards inside a single navigation rail where `UserRole.values` are exposed.
* **Contract Preservation:** The decoupled customer portal must communicate strictly through `SupabaseWashRepositoryImpl` utilizing existing entities (`WashBooking`, `ServiceType`, `WashDispatcher`, `WashStatus`).
* **Day/Night Desk Symmetry:** Refactoring the public gateway must not alter the shared state logic between Cashier (day) and Operational Manager (night). Both shifts rely on identical methods in `AppStateNotifier` (`assignBay`, `updateBookingStatus`, `reconcileIncomingTransaction`, `submitDailyHandover`).
* **Egress Economics:** Customer live tracking must never run unbounded polling queries. It must poll single-record status endpoints (`id=eq.<bookingId>&select=id,status,bay_number,updated_at`) with a minimum 10-second polling interval and exponential backoff when idle.

### 3. Strategic Ecosystem (`egm-zoom-out`) — Bishoftu Station Reality
* **Customer Demographics:** Users in Bishoftu range from ride-hail / taxi drivers requiring rapid, repeatable booking, to private vehicle owners seeking detailing packages, to commercial fleet drivers. The public portal must accommodate low-bandwidth 3G mobile connections.
* **Commercial Advertising Scalability:** Elevating promotional media into a modular "Station Lounge" hub ensures the app is primed for commercial video ads and service highlights as station media production expands.
* **Shared Station Devices:** Station tablets placed at reception must require an explicit, secure PIN check (`RoleAuthDialog`) with a 60-second idle auto-lock to prevent walk-in customers from accessing staff consoles.

### 4. Comprehension & Mental Model (`egm-comprehension`) — Frictionless Flow
* **Customer Mental Model:** "Select car type, see exact fixed price, submit phone number, receive assigned bay."
* **Elimination of Account Wall:** Forcing account creation or passwords creates high drop-off. The system uses **Ephemeral Identity**: License Plate + Phone Number. Returning customers are recognized via local storage tokens without a password barrier.
* **Staff Mental Model:** "Intake in 10 seconds, assign bay, verify Telebirr/CBE payment against incoming SMS, print/show receipt, log commission." Staff must never see consumer onboarding tutorials or promotional carousels.

### 5. Implementation Readiness (`egm-implementation-readiness`) — Zero-Mutation Sandbox
* **Zero Production Mutation:** To strictly uphold preservation rules, all three prototype interaction models will be created inside a dedicated prototype sandbox (`lib/features/prototypes/`) completely decoupled from `lib/main.dart` and `RoleShellScreen`.
* **Hermetic Test Harness:** Prototype interaction models will use an in-memory mock repository (`MockWashRepository`) implementing the `IWashRepository` interface. Zero live Supabase network calls during prototype evaluation.

### 6. Structural Architecture (`egm-structural`) — Gateway Decoupling
* **Dual Gateway Topology:**
  ```
                        ┌─────────────────────────────────┐
                        │       BisheCarWashApp           │
                        │    (lib/main.dart entry)        │
                        └────────────────┬────────────────┘
                                         │
                 ┌───────────────────────┴────────────────────────┐
                 ▼                                                ▼
     ┌───────────────────────┐                        ┌───────────────────────┐
     │ PublicCustomerGateway │                        │ StaffOperationsGateway│
     │      (Route: `/`)     │                        │   (Route: `/staff`)   │
     └───────────┬───────────┘                        └───────────┬───────────┘
                 │                                                │
         Distraction-Free                                 PIN Authentication
         Customer Intake &                                (Cashier, Manager,
         Live Status Tracking                             Storekeeper, Admin)
                 │
                 ▼
     ┌───────────────────────┐
     │ Station Lounge Hub    │
     │ (Ad & Video Showcase) │
     └───────────────────────┘
  ```
* **Decoupled State Scopes:** Customer flow requires only lightweight booking state (`currentVehicleCategory`, `selectedPackage`, `customerPhone`, `licensePlate`). Internal shift metrics, commission logs, bank transactions, and inventory levels are isolated within the Staff Gateway scope, eliminating memory overhead and security exposure.

### 7. Inventive Catalyst (`egm-inventive-catalyst`) — TRIZ Contradiction Resolutions
* **Contradiction 1: Marketing Storytelling vs. Intake Speed**
  * *Contradiction:* Marketing requires video reels and promotional visibility; conversion ergonomics demand zero clutter and minimal clicks.
  * *Resolution (TRIZ Principle 1 - Segmentation & Principle 3 - Local Quality):* Relocate all media into a standalone **Station Lounge Hub**. Intake remains 100% focused on booking speed (<20 seconds), while video ads and service highlights exist in their own dedicated space for user exploration.
* **Contradiction 2: Staff Device Accessibility vs. Customer Tamper Resistance**
  * *Contradiction:* Staff must quickly open their console on any device without complex URLs; customers using station tablets must not stumble into staff dashboards.
  * *Resolution (TRIZ Principle 10 - Prior Action & Principle 13 - The Other Way Round):* Dual-mode gateway access: Dedicated direct route (`/staff`) for bookmarks, plus a discreet, non-discoverable gesture on the public portal (e.g., subtle long-press on the station crest + 4-digit PIN challenge).
* **Contradiction 3: No-Account Simplicity vs. Continuous Vehicle Tracking**
  * *Contradiction:* Customers reject usernames/passwords, but tracking requires returning to their specific vehicle's progress across browser sessions.
  * *Resolution (TRIZ Principle 24 - Intermediary):* License Plate + Phone Number as an ephemeral tracking key stored in `shared_preferences` / browser `localStorage`. When reopening the app within 12 hours, the public portal displays a "Track Active Wash: [Plate #]" banner automatically.

---

## Candidate Prototype Interaction Models

### Prototype 1: Linear Consumer Funnel (App-Style Stepper)
* **Design Philosophy:** Minimalist, focused, step-by-step mobile wizard inspired by leading transport applications.
* **Interaction Paradigm:** A vertical 3-step progressive stepper with persistent back/forward navigation:
  1. *Step 1: Choose Vehicle & Service Type* (Sedan, SUV, Truck, Carpet — large tactile cards).
  2. *Step 2: Package Tier Selection* (Regular Wash, Special Wash, Under-Wash, Detailing — fixed prices clearly displayed in ETB).
  3. *Step 3: Quick Identification & Submission* (License plate input, mobile phone number, instant "Confirm & Drive In" CTA).
* **Live Status Treatment:** Slips into a full-height live progress card with an animated wash-stage indicator (Queued -> In Bay -> Washing -> Drying -> Ready for Inspection).
* **Trade-offs:** Lowest cognitive load for first-time users; foolproof on small mobile screens. Requires 3 sequential taps before reaching final submission.

### Prototype 2: Modern Web Portal (Clean SaaS Dual-Card)
* **Design Philosophy:** Responsive desktop/tablet dashboard with high transparency, inspired by modern logistics portals.
* **Interaction Paradigm:** A clean, dual-card single-view interface:
  * *Left Card (Station Pulse):* Live Bay Availability overview ("Bay 1: Available", "Bay 2: Occupied - 8 mins remaining", "Current Queue: 2 cars").
  * *Right Card (Express Booking):* Compact booking form with vehicle category toggle buttons, package tier dropdown, instant dynamic price calculator, and phone/plate input.
* **Live Status Treatment:** Persistent bottom tracking bar that expands on tap into a detailed modal with real-time bay telemetry.
* **Trade-offs:** Ideal for desktop/tablet customers and reception kiosks; provides immediate reassurance regarding wait times. Denser visual layout on small mobile displays (<380px width) requiring adaptive column stacking.

### Prototype 3: Express Kiosk / Speed Intake (Single-Screen Form)
* **Design Philosophy:** High-velocity intake designed for sub-15-second completion by repeat drivers, taxis, and busy commercial operators.
* **Interaction Paradigm:** A single unified card with zero page transitions:
  * Top: 4 vehicle icon pills (Sedan / SUV / Minibus / Commercial).
  * Middle: Segmented package selector with auto-updated price pill.
  * Bottom: Dual input fields (Plate Number, Phone Number) + large full-width "Instant Book" button.
* **Live Status Treatment:** Immediately replaces the form with a high-contrast digital ticket showing: QR / Booking Reference, Assigned Bay, and Wash Status badge.
* **Trade-offs:** Fastest possible booking time (sub-15 seconds); zero navigation overhead; ultra-resilient on slow network connections. Minimal space for service tier explanations or add-on descriptions.

---

## Goals vs. Non-Goals

### In-Scope Goals
* Two independent entry gateways: Public Customer Portal (`/`) vs. Authenticated Staff Portal (`/staff`).
* Minimal customer flow: Vehicle selection -> Service selection -> Booking confirmation -> Live status.
* Standalone Station Lounge Hub for video advertising and company promotional media.
* Minimal staff flow: Fast vehicle intake -> Bay status dispatch -> Payment verification (Telebirr/CBE SMS) -> Handover closing.
* Three distinct UX prototype models built in an isolated sandbox (`lib/features/prototypes/`) representing alternative interaction paradigms for user testing.
* Preservation of complete trilingual localization (EN, OM, AM) and backend contracts.

### Out-of-Scope Non-Goals
* Direct modification of production source code or screens during the prototyping phase.
* Altering Supabase schemas, RPCs, or live station data contracts.
* Deprecating core station capabilities (SMS matching, commission auditing, shift handovers).

---

## Alternatives Weighed

* **Alternative 1: Retain Unified Screen with Role Tabs (Rejected by Author & Reviewers):** Attempting to keep customer, cashier, and manager views in one screen with role tabs maintains the cognitive collision and risks customers altering station settings or getting confused by staff terminology.
* **Alternative 2: Native App Store App for Staff + Web for Customers (Rejected as YAGNI):** Maintaining two separate build pipelines and repositories would drastically increase maintenance overhead. A single Flutter codebase with route-based gateway separation achieves the exact same security and UX isolation with zero code fragmentation.
* **Alternative 3: Traditional User Registration (Email/Password) (Rejected for High Friction):** Walk-in drivers in Bishoftu will abandon the booking flow if forced to create an account. Ephemeral identification (Phone + Plate) eliminates friction while preserving booking integrity.

---

## Key Decisions & Staging for Next Steps

1. Build all 3 candidate prototype models inside a dedicated, isolated sandbox (`lib/features/prototypes/`) using a hermetic in-memory mock repository.
2. Conduct side-by-side ergonomic evaluation on mobile (360px-420px) and tablet/desktop (800px-1200px) viewports before modifying any production code.
3. Upon approval of the winning prototype, perform a clean surgical cutover to establish the dual-gateway routing architecture.
