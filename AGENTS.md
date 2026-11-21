# Antigravity Workspace Rules: Automated End-to-End Release Pipeline

Whenever completing any coding task, screen edit, bug fix, or feature enhancement:

1. **Implement the code change**: Strictly minimal, clean, and zero fluff.
2. **Preservation of Existing Working Logics (Mandatory & Strict - /learn Rule)**: NEVER touch, modify, replace, or alter already working code, features, workflows, screens, or handlers unless explicitly agreed with the user to edit. Always preserve and keep all existing working logics, handlers, workflows, and interactions previously established in screens. If any existing logic needs to be removed, replaced, or altered to accommodate new requirements, explicitly notify the user and obtain confirmation before modifying the code.
3. **Exemplary Scope & Proactive App-Wide Audit (Mandatory)**: Whenever the user cites an example of a bug, cut-off text, broken layout, or UI inconsistency (e.g., "for example in the welcome screen..."), treat it strictly as an illustrative exemplar of an entire systemic pattern, NOT as an isolated single issue. You must proactively search, locate, and resolve every similar instance across all screens, dashboards, and widgets in the entire application without needing separate user prompts for each instance.
4. **Trilingual Localization (Mandatory)**: Always apply complete trilingual translations across English (EN), Afaan Oromoo (OM), and Amharic (AM). Every user-facing UI text, label, button, badge, tooltip, dialog, and notification must be accessed via `state.tr('key')` from `lib/core/localization/app_strings.dart`. Never leave raw English text unlocalized.
5. **Verify with tests**: Run relevant test suites (`flutter test`) to ensure no regressions.
6. **Compile the production release**: Run `flutter build web --release` to keep the production web bundle in `build/web/` fully up-to-date.
7. **Stage and commit**: Run `git add .` and `git commit -m "<descriptive message>"`.
8. **Push directly to GitHub**: Run `git push origin main` so the app is deployed and live immediately without requiring manual user intervention.
9. **Supabase & Network Egress Economics (Mandatory)**: Always maintain strict network data economy across all queries, polling, and data fetching to preserve free-tier quotas and ensure lightning-fast mobile performance:
   - **Never Poll Unbounded Tables**: Background timers (`Timer.periodic`) must NEVER query full tables or run `select=*` on growing collections. Polling must use dedicated, ultra-lightweight status endpoints (e.g. `status=eq.pending&limit=5`) returning minimal payloads (<100 bytes when idle).
   - **In-Memory TTL Caching for Master Data**: Master and rarely-changing tables (such as service packages, tariffs, bay configurations, and staff rosters) must be cached in memory with a sensible TTL (15–30 minutes) and invalidated strictly on explicit administrative writes, rather than re-fetched on every transaction or screen switch.
   - **Query Limits & Pagination**: Historical queries must always enforce explicit limits (e.g. `limit=60`). Historical lookups exceeding the default active window must be strictly on-demand (via an explicit "Load Older Records" button or a user-selected date-range filter), never automatic.
   - **External Asset Hosting**: Large binary media (videos, full-resolution banners, promotional media) must never be streamed through Supabase database egress; host static media in local/CDN assets or external free media services.
10. **Real-World Live Station Operation Mode (Strict & Mandatory - /learn Rule)**:
    - The application is deployed and actively operating in the live car wash station in Bishoftu.
    - **Zero Mock Data Injection**: Never insert fake, mock, or synthetic records into production tables (`wash_bookings`, `daily_closings`, `bank_incoming_transactions`, `commission_logs`, `daily_handovers`, etc.).
    - **Never Delete Records**: Never run delete operations or scripts that truncate, wipe, or destroy live customer bookings, financial closings, or audit records. All records reflect genuine customer services and business revenue.
11. **Day Shift (Cashier) & Night Shift (Operational Manager) Complete Symmetry (Strict - /learn Rule)**:
    - The **Cashier** runs station desk operations during the **Day Shift**, and the **Operational Manager** takes custody and operates during the **Night Shift**.
    - **Symmetric Capability Guarantee**: Any feature, payment handling, receipt flow, OCR scanning, commission rule, queue management, or UI interaction added or updated for the Cashier MUST be identically mirrored, shared, or implemented in the Operational Manager Desk. Never allow feature drift or capability discrepancies between the Day and Night shift desks.
