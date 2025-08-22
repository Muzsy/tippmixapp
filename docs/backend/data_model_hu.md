# 🧬 Adatmodell (HU)

Ez a dokumentum a TippmixApp legfontosabb adatmodelljeit mutatja be.
A modellek Dart nyelven készülnek, Firestore-ban tárolódnak.

---

## 👤 UserModel

A felhasználó adatait tárolja. **A TippCoin‑egyenleg átkerült a WalletModel‑be.**

> ⚠️ **Elavult mező**: `tippCoin` – ideiglenesen marad a kompatibilitás kedvéért, de hamarosan törlésre kerül, miután a Cloud Function inicializálja a wallet doksit.

```dart
UserModel {
  String uid;
  String email;
  String? displayName;
  String? avatarUrl;
  // int tippCoin; // ELAVULT – lásd WalletModel
  // terv: badge-ek, ranglista helyezés, ország
}
```

- Regisztrációkor jön létre
- Alapértelmezett `tippCoin = 1000`
- Elérési út: `users/{uid}`

# 💰 WalletModel (Új)

TippCoin‑egyenleg tárolása felhasználónként.

```dart
WalletModel {
  String userId;   // ugyanaz, mint az auth.uid
  int coins;       // aktuális TippCoin egyenleg
  Timestamp createdAt;
}
```

- Elérési út: `wallets/{userId}` (legacy) és `users/{userId}/wallet` (user-centrikus SoT)
- A dokumentum **lazy‑create** módon jön létre az első fogadáskor.
- Egy **Auth onCreate** Cloud Function most mindkét helyre 50 coin kezdő egyenleget ír.
- Ledger bejegyzések a `users/{userId}/ledger/{entryId}` útvonalon tükröződnek.

## 🎯 TipModel

Egy kiválasztott fogadási eseményt (kimenetelt) jelöl.

```dart
TipModel {
  String matchId;
  String event;
  String market;
  String outcome;
  double odds;
}
```

- Csak szelvényhez csatolva jelenik meg
- Odds érték a beküldés pillanatában frissül az API-Football-ból

## 🎟️ TicketModel

Egy teljes szelvényt képvisel, 1 vagy több tippel.

```dart
TicketModel {
  String ticketId;
  String userId;
  List<TipModel> tips;
  int stake;
  double potentialWin;
  String status; // pending, won, lost
  Timestamp createdAt;
}
```

- Elérési út: `users/{userId}/tickets/{ticketId}`
- Státusz később frissül a meccsek lezárása után

## 🎁 Bónusz szabályok és állapot

A globális szabályokat a `system_configs/bonus_rules` dokumentum tartalmazza.

```json
BonusRules {
  version: number,
  killSwitch: boolean,
  signup?: { enabled: boolean, amount: number, once: boolean },
  daily?: { enabled: boolean, amount: number, cooldownHours: number, maxPerDay?: number }
}
```

Felhasználónkénti bónusz állapot a `users/{uid}/bonus_state` dokumentumban tárolódik.

```json
BonusState {
  signupClaimed?: boolean,
  lastDailyClaimAt?: timestamp,
  dailyCooldownUntil?: timestamp,
  lastAppliedVersion?: number,
  lock?: { active: boolean, expiresAt: timestamp | null }
}
```

## 🔜 Tervezett modellek

- `BadgeModel`: badge-szabályok és megszerzett címek
- `LeaderboardEntryModel`: ranglista gyorsított tárolása
- `FeedEventModel`: közösségi események (feed)

## 🗑️ Elavult modellek

- `TippCoinLogModel`: leváltva a `users/{uid}/ledger` alatti naplóbejegyzésekkel

## 📘 Változásnapló

- 2025-08-20: Frissítve a wallet és ledger duplairás, onCreate inicializálás dokumentációja.
- 2025-08-22: Hozzáadva a BonusRules és BonusState modellek a Bonus Engine-hez.
