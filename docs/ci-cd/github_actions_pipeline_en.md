version: "2025-10-05"
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

`.github/workflows/deploy.yml` runs on pushes to the `dev` and `main` branches or via manual `workflow_dispatch`:

1. Determine deploy `MODE` from branch (`main` → `prod`, others → `dev`) or `workflow_dispatch` `target`, writing the result to `$GITHUB_ENV`.
2. Set up Node 20 with npm cache.
3. Install `firebase-tools@^13`.
4. Remove stale `cloud_functions/lib` artifacts.
5. Install dependencies and build functions with `npm ci --prefix cloud_functions` and `npm run build --prefix cloud_functions`.
6. Deploy Firestore rules from the root `firebase.rules`.
7. Deploy Cloud Functions with explicit project selection (secrets via Secret Manager; no `.env` or runtime config).
8. Execute a Terraform no-op plan (`terraform init -backend=false && terraform validate && terraform plan`).

See [README-ci.md](../../README-ci.md) for required GitHub Secrets.

---

## 🚧 Planned Extensions

- Firebase Test Lab integration (instrumentation)
- Codemagic integration for APK build (optional)
- Deploy Docs to GitHub Pages (via MkDocs)
- Pre-push hook: validate YAML + run lint locally
