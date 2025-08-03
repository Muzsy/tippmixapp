# 🔒 Firestore Security Rules & Access Control (EN)

This document defines the security model and Firestore access rules for TippmixApp.

---

## 🔐 Goals

- Users can only read/write their own data
- Prevent manipulation of TippCoin or tickets
- Ensure data integrity during bet placement

---

## 🧾 Firestore Structure Overview

```
users/{uid}
wallets/{uid}
tickets/{ticketId}
```

---

## 📜 Example Rules (pseudo)

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

## 🧠 Best Practices

- Deny all by default, allow per collection
- Validate required fields with Firestore `rules`
- Do not trust client data (e.g. TippCoin values)
- Offload TippCoin logic to Cloud Functions

---

## 📌 Planned Enhancements

- Add validation for `ticket.status` and `stake`
- Create rule unit tests via Firebase Emulator
- Split rules into separate files (CI-friendly)
- Add moderator/admin roles (future)
