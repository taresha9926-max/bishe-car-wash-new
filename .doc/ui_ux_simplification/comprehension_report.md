# Stage 6: Comprehension Test Report

**Target:** `.doc/ui_ux_simplification/dual_gateway_ui_ux_design.md`  
**Reviewer:** `egm-comprehension` (Naive Reader Persona)  
**Date:** 2026-11-24  

---

## Paraphrase

### What this proposes
The document proposes restructuring the Bishe Car Wash frontend by separating public customer booking from staff operations into a Dual-Gateway architecture with two distinct entry paths (`/` for consumers and `/staff` for authenticated station personnel). To streamline customer intake, promotional videos and car-care media are relocated out of the booking funnel into a dedicated Station Lounge Hub. Before touching production code, three standalone intake interaction models (a linear stepper wizard, a responsive SaaS dual-card portal, and an express single-card kiosk) will be built and evaluated in an isolated sandbox (`lib/features/prototypes/`) backed by an in-memory mock repository.

### How the existing system works, per this document
According to the document, the current application uses a shared single-page frontend where walk-in customers and station personnel (cashiers, night managers, storekeepers, accountants, and admins) all enter through the same interface. Customers attempting to book a wash are forced through cognitive distractions—including video carousels, Google Maps embeds, feedback triggers, staff PIN prompts, and floating AI concierge sheets—before selecting a service package. In addition, operational screens feature dense multi-column layouts and small tap targets that are difficult for attendants to view and operate under bright Bishoftu sunlight.

---

## Prioritized Audit Findings

### 1. Major: Phase 1 Scope Contradiction (Sandbox Isolation vs. Files Outside Sandbox)
* **Severity**: Major
* **Affected Scope**: Lines 17-18, Line 42, Line 208, Line 215, Lines 249-256.
* **Discrepancy Description & Rationale**: The document asserts that Phase 1 work is strictly isolated to the sandbox with zero production modifications:
  - Line 17: *"Development begins with three isolated interactive prototype interaction models in a sandbox (`lib/features/prototypes/`) with zero modifications to production code until validation."*
  - Line 208: *"All prototype code lives exclusively in `lib/features/prototypes/`. Production files remain 100% untouched until explicit user sign-off."*
  However, Phase 1 Target Files list:
  - Item 8: `lib/features/welcome/presentation/screens/station_lounge_screen.dart` (Create inside production feature directory `welcome/`).
  - Item 9: `lib/core/localization/app_strings.dart` (Modify shared production localization dictionaries).
* **Recommendation**: Clarify that during Phase 1 sandbox prototyping, the Station Lounge preview lives inside the prototype sandbox at `lib/features/prototypes/presentation/screens/prototype_station_lounge_screen.dart`, and define that `AppStrings` modifications are strictly additive translation keys that cannot break existing lookups.

### 2. Major: Prototype File Structure Discrepancy
* **Severity**: Major
* **Affected Scope**: Section 2 (Lines 111-123) vs. Line 245.
* **Discrepancy Description & Rationale**: Section 2 provides a file tree for `lib/features/prototypes/` listing six files, but omits the shared digital ticket component specified in Target Files (item 7, line 245): `prototype_live_ticket_view.dart`.
* **Recommendation**: Add `prototype_live_ticket_view.dart` to the ASCII directory tree in Section 2.

### 3. Major: Unspecified Routing Architecture and Prototype Entry Point
* **Severity**: Major
* **Affected Scope**: Lines 79-89, Lines 229-232, Lines 267-274.
* **Discrepancy Description & Rationale**: The document specifies route paths (`/` and `/staff`), but does not describe the routing mechanism used by the application (declarative `GoRouter` vs. standard Flutter `onGenerateRoute`). Furthermore, it never specifies how a developer or tester launches `prototype_evaluator_screen.dart` during the evaluation phase.
* **Recommendation**: Explicitly state the route mechanics and add a development launcher trigger (e.g., debug floating action button or route `/#/prototypes`) for opening `prototype_evaluator_screen.dart`.

### 4. Major: Undefined UI Anchor for the Discrete Attendant Handoff Gesture
* **Severity**: Major
* **Affected Scope**: Line 50, Line 69, Lines 81-83.
* **Discrepancy Description & Rationale**: Attendants can switch to the staff console by long-pressing the "header station crest", but the document never defines which widget hosts the crest or where the gesture detector binds.
* **Recommendation**: Explicitly define the station crest as the logo asset `AutoCareAssets.logo` rendered within `AppRoleHeader` (`lib/core/widgets/app_role_header.dart`).

### 5. Major: Undefined Project-Specific Symbols & Components
* **Severity**: Major
* **Affected Scope**: Lines 81-82, Line 152, Line 199, Line 227.
* **Discrepancy Description & Rationale**: Several symbols (`StaffAuthenticator`, `RoleAuthDialog`, `IWashRepository`, `AdVideoPlayer`) are referenced without explicit file paths or contracts.
* **Recommendation**: Include exact repository file paths for all referenced symbols:
  - `StaffAuthenticator`: `lib/features/auth_roles/domain/models/staff_authenticator.dart`
  - `RoleAuthDialog`: `lib/features/auth_roles/presentation/widgets/role_auth_dialog.dart`
  - `IWashRepository`: `lib/features/booking_service/domain/repositories/i_wash_repository.dart`
  - `AdVideoShowcaseCard`: `lib/features/welcome/presentation/widgets/ad_video_showcase_card.dart`

### 6. Nit: Undefined Reference to "Rule 10"
* **Severity**: Nit
* **Affected Scope**: Lines 227-228.
* **Discrepancy Description & Rationale**: "Rule 10" is an internal workspace rule in `AGENTS.md`. An external reader has no definition.
* **Recommendation**: State the rule inline: *"Workspace Rule 10: Zero Test/Mock Data Insertion on Live Production Backend"*.

### 7. Nit: Vague Data Contract for Prototype 2 Station Telemetry
* **Severity**: Nit
* **Affected Scope**: Lines 135-138.
* **Discrepancy Description & Rationale**: Prototype 2 requires displaying live station telemetry without specifying if the mock repository provides dynamic streams or static presentation fixtures.
* **Recommendation**: Specify that `MockPrototypeWashRepository` exposes a simulated `StationTelemetrySnapshot` entity.

### 8. Nit: Unenumerated 6-Stage Visual Stepper
* **Severity**: Nit
* **Affected Scope**: Lines 64-65, Line 161.
* **Discrepancy Description & Rationale**: CUJ 2 references a "6-stage visual stepper", but the codebase's `WashStatus` enum has 8 states.
* **Recommendation**: Explicitly list the 6 customer-facing stages: `pending` -> `assignedToBay` -> `washing` -> `drying` -> `readyForPickup` -> `completed`.

### 9. Nit: Unexplained Local Storage 12-Hour Expiration Mechanism
* **Severity**: Nit
* **Affected Scope**: Lines 200-201.
* **Discrepancy Description & Rationale**: The 12-hour expiration for local storage tracking keys lacks an implementation mechanism.
* **Recommendation**: Clarify that the client stores an ISO 8601 timestamp alongside the booking ID in `SharedPreferences` and discards it if `DateTime.now().difference(storedTimestamp).inHours >= 12`.
