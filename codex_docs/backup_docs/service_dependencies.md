# 🔗 service\_dependencies.md – TippmixApp szolgáltatásfüggőségek

Ez a dokumentum definiálja a TippmixApp projekt Codex-kompatibilis szolgáltatásfüggőségeit. Célja, hogy a Codex mindig tisztában legyen egy adott service kapcsolódási pontjaival, és ne okozzon rejtett mellékhatásokat új modulok vagy logikák generálásakor.

---

## 🎯 Funkció

- Áttekinthetővé és deklaratívvá tenni a szolgáltatások közötti kapcsolatokat
- Biztosítani, hogy a Codex csak konzisztens módon bővítse vagy használja a service-eket
- Minimalizálni a rejtett állapot- vagy adatkonfliktusokat

---

## 🧠 Fejlesztési részletek

### Kulcsmodulok

| Szolgáltatás          | Függőségei                                                               |
| --------------------- | ------------------------------------------------------------------------ |
| `CoinService`         | `cloud_functions/coin_trx.ts`, `user_model.dart`, `TippCoinLogModel`     |
| `StatsService`        | `Firestore`, `BigQuery` (absztrakció: `StatsBackendMode`)                |
| `BadgeService`        | `ProfileController`, `TicketModel`, `StatsService`                       |
| `FeedService`         | `public_feed` kollekció (Firestore), `UserModel`, `CopyBetFlow`          |
| `NotificationService` | `Firebase Messaging`, `TicketModel`, `ChallengeService`                  |
| `ChallengeService`    | `UserModel`, `TicketModel`, `ClubModel`, `cloud_functions/push_logic.ts` |
| `DailyBonusJob`       | `cloud_functions/daily_bonus.ts`, `CoinService`, időzítő trigger         |
| `AIRecommender`       | `BigQuery`, `odds_api_wrapper.dart`, `UserPrefModel`                     |

---

## 🔁 Függőségi szabályok a Codex számára

1. Codex csak akkor használhat másik service-t, ha az a fenti táblázatban deklarált kapcsolaton keresztül történik.
2. Nem hívhat közvetlenül más service-t, ha az nincs dokumentálva.
3. Új kapcsolat felvételéhez új canvas szükséges, amely ezt kifejezetten engedélyezi.
4. Több service-t integráló logikát kizárólag `controllers/` alá helyezhet (pl. `profile_controller.dart`).
5. Cloud Functions csak akkor érhető el Codex számára, ha `canvases/` alatt dokumentált használati mód is van hozzá.

---

## 📎 Kapcsolódó fájlok

- `lib/services/*.dart` – szolgáltatások forráskódja
- `cloud_functions/*.ts` – tranzakciós és időzített logika
- `lib/controllers/` – összetett aggregációk / logikai routing
- `lib/models/` – minden adatmodell (ticket, tip, user, stats, stb.)
- `codex_context.yaml` – globális Codex szabályzat

---

## 🧪 Tesztelés

- Minden új service-hívásnál Codex-nek unit tesztet is kell generálnia
- Tesztek `test/services/<név>_test.dart` alá kerülnek
- Mock adatmodell használata ajánlott: `mock_user_model.dart`, `mock_ticket_model.dart`, stb.

---

Ez a dokumentum kötelező hivatkozási alap minden Codex által generált szolgáltatáshoz, amely más komponensre támaszkodik.
