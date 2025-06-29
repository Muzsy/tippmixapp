# T12 – RewardsScreen widget-teszt vászon

## Cél

Validálni, hogy a **RewardsScreen** (lib/screens/rewards/rewards\_screen.dart) helyesen jelenik meg és működik:

* jutalmak listázása kártyákon (RewardCard)
* jutalom átvétele (Claim) eltávolítja / státuszát frissíti
* üres lista esetén üzenet jelenik meg
* 3 nyelvű lokalizáció (en, hu, de)
* hosszú lista scroll közben stabil
* ikon‐mapping helyes (`coin`, `badge`, egyéb → default)

---

## Környezet

* **Flutter**: stable (≥ 3.22)
* `flutter_test`, `riverpod` mockok
* `rewardServiceProvider` felülbírálása tesztben (FakeRewardService)
* `AppLocalizations` - l10n setup

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      rewardServiceProvider.overrideWith((ref) => FakeRewardService(rewards)),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const RewardsScreen(),
    ),
  ),
);
```

---

## Tesztesetek

| ID    | Leírás                     | Előkészítés                   | Elvárt eredmény                                      |
| ----- | -------------------------- | ----------------------------- | ---------------------------------------------------- |
| RC-01 | **Lista megjelenítése**    | 1 reward (`Daily Bonus`)      | Cím, leírás, Claim gomb látszik                      |
| RC-02 | **Átvétel – eltávolítás**  | Ugyanaz, tap Claim            | Item eltűnik a ListView-ből                          |
| RC-03 | **Empty state**            | rewards = `[]`                | `loc.rewardEmpty` üzenet középen                     |
| RC-04 | **Lokalizáció – HU**       | locale = `hu`, rewards = `[]` | Üzenet magyar: "Nincs átvehető jutalom"              |
| RC-05 | **Lokalizáció – DE**       | locale = `de`                 | Üzenet német nyelven                                 |
| RC-06 | **Scroll stabilitás**      | 150 reward dummy              | Scroll végéig tud görgetni, nincs overflow/exception |
| RC-07 | **Ikon mapping**           | reward.iconName = `coin`      | `Icons.attach_money` jelenik meg                     |
| RC-08 | **onClaim callback hívás** | mock onClaim (bool flag)      | Claim után a flag `true`                             |

---

## DoD

* Fenti 8 teszteset zölden fut CI-ben (`flutter test`)
* RewardsScreen és RewardService lefedettség ≥ 90 %
* Nincs `debugPrint` / console spill
* Golden snapshot továbbra sem szükséges
* YAML-cél (`codex/goals/fill_canvas_rewards_screen_test.yaml`) megfelel a Codex szabályoknak (lint OK)

---

## Nyitott kérdések

1. A jutalom átvétel animációja (confetti) kötelező tesztelni? (most skipelhető)
2. Később kategória-szűrő (Daily, Weekly, Achievements) bekerülhet – külön teszt?

---

## Hivatkozások

* rewards\_screen.dart, reward\_card.dart – **lib/**
* reward\_service.dart, reward\_model.dart – **lib/services**, **lib/models**
* Sprint5 Docs: **Progress Overview2.pdf**, **Audit 2025-06-26.pdf**
