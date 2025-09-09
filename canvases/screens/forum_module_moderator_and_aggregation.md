# Forum Module – Moderator Controls & Server Aggregation

🎯 **Function**
Add moderator-facing controls (pin/lock) to the forum, and migrate vote counting to a reliable server-side aggregation using Cloud Functions triggers. Align documentation and CI so that the new behavior is tested and documented consistently.

---

🧠 **Development Details**

* **Moderator UI**

  * Add pin/unpin and lock/unlock actions to `ThreadViewScreen` AppBar (visible only to moderators/admins as defined by Firestore rules/claims).
  * Ensure optimistic UI update with rollback on failure; show success/error snackbars.
* **Server-side `votesCount` aggregation**

  * Implement Cloud Functions triggers on `votes` create/delete to increment/decrement `posts/{postId}.votesCount` atomically.
  * Remove client-side manual vote count mutation; switch UI to display the server field with a lightweight local fallback while waiting for snapshot.
* **Repository updates**

  * Expose read-only `votesCount` from `Post` model; repository no longer mutates counts client-side.
* **Docs & CI**

  * Update docs to reflect moderator UI and server aggregation.
  * Ensure Jest tests in `cloud_functions` run in CI and reference the single source-of-truth `firebase.rules`.

---

🧪 **Test Status**

* Add widget tests for moderator buttons visibility and behavior (visible for moderators, hidden for regular users).
* Add integration test verifying lock state disables composer and prevents posting.
* Add Cloud Functions unit tests for vote triggers (create/delete) adjusting `votesCount` correctly.
* Verify e2e happy-path: user upvotes, count increments; user unvotes, count decrements; UI reflects server value.

---

🌍 **Localization**

* New keys required:

  * `"moderator_menu_title"`, `"pin_thread"`, `"unpin_thread"`, `"lock_thread"`, `"unlock_thread"`
  * `"moderator_action_success"`, `"moderator_action_failed"`

---

📎 **Connections**

* **Firestore:** `threads`, `posts`, `votes` (triggers on `votes`), security rules in `firebase.rules`.
* **Routing/UI:** `ThreadViewScreen` AppBar actions; composer respects `locked`.
* **Cloud Functions:** triggers for `votes` collection writes.
* **CI:** root workflow runs Flutter tests and CF Jest tests; both import `firebase.rules` from project root.

---

✅ **Checklist**

* [ ] AppBar moderator menu (pin/unpin, lock/unlock) visible only for moderators.
* [ ] Lock switches composer to disabled state in real time; UI banner present.
* [ ] Cloud Functions: `onCreate`/`onDelete` vote triggers adjust `posts/{postId}.votesCount`.
* [ ] Client code no longer mutates `votesCount`; uses server value with safe fallback.
* [ ] Repository and models updated to treat `votesCount` as read-only server field.
* [ ] Widget/integration tests cover moderator UI visibility and lock behavior.
* [ ] CF unit tests cover vote triggers increment/decrement and error paths.
* [ ] CI runs CF tests and references project-root `firebase.rules` only.
* [ ] Docs updated to describe moderator workflow and server-side aggregation.
