# 🔒 Firestore biztonsági szabályok (HU)

Ez a dokumentum rögzíti a TippmixApp Firestore adatbázisra vonatkozó jogosultsági és integritási szabályait.

---

## 🔐 Célok

- A felhasználó csak a saját adatait érhesse el / módosíthassa
- Ne lehessen manipulálni TippCoin vagy szelvény adatokat
- Fogadásoknál biztosítani kell a konzisztens adatbevitelt

---

## 🧾 Adatstruktúra

```
users/{uid}
wallets/{uid}
tickets/{ticketId}
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

    match /wallets/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow delete: if false;
    }

    match /tickets/{ticketId} {
      allow create: if request.auth != null
        && request.resource.data.userId == request.auth.uid
        && request.resource.data.keys().hasOnly([
          'userId','tips','stake','totalOdd','potentialWin','createdAt','updatedAt','status']);
      allow read: if request.auth != null;
      allow update, delete: if false;
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
