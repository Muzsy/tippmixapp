# 🧩 priority\_rules.md – TippmixApp fejlesztési prioritások Codex számára

Ez a dokumentum definiálja a TippmixApp Codex-kompatibilis fejlesztési prioritási szabályait. Célja, hogy a Codex mindig a megfelelő fontossági sorrend szerint dolgozza fel a feladatokat, és az MVP utáni fejlesztés során a kritikus komponenseket részesítse előnyben.

---

## 🎯 Prioritási szintek

| Prioritás | Jelentés                                | Típusok                                |
| --------- | --------------------------------------- | -------------------------------------- |
| `P0`      | Kritikus – a működéshez elengedhetetlen | Tranzakció-kezelés, jogosultság, cache |
| `P1`      | Fontos – felhasználói élményt javít     | Gamifikáció, ranglista, push           |
| `P2`      | Opcionális – közösségi + kiegészítő     | Feed, avatar, klubfunkciók             |
| `P3`      | Jövőbeli – AI, A/B, haladó analitika    | AI Tippelő, statisztikai vizualizáció  |

---

## 🔝 P0 – Kritikus elemek

- `CoinService` és `coin_trx.ts` működése
- Tranzakciós rollback, naplózás (TippCoinLogModel)
- Firestore security rules (create / read elkülönítve)
- `odds_cache_wrapper.dart` – TTL-alapú cache és kvótavédelem
- CI pipeline (`ci.yaml`) – automatikus build & teszt
- Lokalizációs rendszer enum + ARB + runtime váltás kombinációja

---

## 🥇 P1 – Fontos bővítések

- `BadgeService` (pl. 10 nyertes fogadás utáni badge)
- `LeaderboardScreen` – Coin / Winrate alapú ranglista
- `SettingsScreen` – Téma / nyelv / kijelentkezés
- `NotificationService` – Push értesítések eseményekre
- Widget és unit tesztek bevezetése (80% feletti coverage cél)

---

## 🧩 P2 – Közösségi kiegészítések

- `FeedService` – Like, komment, CopyBet
- `ProfileBadgeWidget` – Profilon badge-ek valós időben
- `ChallengeService` – baráti kihívások logikája
- `ClubModel` – klubtagság, logó, közös feed
- `DailyBonusJob` – időzített CF napi coinra

---

## 🔮 P3 – AI és haladó

- `AIRecommender` – LogisticRegression alapú javaslatok
- `UserPrefModel` – felhasználói preferenciák alapján AI input
- `tip_reco_widget.dart` – ajánlott tipp megjelenítése odds alatt
- A/B tesztelés támogatása (Settings toggle)
- BigQuery backend kapcsolatok mélyítése

---

## 📎 Kapcsolódások

- `codex_context.yaml` – globális szabályzat
- `fill_canvas_*.yaml` – minden YAML fájl tartalmaz `priority:` mezőt
- `sprint*.md` – sprinttervek és státuszok meghatározása
- `audit_report.md` – audit alapján javasolt prioritáslista

---

## ✅ Codex-végrehajtási elvek

1. `P0` feladatokat csak akkor kerülhet el a Codex, ha a canvas lezárt
2. `P1–P2` automatikusan futtatható, ha nincs P0 blokkolás
3. `P3` csak explicit sprint utasítás alapján generálható
4. A YAML fájlban kötelező megadni a `priority:` mezőt
5. A Codex elsőként a `P0`-s elemeket dolgozza fel, sprintfüggetlenül

---

Ez a dokumentum minden Codex-futtatás során figyelembe veendő, ha prioritási ütközés vagy sorrendi kérdés merül fel.
