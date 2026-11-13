# Antigravity Workspace Rules: Automated End-to-End Release Pipeline

Whenever completing any coding task, screen edit, bug fix, or feature enhancement:

1. **Implement the code change**: Strictly minimal, clean, and zero fluff.
2. **Preservation of Existing Working Logics (Mandatory)**: Always preserve and keep all existing working logics, handlers, workflows, and interactions previously established in screens, unless the user explicitly requested their removal or replacement. If any existing logic needs to be removed, replaced, or altered to accommodate new requirements, explicitly notify the user and obtain confirmation before modifying the code.
3. **Trilingual Localization (Mandatory)**: Always apply complete trilingual translations across English (EN), Afaan Oromoo (OM), and Amharic (AM). Every user-facing UI text, label, button, badge, tooltip, dialog, and notification must be accessed via `state.tr('key')` from `lib/core/localization/app_strings.dart`. Never leave raw English text unlocalized.
4. **Verify with tests**: Run relevant test suites (`flutter test`) to ensure no regressions.
5. **Compile the production release**: Run `flutter build web --release` to keep the production web bundle in `build/web/` fully up-to-date.
6. **Stage and commit**: Run `git add .` and `git commit -m "<descriptive message>"`.
7. **Push directly to GitHub**: Run `git push origin main` so the app is deployed and live immediately without requiring manual user intervention.
