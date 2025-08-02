# 🥇 Badge System (EN)

This document outlines the logic and planned structure for the badge (achievement) system in TippmixApp.

---

## 🎯 Purpose

- Reward users for milestones and achievements
- Provide visual motivation (gamification)
- Display badges in profile

---

## 🧾 Badge Types (examples)

- 🎯 **Sharp Shooter** – 3 winning tickets in a row
- 🧠 **Tactician** – Win with 4+ odds
- 🕓 **Veteran** – 100+ days active
- 🏅 **Starter Pack** – Place first bet

---

## 📁 Firestore Design

Suggested structure:

```
users/{uid}/badges/{badgeId}
```

Badge object:

```json
{
  "id": "veteran",
  "name": "Veteran",
  "description": "100 days active",
  "earnedAt": "timestamp"
}
```

- Central config: `badges_config` (in-code or Firestore root)
- Localized name + description (via keys or ARB)

---

## 🔁 Evaluation

- Triggered on ticket submit, result update, or daily login
- Central BadgeService evaluates logic
- Newly earned badges stored under `users/{uid}/badges/`

---

## 🧠 UI/UX

- Profile displays unlocked + locked badges
- New badge triggers popup/snackbar
- Add 🔔 notification icon or dot indicator

---

## 🧪 Testing Plan

- Unit test: logic for each badge rule
- Widget test: badge panel rendering
- Integration: reward flow end-to-end
