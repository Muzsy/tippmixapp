version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[precommit\_checklist\_en.md]

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

| Lépés                     | Eszköz                              | Hibafeltétel                           |                       |
| ------------------------- | ----------------------------------- | -------------------------------------- | --------------------- |
| **Dart formázás**         | `dart format --set-exit-if-changed` | Bármely fájl módosul                   |                       |
| **Statikus analízis**     | `flutter analyze --fatal-infos`     | Info szintű vagy súlyosabb hiba        |                       |
| **Unit & widget tesztek** | `flutter test --coverage`           | Teszt hiba vagy lefedettség < **80 %** |                       |
| **Markdown lint**         | `markdownlint '**/*.md'`            | Stílushiba                             |                       |
| **Fájlnév‑szabály**       | Bash regex \`^\[a-z0-9\_]+.(dart    | md)$\`                                 | Nem megfelelő fájlnév |
| **PDF detektálás**        | \`git diff --name-only --cached     | grep '.pdf\$'\`                        | PDF stage‑elve        |
| **Commit üzenet lint**    | Conventional Commits – `commitlint` | Nem megfelelő üzenet                   |                       |

> *Tipp*: `./scripts/precommit.sh --fix` automatikusan javítja a formázást és az import‑rendezést.

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
| Auto‑generált kód (json\_serializable) | Külön `chore:` commit a script futtatása után                      |

Minden kihagyást a CI jelez, és Tech Lead jóváhagyást igényel.

---

## 5. Változásnapló

| Dátum      | Szerző   | Megjegyzés                                             |
| ---------- | -------- | ------------------------------------------------------ |
| 2025-07-29 | docs-bot | Első checklist, a `codex_dry_run_checklist.md` helyett |
