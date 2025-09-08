# Forum Module – Detailed MVP Completion Plan

> **Goal**: Complete the Forum Module to MVP standard. Codex must execute each task and check off the checklist. The module is considered complete when **all items are checked**.

---

## 🎯 Purpose

The Forum Module provides community discussion functionality: threads, posts, voting (upvotes), reporting (abuse/moderation), basic moderation tools, list filtering and sorting, thread view with pagination, thread creation with first post, locked thread handling, and client-side compliance with Firestore security rules.

---

## 🧠 Development Tasks

The following tasks are organized by priority. Each task has **completion criteria**. Codex should check off the checklist after successful implementation and validation.

### P0 – Critical (MVP blockers)

* [x] **Bind real Auth UID for all operations**
  Replace all hardcoded userIds with the Firebase Auth UID. Ensure Firestore writes only send allowed fields per rules.
  **Done when**: All writes succeed on emulator without `permission-denied`.

* [x] **Wire UI actions in Thread View**
  Implement Reply, Add Comment, Edit (owner), Delete (owner), Upvote, Report buttons. Add optimistic updates + error handling.
  **Done when**: All icons trigger correct behavior with feedback.

* [x] **New Thread creation flow**
  Add validation (title, first post, type). Navigate to thread view after success.
  **Done when**: Invalid inputs show errors, success redirects to thread with first post visible.

* [x] **Forum FAB navigation**
  Connect FAB on Forum list to New Thread screen.
  **Done when**: Clicking FAB opens new thread form.

* [x] **Firestore rules alignment**
  Ensure all client JSON structures align with Firestore rules. Expand rule tests.
  **Done when**: Rules tests pass (positive/negative), emulator shows no rejection.

* [x] **Locked threads handling**
  Respect `locked` field: disable composer and show message.
  **Done when**: Locked thread blocks posting, clear feedback visible.

### P1 – Important (MVP polish)

* [x] **Infinite scroll & pagination**
  Load more threads/posts at scroll end, add loading footer, prevent duplicates.
  **Done when**: Smooth scroll loads, no duplicate entries.

* [x] **Filtering & sorting**
  Implement All/Matches/General/Pinned + Latest/Newest/Activity combinations. Unit test query builder.
  **Done when**: Filters and sorts return correct results.

* [x] **Firestore indexes**
  Update `firestore.indexes.json` for all queries.
  **Done when**: No missing index errors in emulator.

* [ ] **Thread aggregate fields**
  Maintain `lastActivityAt` and `postCount` on create/delete.
  **Done when**: Ordering and counts are correct.

### P2 – Quality & Moderation

* [ ] **Report flow**
  Implement report form, save Firestore document, show confirmation.
  **Done when**: Report works end-to-end, user sees feedback.

* [ ] **Upvote state and counter**
  Show per-user upvote state + total count, optimistic updates, idempotent behavior.
  **Done when**: Upvote count correct, no double increments.

* [ ] **Edit/Delete own posts**
  Add Edit dialog + Delete confirmation, owner-only access.
  **Done when**: Owners can edit/delete, rules respected.

### P3 – Testing & Dev Experience

* [ ] **End-to-end integration test**
  Full path: Login → New Thread → First Post → List → Open Thread → Comment → Upvote → Report.
  **Done when**: Test green locally and in CI.

* [ ] **Extended rules testing**
  Cover owner vs non-owner, locked vs unlocked, whitelist violations, etc.
  **Done when**: Extended rules test suite passes.

* [ ] **Localization updates (HU/EN/DE)**
  Externalize all new strings (errors, forms, snackbars), update ARB files, regenerate l10n.
  **Done when**: ARB files updated, build passes, translations complete.

---

## 🧪 Test Status

* Current: unit and widget tests exist, rules tests basic.
* Missing: full e2e happy-path, extended rules, pagination/filter tests.
* Critical: Ensure client JSON exactly matches rules; otherwise regressions occur.

---

## 🌍 Localization

* Target languages: **HU/EN/DE**.
* Work: add new keys for actions, errors, validation, and feedback.

---

## 📎 Dependencies

* **Firebase/Firestore**: collections (`threads`, `posts`, `votes`, `reports`), indexes, rules.
* **Auth**: required for write operations, owner validation.
* **CI**: must run emulator tests (rules + integration).
* **Moderation**: report schema compatible with future admin tools.

---

## ✅ Definition of Done

1. All P0–P3 checklist items checked.
2. All tests (unit, widget, integration, rules) pass in CI.
3. Manual emulator run works (thread → post → upvote → report → locked thread).
4. No missing index errors.
5. Localization build passes without errors.
