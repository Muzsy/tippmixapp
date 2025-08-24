# 🔒 Firestore Security Rules & Access Control (EN)

This document defines the security model and Firestore access rules for TippmixApp.

---

## 🔐 Goals

- Users can only read/write their own data
- Prevent manipulation of TippCoin or tickets
- Ensure data integrity during bet placement
- Leaderboard requires read-only access to all `users/{uid}` docs for signed-in users
- TippCoin balances stored in `users/{uid}/wallet/main`; legacy `wallets/*` and `coin_logs/*` paths removed

---

## 🧾 Firestore Structure Overview

```
users/{uid}
  badges/{badgeId}
  settings/{settingId}
  wallet/{walletId}
  ledger/{entryId}
  tickets/{ticketId}
  bonus_state
tickets/{ticketId} (legacy read-only)
public_feed/{postId}
  reports/{reportId}
moderation_reports/{reportId}
copied_bets/{userId}
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

    // user-centric wallet & ledger (SoT)
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

    // root tickets collection (legacy, read-only)
    match /tickets/{ticketId} {
      allow create: if false;
      allow read: if request.auth != null;
      allow update, delete: if false;
    }

    // user-centric tickets subcollection
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

---

## 📘 Changelog

- 2025-08-06: Corrected `/tickets/{ticketId}` field whitelist to cover all client-sent keys.
- 2025-08-20: Added user-centric wallet & ledger rules and dual-write notes.
- 2025-08-20: Disabled writes to legacy `wallets` and `coin_logs` paths.
- 2025-08-22: Added read-only rules for `system_configs/bonus_rules` and `users/{uid}/bonus_state`.
- 2025-08-23: Removed legacy `coin_logs` and `wallets/*` rules after wallet migration.
