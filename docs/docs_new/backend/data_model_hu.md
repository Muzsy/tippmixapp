# 🧬 Adatmodell (HU)

Ez a dokumentum a TippmixApp legfontosabb adatmodelljeit mutatja be.
A modellek Dart nyelven készülnek, Firestore-ban tárolódnak.

---

## 👤 UserModel

A felhasználó adatait és TippCoin egyenlegét tárolja.

```dart
UserModel {
  String uid;
  String email;
  String? displayName;
  String? avatarUrl;
  int tippCoin;
  // terv: badge-ek, ranglista helyezés, ország
}
```

* Regisztrációkor jön létre
* Alapértelmezett `tippCoin = 1000`
* Elérési út: `users/{uid}`

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

* Csak szelvényhez csatolva jelenik meg
* Odds érték a beküldés pillanatában frissül az OddsAPI-ból

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

* Elérési út: `tickets/{userId}/{ticketId}`
* Státusz később frissül a meccsek lezárása után

## 🔜 Tervezett modellek

* `TippCoinLogModel`: coin tranzakciók naplózása
* `BadgeModel`: badge-szabályok és megszerzett címek
* `LeaderboardEntryModel`: ranglista gyorsított tárolása
* `FeedEventModel`: közösségi események (feed)
