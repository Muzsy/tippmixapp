version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[codex\_context.yaml, routing\_integrity\_en.md]

# 🛰️ Routing Integritási Irányelvek

> **Cél**
> Kötelező `GoRouter` minták és bevált gyakorlatok meghatározása a kiszámítható, tesztelhető és deep‑link‑barát navigáció érdekében.

---

## Alaparchitektúra

Az alkalmazás **ShellRoute + beágyazott útvonalak** modellt használ, így az alsó navigációs sáv állandó, miközben minden fül saját navigációs veremmel rendelkezik.

```mermaid
graph LR
  shell(ShellRoute)
  shell --> home[/home]
  shell --> bets[/bets]
  shell --> profile[/profile]
  bets --> betDetail[/bets/:ticketId]
```

---

## Kötelező szabályok

1. **Útvonal‑konstansok központi helyen** – Minden útvonalat a `lib/src/routing/app_route.dart` fájlban deklarálj; ne legyen hard‑coded string a widgetekben.
2. **Csak névvel ellátott route** – Minden útvonal kapjon `name` mezőt, amely megfelel az `AppRoute` enum elemének.
3. **Auth guard** – A privát stackeket `AuthRedirect()` védi; anonim felhasználó `/sign‑in`‑re irányítódik.
4. **Paraméter‑validálás** – Hibás vagy hiányzó paraméterű deep‑linket utasítsuk el (`typed_params`).
5. **Ne használj wildcard route‑ot** (`*`) – Helyette külön 404 útvonal (`/not-found`).
6. **Egységes query‑dekódolás** – Minden query parsing a `RouteData.fromState()`‑ben történjen, ne az UI‑ban.
7. **Unit teszt** – Minden új útvonalhoz legalább egy teszt a `test/routing/` mappában.

---

## Gyors ellenőrző lista

| ✅ Ellenőrizd                    | Hogyan?                                            |
| ------------------------------- | -------------------------------------------------- |
| Létezik path konstans           | `grep '/new-path' lib/src/routing` → **1 találat** |
| Deep link megnyitja a képernyőt | `flutter test test/routing/new_path_test.dart`     |
| Jogosulatlan redirect           | Deep link guest módban → Sign‑in nézet             |

---

## Változásnapló

| Dátum      | Szerző   | Megjegyzés  |
| ---------- | -------- | ----------- |
| 2025‑07‑29 | docs‑bot | Első verzió |
