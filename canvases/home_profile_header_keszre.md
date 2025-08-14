# Főképernyő – Home Profile Header készre

## Kontextus

A főképernyő tetején jelenik meg a felhasználói profil‑fejléc. A kódban már létezik egy `ProfileSummary` widget (bejelentkezett állapot gyors áttekintése), és lokalizációban előkészített üzenet a vendég felhasználók számára (audit: `home_guest_message`). A cél a fejléc véglegesítése: **bejelentkezett** felhasználónál teljes profil‑összefoglaló, **vendég** felhasználónál helyettesítő, statikus „promo” csempe.

## Cél (Goal)

Egységes, újrahasznosítható fejléc komponens a Home tetején, amely **automatikusan** vált a bejelentkezett és vendég állapot között, teljes i18n és widget tesztekkel.

## Feladatok

* [ ] Új összevonó widget: `HomeProfileHeader`

  * Döntési logika: ha `AuthProvider` szerint van bejelentkezett user → `ProfileSummary`, különben `GuestPromoTile`.
  * Paraméterek: opcionális `onLoginTap`, `onRegisterTap` callbackek (ha a későbbiekben a Home képernyő át akarja drótozni a gombokat). Callback hiányában csak információs csempe.
* [ ] Vendég csempe: `GuestPromoTile`

  * Statikus, csempés UI (ikon, cím, leírás, 1‑2 CTA gomb – callbackekre kötve).
  * Teljes i18n kulcsok: cím, leírás, gombfeliratok (HU/EN/DE).
  * A dizájn a meglévő csempéhez igazodik (sötét/világos témát követ, kerekített sarok, padding).
* [ ] Profil‑fejléc (bejelentkezett) véglegesítése `ProfileSummary` újrahasznosításával

  * Avatár (user fotó vagy monogram), megjelenítendő név, TippCoin egyenleg.
  * Skeleton/placeholder állapot rövid betöltéshez (pl. üres avatár, shimmer helyett egyszerű `Opacity`).
* [ ] i18n

  * Új kulcsok: `home_guest_title`, `home_guest_body`, `home_cta_login`, `home_cta_register` HU/EN/DE nyelven.
* [ ] Tesztek

  * `HomeProfileHeader` vendég módban → `GuestPromoTile` renderel, helyes feliratokkal (HU).
  * `HomeProfileHeader` bejelentkezett módban → `ProfileSummary` renderel, és megjelenik a felhasználó neve + egyenlege (mockolt providerrel).
* [ ] Integráció a Home tetején (nem sértve meglévő funkcionalitást)

  * A `HomeScreen` (vagy a fő tartalmi widget) fejlécében a korábbi közvetlen `ProfileSummary` helyett `HomeProfileHeader` használata.

## Done / Acceptance Criteria

* [ ] `HomeProfileHeader` komponens elérhető a `lib/widgets/home_profile_header.dart` alatt.
* [ ] Vendég esetben a fejlécet a `GuestPromoTile` helyettesíti (statikus csempe, i18n kulcsokkal).
* [ ] Bejelentkezett esetben a meglévő `ProfileSummary` jelenik meg változtatás nélkül (vagy minimális, vizuális finomítással).
* [ ] Új i18n kulcsok HU/EN/DE ARB fájlokban; `flutter gen-l10n` lefut.
* [ ] Widget tesztek zöldek.
* [ ] `flutter analyze` hibamentes.

## Megjegyzések

* Navigációs CTA-k: a `GuestPromoTile` gombjai **opcionális callbackek**, hogy ne tegyünk feltevést a route‑nevekről. Ha nincs callback, a gombok rejtve vagy disabled.
* Téma: **nincs hard‑coded szín** – a Theme/ColorScheme alapján.
* Nem érintjük a „tiltott” fájlokat (android/ios/pubspec.yaml, stb.).

## Hivatkozások

* Canvas → `/codex/goals/home_profile_header_keszre.yaml`
* Audit: főképernyő/`ProfileSummary`, `home_guest_message` kulcs előkészítve.
* Localization best practice: `/docs/localization_best_practice.md` (projekt szabályai szerint).
