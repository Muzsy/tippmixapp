version: "2025-07-29"
last_updated_by: docs-bot
depends_on: [precommit_checklist_en.md]

# ✅ Pre‑commit ellenőrző lista

> **Cél**
> Meghatározza azokat a kötelező lokális ellenőrzéseket, amelyeket minden fejlesztőnek (és a Codexnek) **push előtt** futtatnia kell. Ugyanezek a lépések futnak a CI‑ben is – ha helyben zöld, a pipeline sem fog meglepni.

---

## 1. Gyors parancs

```bash
./scripts/lint_docs.sh && ./scripts/precommit.sh
```

*Alias*: A Git `prepare-commit-msg` hook már klónozáskor telepíti ezt a parancsot.

---

## 2. Mit csinál a script

| Lépés                     | Eszköz                                    | Hibafeltétel              |
| ------------------------- | ----------------------------------------- | ------------------------- |
| **Dart formázás**         | `dart format --set-exit-if-changed`       | Bármely fájl módosul      |
| **Statikus analízis**     | `flutter analyze --fatal-infos`           | Info szintű vagy súlyosabb hiba |
| **Unit & widget tesztek** | `flutter test --concurrency=4`            | Teszthiba                 |
| **Markdown lint**         | `markdownlint '**/*.md'`                  | Stílushiba                |
| **Fájlnév-szabály**       | Bash regex `^[a-z0-9_]+.(dart|md)$`       | Nem megfelelő fájlnév     |
| **PDF detektálás**        | `git diff --name-only --cached | grep '.pdf$'` | PDF stage-elve       |
| **Commit üzenet lint**    | Conventional Commits – `commitlint`       | Nem megfelelő üzenet      |

### Opcionális lefedettség

Csak igény szerint futtasd, vagy hagyd a `coverage.yml` workflow-ra:

```bash
flutter test --coverage
```

---

## 3. Elfogadott commit üzenet formátum

```
<type>(scope): Főmondat felszólító módban

Törzs (opcionális, 72 karakteres sortöréssel)

BREAKING CHANGE: leírás (ha van)
```

*Példák*: `feat(bets): cash‑out funkció`, `fix(theme): hibás dark szövegszín`.

---

## 4. Kivételek

| Szenárió                               | Megengedett kihagyás                                               |
| -------------------------------------- | ------------------------------------------------------------------ |
| Vészhelyzeti hot‑fix prod crash esetén | `git commit --no‑verify` **egyszer**, majd follow‑up PR tesztekkel |
| Auto‑generált kód (json_serializable)  | Külön `chore:` commit a script futtatása után                      |

Minden kihagyást a CI jelez, és Tech Lead jóváhagyást igényel.

---

## 5. Változásnapló

| Dátum      | Szerző   | Megjegyzés                                             |
| ---------- | -------- | ------------------------------------------------------ |
| 2025-07-29 | docs-bot | Első checklist, a `codex_dry_run_checklist.md` helyett |
