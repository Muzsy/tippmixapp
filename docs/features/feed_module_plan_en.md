# 📰 Feed Module Plan (EN)

This document defines the architecture and plan for the community activity Feed in TippmixApp.

---

## 🎯 Purpose

* Show latest public user activities
* Increase engagement and community awareness
* Serve as entry point for inspiration and exploration

---

## 📋 What appears in the feed?

* User placed a bet (ticket summary)
* User won a ticket (with TippCoin gain)
* User earned a badge (with name)

---

## 📁 Firestore Structure (suggested)

```
feed_events/{eventId}
```

```json
{
  "type": "ticket_placed" | "ticket_won" | "badge_earned",
  "userId": "abc123",
  "displayName": "PlayerX",
  "timestamp": "...",
  "payload": { ... }
}
```

* Store only non-sensitive info
* Keep size low for Firestore read quotas

---

## 🔁 Feed Generation

* Triggered by: ticket submission, ticket status change, badge earned
* Cloud Function appends new `feed_events`
* Optional: scheduled cleanup (keep 7–14 days max)

---

## 🧠 UI Plan

* `HomeScreen` shows a vertical feed list
* Card types:

  * TicketPlacedCard
  * TicketWonCard
  * BadgeEarnedCard
* Usernames anonymized (or use displayName)
* Profile avatar shown if available

---

## 🧪 Testing

* Widget tests per feed card type
* List virtualization test (long feed)
* Data-mock integration test (Firebase query simulation)
