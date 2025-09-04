version: "2025-07-29"
last_updated_by: docs-bot
depends_on: []

# ✅ Pre‑commit Checklist

> **Purpose**
> Define the mandatory local checks every developer (and Codex) must run **before pushing** code to the TippmixApp repository. The same steps run in CI—passing locally means zero surprises in the pipeline.

---

## 1. Quick command

```bash
./scripts/lint_docs.sh && ./scripts/precommit.sh
```

*Alias*: A Git `prepare-commit-msg` hook installs this command on first `git clone`.

---

## 2. What the script does

| Step                    | Tool                                     | Fail condition                |
| ----------------------- | ---------------------------------------- | ----------------------------- |
| **Format Dart**         | `dart format --set-exit-if-changed`      | Any file changed              |
| **Static analysis**     | `flutter analyze --fatal-infos`          | Issue ≥ info level            |
| **Unit & widget tests** | `flutter test --concurrency=4`           | Any test fails                |
| **Markdown lint**       | `markdownlint '**/*.md'`                 | Style error                   |
| **Filename policy**     | custom Bash regex `^[a-z0-9_]+.(dart|md)$`| Any file not matching         |
| **PDF detector**        | `git diff --name-only --cached | grep '.pdf$'` | Any PDF staged          |
| **Commit message lint** | Conventional Commits via `commitlint`    | Message not conforming        |

### Optional coverage

Run only when explicitly needed or rely on `coverage.yml`:

```bash
flutter test --coverage
```

---

## 3. Acceptable commit message format

```
<type>(scope): Subject in imperative mood

Body (optional, wrap at 72 chars)

BREAKING CHANGE: description (if any)
```

*Examples*: `feat(bets): add cash‑out feature`, `fix(theme): wrong dark text colour`.

---

## 4. Exemptions

| Scenario                                 | Allowed bypass                                                       |
| ---------------------------------------- | -------------------------------------------------------------------- |
| Emergency hot‑fix for prod crash         | `git commit --no‑verify` **once**, then open follow‑up PR with tests |
| Auto‑generated code (json_serializable)  | Commit as separate `chore:` after running script                     |

All bypasses are flagged in CI and require Tech Lead approval.

---

## 5. Changelog

| Date       | Author   | Notes                                                    |
| ---------- | -------- | -------------------------------------------------------- |
| 2025-07-29 | docs-bot | Initial checklist replacing `codex_dry_run_checklist.md` |
