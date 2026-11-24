# UI/UX Simplification & Cognitive Decluttering

* **Author:** Tare
* **Date:** 2026-11-24

## Overview

A structural overhaul of the Bishe Car Wash front-end architecture to eliminate visual clutter, cognitive friction, and competing persona flows. The design splits the application into two strictly decoupled gateways:
1. **Public Customer Portal**: A clean, single-purpose consumer interface dedicated exclusively to service booking, pricing transparency, and live wash status tracking. All marketing reels, promotional carousels, and extraneous floating widgets are removed from the primary path.
2. **Staff Operations Portal**: An authenticated, high-density operations console dedicated to Cashiers, Operational Managers, Storekeepers, Accountants, and Administrators, accessible via a secure gateway isolated from end customers.

Development will proceed through three distinct interactive design prototypes before any changes are introduced to the production frontend.

## Problem Statement & Root Constraints

1. **Audience Collision Resolved via Two Gateways**: Eliminates the intermingling of customer booking flows with internal operational tooling.
2. **Elimination of Marketing Noise**: Video reels, promotional carousels, floating AI sheets, and feedback prompts are stripped from the booking funnel to reduce cognitive load.
3. **Ergonomic Progressive Disclosure**: Replacing dense multi-option forms with progressive, linear decision steps.
4. **Zero Production Mutation During Ideation**: All exploratory designs will be developed as distinct prototype artifacts before touching the live production application.

## Goals vs. Non-Goals

### In-Scope Goals
* Two independent entry gateways: Public Customer Portal vs. Authenticated Staff Portal.
* Minimal customer flow: Vehicle selection -> Service selection -> Booking confirmation -> Live status.
* Minimal staff flow: Fast vehicle intake -> Bay status dispatch -> Payment verification (Telebirr/CBE SMS) -> Handover closing.
* Three distinct UX prototype models representing alternative interaction paradigms for user testing.
* Preservation of complete trilingual localization (EN, OM, AM) and backend contracts.

### Out-of-Scope Non-Goals
* Modification of production source code or screens during the brainstorming and prototyping phase.
* Altering Supabase schemas, RPCs, or live station data contracts.
* Deprecating core station capabilities (SMS matching, commission auditing, shift handovers).

## Candidate Prototype Directions

* **Prototype 1: Linear Consumer Funnel (App-Style)**
  * Single-column, 3-step progressive stepper (Vehicle -> Package -> Summary).
  * Direct call to action, zero secondary distractions, persistent bottom status bar.
* **Prototype 2: Modern Web Portal (Clean SaaS-Style)**
  * Clear visual hierarchy with dual-card layout: Live Bay Availability & Quick Book form.
  * Direct pricing calculator with clear vehicle category toggles.
* **Prototype 3: Express Kiosk / Speed Intake (Low-Friction)**
  * Ultra-compact single-screen form optimized for sub-15-second completion.
  * Direct license plate input, auto-suggested vehicle category, instant submit.

## Key Decisions & Staging for Next Steps

* Staff gateway discovery mechanism (subtle footer link, discrete key combo, or `/staff` URL route).
* Customer live tracking presentation (persistent bottom sheet vs dedicated tracking tab).
* Execution of multi-lens Goldfish review on the decoupled gateway hypothesis.
