version: "2025-08-05"
last_updated_by: codex-bot
depends_on: []

# 🚀 GitHub Actions CI/CD Pipeline (EN)

This document describes the CI/CD pipeline setup for TippmixApp using GitHub Actions.

---

## ⚙️ Goals

- Run tests automatically on push/PR
- Ensure documentation quality
- Deploy backend infrastructure and Cloud Functions

---

## 🧩 Structure

Main config files:

```
.github/workflows/main.yaml      # CI for Flutter app
.github/workflows/deploy.yml     # Backend infra + functions
```

Basic steps:

1. Checkout repo
2. Set up Flutter
3. Run `flutter pub get`
4. Run `flutter analyze`
5. Run `flutter test`
6. Run markdown and link checks

---

## 🧪 Quality Gates

- All tests must pass (`flutter test`)
- At least 80% coverage (TODO: add coverage check)
- No broken links in Markdown
- No hardcoded secrets committed (use secret scanning)

---

## 🧰 Recommended Tools

- [`actions/setup-flutter`](https://github.com/marketplace/actions/setup-flutter)
- \[`peaceiris/actions-mdbook`]\(for future doc builds)
- `markdownlint`, `markdown-link-check`

---

## 🚀 Backend deploy workflow

`.github/workflows/deploy.yml` runs on pushes to the `dev` and `main` branches:

1. Set up Node 18 and install `functions/` dependencies.
2. Run lint, unit and e2e tests for Cloud Functions.
3. Initialize and plan Terraform with environment-specific variables.
4. Apply Terraform automatically on `dev` (manual approval for `main`).
5. Deploy the `match_finalizer` Cloud Function with flattened env vars from `env.settings.*`.
6. Send success or failure notifications to Slack.

See [README-ci.md](../../README-ci.md) for required GitHub Secrets.

---

## 🚧 Planned Extensions

- Firebase Test Lab integration (instrumentation)
- Codemagic integration for APK build (optional)
- Deploy Docs to GitHub Pages (via MkDocs)
- Pre-push hook: validate YAML + run lint locally
