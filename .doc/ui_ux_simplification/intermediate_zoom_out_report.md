# Stage 8 Audit: Intermediate Zoom-Out & Structural Review

* **Target:** `.doc/ui_ux_simplification/dual_gateway_ui_ux_design.md` (Lines 1–212)
* **Lenses:** `egm-structural`, `egm-zoom-out`
* **Status:** Complete

---

## 1. Dual-Gateway Routing Topology & Seams
* **Gateway Decoupling:** The `/` (Public Customer) and `/staff` (Authenticated Console) split is structurally sound and eliminates customer exposure to internal role selectors in `RoleShellScreen`.
* **Flutter Web URL Strategy:** In Flutter Web, routing defaults to hash-based paths (`/#/` and `/#/staff`). The route dispatcher should support both path-based routing (`usePathUrlStrategy()`) and hash-based fallback so URL direct entries and bookmarks work reliably across all mobile browsers.

## 2. Sandbox Harness Entry Route
* **Isolation Guarantee:** The document specifies creating `prototype_evaluator_screen.dart` in `lib/features/prototypes/presentation/screens/`.
* *Gap:* The document does not define how testers and developers open the prototype evaluator screen during Phase 1 without altering production `lib/main.dart` or `RoleShellScreen`.
* *Recommendation:* Add an isolated route `/prototype` (or `/#/prototype`) or a debug-mode floating switcher in the evaluator harness so that evaluation can occur with 100% zero changes to existing production screens (Rule 2).

## 3. Evaluation of Alternatives
* Alternatives A (Monolithic Tabs), B (Separate Repositories), C (Mandatory Accounts), and D (Deleting Videos) were rigorously evaluated. The author's rejections are fully justified:
  * Alternative B would introduce massive code duplication (violating YAGNI / Ponytail rules).
  * Alternative C would introduce severe booking abandonment on Bishoftu 3G connections.
  * Alternative D would sacrifice the station's future advertising and brand storytelling pipeline.
