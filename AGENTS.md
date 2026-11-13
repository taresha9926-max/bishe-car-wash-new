# Antigravity Workspace Rules: Automated End-to-End Release Pipeline

Whenever completing any coding task, screen edit, bug fix, or feature enhancement:

1. **Implement the code change**: Strictly minimal, clean, and zero fluff.
2. **Preservation of Existing Working Logics (Mandatory)**: Always preserve and keep all existing working logics, handlers, workflows, and interactions previously established in screens, unless the user explicitly requested their removal or replacement. If any existing logic needs to be removed, replaced, or altered to accommodate new requirements, explicitly notify the user and obtain confirmation before modifying the code.
3. **Exemplary Scope & Proactive App-Wide Audit (Mandatory)**: Whenever the user cites an example of a bug, cut-off text, broken layout, or UI inconsistency (e.g., "for example in the welcome screen..."), treat it strictly as an illustrative exemplar of an entire systemic pattern, NOT as an isolated single issue. You must proactively search, locate, and resolve every similar instance across all screens, dashboards, and widgets in the entire application without needing separate user prompts for each instance.
4. **Trilingual Localization (Mandatory)**: Always apply complete trilingual translations across English (EN), Afaan Oromoo (OM), and Amharic (AM). Every user-facing UI text, label, button, badge, tooltip, dialog, and notification must be accessed via `state.tr('key')` from `lib/core/localization/app_strings.dart`. Never leave raw English text unlocalized.
5. **Verify with tests**: Run relevant test suites (`flutter test`) to ensure no regressions.
6. **Compile the production release**: Run `flutter build web --release` to keep the production web bundle in `build/web/` fully up-to-date.
7. **Stage and commit**: Run `git add .` and `git commit -m "<descriptive message>"`.
8. **Push directly to GitHub**: Run `git push origin main` so the app is deployed and live immediately without requiring manual user intervention.
