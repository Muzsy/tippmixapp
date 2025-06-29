## 🧪 ProfileScreen – Widget‑teszt (Sprint5 ✓ T06)

### 🎯 Cél

Az **ProfileScreen** felület regressziós lefedése, különös tekintettel a badge‑gridre és a statisztikák megjelenítésére.

| Use‑case               | Elvárt viselkedés                                                                                                        |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| 1. Badge‑grid render   | A `ProfileBadgeWidget` megjeleníti az összes megszerzett jelvényt, *hiányzó* jelvények szürke overlay‑jel jelennek meg.  |
| 2. Badge‑tap hero‑anim | Jelvényre tap → hero‑animáció mellett navigál a `BadgeScreen`‑re (named route: `BadgeRoute`).                            |
| 3. Statisztika‑kártyák | `StatsCard` widgetekben a `StatsProvider` által szolgáltatott értékek jelennek meg (nyertes tippek, TippCoin balance …). |
| 4. Üres jelvénylista   | Ha a felhasználónak nincs badge‑e, jelenjen meg a `EmptyBadgePlaceholder`.                                               |
| 5. Lokalizáció         | A képernyő minden szövege elérhető 3 nyelven (hu/en/de).                                                                 |

### 🏗️ Implementációs lépések

1. **ProviderScope override**

   * `authProvider` → `_FakeAuthNotifier` (bejelentkezett felhasználó mock).
   * `badgeStreamProvider` → `StreamProvider<List<BadgeModel>>` fake adat.
   * `statsProvider` → `Provider<StatsModel>` fake adat.
2. **Widget pump** – `MaterialApp` 3 nyelvvel, `debugShowCheckedModeBanner: false`, `initialRoute: ProfileRoute`.
3. **Teszt #1** – *badge‑grid render*

   * Várjuk `find.byType(ProfileBadgeWidget)`; assert badge‑count == fake.length.
4. **Teszt #2** – *hero‑anim*

   * `tester.tap` egy badge‑re, majd `await tester.pumpAndSettle()`; assert `find.byType(BadgeScreen)`.
5. **Teszt #3** – *stats‑kártyák*

   * Ellenőrizzük, hogy `StatsCard`‑ban található számszerű értékek megegyeznek a fake modellel.
6. **Teszt #4** – *üres jelvénylista*

   * Üres stream override → `EmptyBadgePlaceholder` jelenik meg.

### ✅ DoD

* Tesztek **zölden futnak** `dart run test` paranccsal Codex környezetben.
* 3 nyelvű lokalizáció lefedve; fut a `localization_logic.md` sanity check.
* Kódfedettség ≥ 90 % az érintett fájlokra.
* CI pipeline zöld (lint + test + coverage + codex check).

### 📎 Kapcsolódások

* `codex_docs/testing_guidelines.md`
* `codex_docs/localization_logic.md`
* `lib/screens/profile_screen.dart`
* `lib/widgets/profile_badge_widget.dart`
* `lib/widgets/stats_card.dart`
* `lib/widgets/empty_badge_placeholder.dart`
* `lib/providers/auth_provider.dart`
* `lib/providers/badge_stream_provider.dart`
* `lib/providers/stats_provider.dart`

> **Megjegyzés**: A Codex nem futtathat Flutter‑parancsot; a tesztek Dart‑teszt runnerrel futnak (`dart run test`).
