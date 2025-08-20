# 🔒 Firestore biztonsági szabályok (HU)

Ez a dokumentum rögzíti a TippmixApp Firestore adatbázisra vonatkozó jogosultsági és integritási szabályait.

---

## 🔐 Célok

- A felhasználó csak a saját adatait érhesse el / módosíthassa
- Ne lehessen manipulálni TippCoin vagy szelvény adatokat
- Fogadásoknál biztosítani kell a konzisztens adatbevitelt
- A ranglista miatt minden hitelesített felhasználó olvashatja mások `users/{uid}` dokumentumát
- A TippCoin egyenlegek a `users/{uid}/wallet` alatt tárolódnak; a `wallets/*` és `coin_logs/*` útvonalak csak olvashatók

---

## 🧾 Adatstruktúra

```
users/{uid}
  badges/{badgeId}
  settings/{settingId}
  wallet
  ledger/{entryId}
wallets/{uid} (legacy)
coin_logs/{logId} (legacy)
tickets/{ticketId}
public_feed/{postId}
  reports/{reportId}
moderation_reports/{reportId}
copied_bets/{userId}
```

---

## 📜 Példa szabályok (pszeudó)

```js
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {

    match /users/{userId} {
      allow read:  if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    match /coin_logs/{logId} {
      allow create, update, delete: if false;
      allow read:   if request.auth != null && request.auth.uid == resource.data.userId;
    }

    match /wallets/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false;

      match /ledger/{ticketId} {
        allow read: if request.auth != null && request.auth.uid == userId;
        allow write: if false;
      }
    }

    // user-centrikus wallet és ledger (SoT)
    match /users/{userId}/wallet {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false;
    }
    match /users/{userId}/ledger/{entryId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false;
    }

    match /tickets/{ticketId} {
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.keys().hasOnly([
          'id','userId','tips','stake','totalOdd','potentialWin','createdAt','updatedAt','status']);
      allow read: if request.auth != null;
      allow update, delete: if false;
    }

    match /public_feed/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow update, delete: if false;

      match /reports/{reportId} {
        allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
        allow read, update, delete: if false;
      }
    }

    match /moderation_reports/{reportId} {
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      allow read, update, delete: if false;
    }

    match /users/{userId}/badges/{badgeId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update, delete: if false;
    }

    match /users/{userId}/settings/{settingId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /copied_bets/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }
  }
}
```

---

## 🧠 Legjobb gyakorlatok

- Alapértelmezetten tiltani, majd kollekciónként engedni
- Ellenőrizni kötelező mezőket (`rules` validáció)
- Ne bízz a kliens oldali adatban (pl. TippCoin érték)
- TippCoin logika inkább Cloud Function-ben fusson

---

## 📌 Tervezett fejlesztések

- `ticket.status` és `stake` mezők validálása
- Firebase Emulatorral szabály-tesztek írása
- Szabályok külön fájlokba szedése (CI kompatibilitás)
- Moderator / admin jogosultsági szintek bevezetése (később)

---

## 📘 Változásnapló

- 2025-08-06: Javítva a `/tickets/{ticketId}` mezőlista, hogy a kliens összes kulcsa engedélyezett legyen.
- 2025-08-20: Hozzáadva user-centrikus wallet és ledger szabályok, duplairás.
- 2025-08-20: Letiltva a `wallets` és `coin_logs` legacy írása.
