# Főképernyő – Home Profile Header készre

## Kontextus

A főképernyő tetején jelenleg részlegesen működik a profilösszefoglaló. Cél, hogy a **bejelentkezett** felhasználónak teljes, reszponzív „profilfejlécet” jelenítsünk meg (név, avatar, TippCoin-egyenleg, gyorslinkek), **vendég** esetén pedig egy statikus, lokalizált CTA‑csempét (belépés/registráció hívógombokkal). A megoldás a meglévő struktúrára épül (Riverpod/AuthProvider, HomeScreen), és nem sérti a már működő funkciókat.

## Cél (Goal)

A Home képernyő tetején **feltételes fejléc**: Auth==logged‑in → `ProfileSummary`; Auth==guest → új `GuestCtaTile`. Teljes i18n (HU/EN/DE), widget‑tesztek, és `flutter analyze` hibamentes állapot.

## Feladatok

* [ ] Új komponens: `GuestCtaTile` (statikus csempe vendégeknek) – cím, leírás, két gomb (Bejelentkezés / Regisztráció), GoRouter route‑okra hivatkozva.
* [ ] Integráció a `HomeScreen` tetején: Riverpod/AuthProvider alapján `ProfileSummary` **vagy** `GuestCtaTile` render.
* [ ] (Logged in) `ProfileSummary` jelenjen meg névvel, avatar‑ral és TippCoin egyenleggel (UserModel.tippCoin). Ha nincs avatar, monogram‑placeholder.
* [ ] Lokalizáció: új kulcsok HU/EN/DE (guest csempe: cím, leírás, gombok szövege).
* [ ] Widget teszt: vendég állapot → CTA‑szövegek láthatók; bejelentkezett állapot → `ProfileSummary` jelenik meg és az egyenleg felirat renderelődik.
* [ ] Kódstílus, témázás: projekt Theme használata, hard‑coded színek nélkül.
* [ ] CI‑lépések: `flutter gen-l10n`, `flutter analyze`, `flutter test` futtatása.

## Acceptance Criteria / Done Definition

* [ ] Home tetején feltételesen jelenik meg: **vendég** → „Kezdj el játszani” jellegű csempe; **bejelentkezett** → teljes `ProfileSummary`.
* [ ] Navigációs gombok a vendég csempén működnek (login/register útvonalak, GoRouter‑on).
* [ ] Új stringek az ARB‑ben (HU/EN/DE), `flutter gen-l10n` fut.
* [ ] `flutter analyze` hibamentes.
* [ ] Widget tesztek zöldek.

## Megjegyzések (implementációs irány)

* **Auth állapot**: Riverpod `authProvider`/`authStateProvider` (amelyik a projektben van); ha nincs egységes provider, átmenetileg `FirebaseAuth.instance.currentUser` wrap egy `Provider`‑be.
* **TippCoin megjelenítés**: `UserModel.tippCoin` mező; ha nincs betöltve, mutass rövid skeletont vagy „—”.
* **Monogram avatar**: ha hiányzik a kép, a megjelenítendő név kezdőbetűi kör alakú háttérrel (Theme‑ből színezve).

## Hivatkozások

* Canvas → `/codex/goals/home_profile_header_keszre.yaml`
* Codex útmutató → `Codex Canvas Yaml Guide.pdf`
* Audit: Főképernyő/Profil összefoglaló, i18n állapot (HU/EN/DE)
