# Antigravity Workspace Rules: Automated End-to-End Release Pipeline

Whenever completing any coding task, screen edit, bug fix, or feature enhancement:

1. **Implement the code change**: Strictly minimal, clean, and zero fluff.
2. **Trilingual Localization (Mandatory)**: Always apply complete trilingual translations across English (EN), Afaan Oromoo (OM), and Amharic (AM). Every user-facing UI text, label, button, badge, tooltip, dialog, and notification must be accessed via `state.tr('key')` from `lib/core/localization/app_strings.dart`. Never leave raw English text unlocalized.
3. **Verify with tests**: Run relevant test suites (`flutter test`) to ensure no regressions.
4. **Compile the production release**: Run `flutter build web --release` to keep the production web bundle in `build/web/` fully up-to-date.
5. **Stage and commit**: Run `git add .` and `git commit -m "<descriptive message>"`.
6. **Push directly to GitHub**: Run `git push origin main` so the app is deployed and live immediately without requiring manual user intervention.
