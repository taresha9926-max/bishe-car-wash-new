# Antigravity Workspace Rules: Automated End-to-End Release Pipeline

Whenever completing any coding task, screen edit, bug fix, or feature enhancement:

1. **Implement the code change**: Strictly minimal, clean, and zero fluff.
2. **Verify with tests**: Run relevant test suites (`flutter test`) to ensure no regressions.
3. **Compile the production release**: Run `flutter build web --release` to keep the production web bundle in `build/web/` fully up-to-date.
4. **Stage and commit**: Run `git add .` and `git commit -m "<descriptive message>"`.
5. **Push directly to GitHub**: Run `git push origin main` so the app is deployed and live immediately without requiring manual user intervention.
