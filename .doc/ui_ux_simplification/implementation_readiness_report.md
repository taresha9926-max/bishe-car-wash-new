# Stage 9 Audit: Implementation Readiness & Codebase Details Review

* **Target:** `.doc/ui_ux_simplification/dual_gateway_ui_ux_design.md` (Lines 213–305)
* **Lenses:** `egm-implementation-readiness`, `egm-codebase-details`
* **Status:** Complete

---

## 1. Workspace Rules Compliance Audit
* **Rule 2 (Preservation of Existing Working Logics):** Fully compliant. Phase 1 is 100% sandboxed in `lib/features/prototypes/`. No production screens are modified.
* **Rule 4 (Trilingual Localization):** Fully compliant. Target File 9 explicitly updates `lib/core/localization/app_strings.dart` with EN, OM, AM keys for all prototype strings.
* **Rule 9 (Supabase & Network Egress Economics):** Compliant. Prototype evaluation uses an in-memory repository with zero network calls. For live tracking, bounded single-record polling (<100 bytes) is specified.
  * *Enhancement:* Specify that polling timers must be canceled immediately upon status reaching `completed` or `picked_up`, or when the browser tab is backgrounded.
* **Rule 10 (Live Station Operation & Zero Test Data):** Fully compliant. `MockPrototypeWashRepository` operates strictly in memory. Zero test bookings are inserted into live Supabase tables (`wash_bookings`, etc.).
* **Rule 11 (Day/Night Shift Complete Symmetry):** Fully preserved. The design explicitly preserves shared state dispatches across Cashier (Day) and Manager (Night) desks.

## 2. Interface Contract Optimization (`IWashRepository`)
* Line 227 states that `MockPrototypeWashRepository` "Implements `IWashRepository` in-memory".
* *Analysis:* `IWashRepository` in `lib/features/booking_service/domain/repositories/i_wash_repository.dart` is a composite interface of over 30 domain methods spanning bookings, inventory, staff, digital payments, and commissions.
* *Codebase Leverage (Ponytail Rule):* `WashRepositoryImpl` in `lib/features/booking_service/data/repositories/wash_repository_impl.dart` is ALREADY an in-memory repository implementing `IWashRepository` with default seeded collections.
* *Recommendation:* `MockPrototypeWashRepository` should simply extend `WashRepositoryImpl` and override only the specific prototype booking and tracking methods needed for the sandbox. This prevents writing hundreds of lines of redundant mock implementations.

## 3. Verification Plan Feasibility
* Verification commands (`flutter test test/prototypes/prototype_models_test.dart`, `dart analyze lib/features/prototypes/`, `flutter build web --release`) are hermetic, testable, and adhere to project standards.
