# 🚀 GitHub Actions CI/CD Pipeline (EN)

This document describes the CI/CD pipeline setup for TippmixApp using GitHub Actions.

---

## ⚙️ Goals

* Run tests automatically on push/PR
* Ensure documentation quality
* Prepare for future deployment steps

---

## 🧩 Structure

Main config file:

```
.github/workflows/main.yaml
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

* All tests must pass (`flutter test`)
* At least 80% coverage (TODO: add coverage check)
* No broken links in Markdown
* No hardcoded secrets committed (use secret scanning)

---

## 🧰 Recommended Tools

* [`actions/setup-flutter`](https://github.com/marketplace/actions/setup-flutter)
* \[`peaceiris/actions-mdbook`]\(for future doc builds)
* `markdownlint`, `markdown-link-check`

---

## 🚧 Planned Extensions

* Firebase Test Lab integration (instrumentation)
* Codemagic integration for APK build (optional)
* Deploy Docs to GitHub Pages (via MkDocs)
* Pre-push hook: validate YAML + run lint locally