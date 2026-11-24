# UI/UX Simplification & Cognitive Decluttering

* **Author:** Tare
* **Date:** 2026-11-24

## Overview

A systematic redesign of the Bishe Car Wash front-end architecture to eliminate visual clutter, decision fatigue, and competing user actions. The objective is to maximize customer retention, streamline operational task completion for staff (Cashier, Manager), and enforce professional UI/UX standards (progressive disclosure, visual hierarchy, single primary action per viewport) without breaking underlying business rules or station workflows.

## Problem Statement & Observed Friction

1. **Audience Collision**: Customer-facing entrypoints, administrative controls, staff role switchers, and marketing media (reels, maps, feedback) are intermingled on primary entry screens.
2. **Excessive Visual Noise**: Heavy glassmorphism, conflicting high-saturation accent colors, and competing badges draw attention away from the primary user flow.
3. **Choice Paralysis**: The user is presented with multiple simultaneous branching paths (division choice, package choice, bay monitor, video showcase, AI sheet) rather than a linear, goal-oriented workflow.
4. **Information Architecture Density**: Dense forms and modals require manual reading and multi-step cognitive processing rather than obvious, low-friction interactions.

## Analysis

*(Pending Goldfish review and iterative problem drilling)*

## Goals vs. Non-Goals

### In-Scope Goals
* Isolate customer-facing journeys from internal staff/administrative interfaces.
* Implement progressive disclosure: display only the information needed for the current step.
* Establish a disciplined visual hierarchy with one primary action per screen.
* Optimize mobile ergonomic touch targets and thumb zones for quick action.
* Retain full trilingual accessibility across EN, OM, and AM.

### Out-of-Scope Non-Goals
* Altering underlying domain entities, database schemas, or RPCs.
* Removing essential station capabilities (e.g., SMS payment matching, shift handovers, commission calculations).
* Full rewrite of state management or backend integration layer.

## Alternatives Weighed

*(Pending exploration)*

## Key Decisions & Staging for Next Steps

* Clarify target user segmentation: whether to partition Customer experience into a dedicated standalone client flow or keep shared responsive shell.
* Establish primary interaction models for Customer, Cashier, and Manager roles.
