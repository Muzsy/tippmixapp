# 🔒 Firestore biztonsági szabályok (HU)

Ez a dokumentum rögzíti a TippmixApp Firestore adatbázisra vonatkozó jogosultsági és integritási szabályait.

---

## 🔐 Célok

- A felhasználó csak a saját adatait érhesse el / módosíthassa
- Ne lehessen manipulálni TippCoin vagy szelvény adatokat
- Fogadásoknál biztosítani kell a konzisztens adatbevitelt
- A ranglista miatt minden hitelesített felhasználó olvashatja mások `users/{uid}` dokumentumát
- A TippCoin egyenlegek a `users/{uid}/wallet/main` alatt tárolódnak; a `wallets/*` és `coin_logs/*` útvonalak kivezetve

---

## 🧾 Adatstruktúra

```
users/{uid}
  badges/{badgeId}
  settings/{settingId}
  wallet/{walletId}
  ledger/{entryId}
  tickets/{ticketId}
  bonus_state
tickets/{ticketId} (legacy csak olvasás)
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

    // user-centrikus wallet és ledger (SoT)
    match /users/{userId}/wallet/{walletId} {
      allow read: if request.auth != null && request.auth.uid == userId && walletId == 'main';
      allow write: if false;
    }
    match /users/{userId}/ledger/{entryId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false;
    }
    match /system_configs/{key} {
      allow read: if true;
      allow write: if false;
    }
    match /users/{userId}/bonus_state {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false;
    }

    // gyökér tickets kollekció (legacy, csak olvasás)
    match /tickets/{ticketId} {
      allow create: if false;
      allow read: if request.auth != null;
      allow update, delete: if false;
    }

    // felhasználói tickets alkollekció
    match /users/{userId}/tickets/{ticketId} {
      allow create: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.userId == userId
        && request.resource.data.keys().hasOnly([
          'id','userId','tips','stake','totalOdd','potentialWin','createdAt','updatedAt','status']);
      allow read: if request.auth != null && request.auth.uid == userId;
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

## 💬 Fórum gyűjtemények

- `threads/{threadId}`: csak hitelesített felhasználó hozhat létre; a `createdBy` mezőnek egyeznie kell a `request.auth.uid` értékkel, és csak a `title`, `type`, `fixtureId`, `createdBy`, `createdAt` mezők engedélyezettek.
- `threads/{threadId}/posts/{postId}`: `userId == request.auth.uid`; frissítés csak `content` és `editedAt` mezőkre, 15 percen belül; a thread nem lehet zárolva.
- `votes/{voteId}`: a felhasználó akkor szavazhat, ha `userId` megegyezik az auth UID-vel; a dokumentum azonosítója `entityId_uid`; törlés a tulajdonos vagy moderátor által.
- `reports/{reportId}`: jelentés létrehozása csak bejelentkezett felhasználónak `reporterId == auth.uid`; `status` mező nem állítható kliensről; csak moderátor olvashatja vagy módosíthatja.

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
- 2025-08-22: Hozzáadva a `system_configs/bonus_rules` és `users/{uid}/bonus_state` csak olvasható szabályai.
- 2025-08-23: Eltávolítva a `coin_logs` és `wallets/*` legacy szabályblokkok.
