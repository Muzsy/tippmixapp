# Sprint8 – Regisztrációs állapot visszaállítása (reset)

## Kontextus

**H-7**: Ha a felhasználó kilép a több‑lépéses regisztrációs folyamatból (például visszalép a kezdőképernyőre vagy bezárja az appot), a `RegisterStateNotifier` benne maradt értékei a memóriában maradnak. Amikor később újraindul a regisztráció, ezek a régi adatok automatikusan betöltődnek, ami hibás vagy zavaró viselkedést okoz (pl. előtöltött e‑mail, pipált checkbox).

## Cél

Biztosítani, hogy a regisztrációs állapot **mindig tiszta** legyen, amikor a felhasználó új regisztrációt indít, illetve amikor a regisztrációs wizard kilép a képernyőről.

## Feladatok

* [ ] **`RegisterStateNotifier`** – vezessünk be egy `reset()` metódust, ami a `state`‑et üres `RegisterData()` értékre állítja.
* [ ] **`RegisterWizard`** – a `StatefulWidget` `dispose()` metódusában hívjuk meg a notifier `reset()`‑jét.
* [ ] **Sikeres regisztráció után** (Step 3 Finish gomb): hívjuk meg a `reset()`‑et, hogy a következő felhasználókezdeményezéskor is tiszta legyen.
* [ ] **Unit‑teszt**: `reset_clears_state_test.dart` – inicializáljuk a notifiert teszt‑adatokkal, hívjuk `reset()`, várjuk, hogy a state üres legyen.
* [ ] **Widget‑teszt**: szimuláljuk, hogy kitöltjük az első lépést, majd `pumpWidget(Container())`‑rel eltávolítjuk a `RegisterWizard`‑ot; újraépítéskor a mezők legyenek üresek.
* [ ] `flutter analyze` és minden teszt lefut zölden.

## Acceptance Criteria / Done Definition

* [ ] A `RegisterStateNotifier` rendelkezik `reset()` metódussal.
* [ ] A wizard elhagyásakor (dispose) a state törlődik.
* [ ] Új regisztráció indításakor minden mező üres.
* [ ] Az összes teszt zöld, `flutter analyze` hibamentes.

## Hivatkozások

* Canvas → `/codex/goals/sprint8_register_state_reset.yaml`
* Érintett fájlok: `lib/state/register_state_notifier.dart`, `lib/ui/auth/register_wizard.dart`
