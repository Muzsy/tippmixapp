# Forum Module – Fixups and Completion Tasks

🎯 **Function**
The forum module provides community discussion features: threads, posts, voting, and reporting.
This canvas documents the missing and incomplete parts that must be finished to reach a production-ready MVP.

---

🧠 **Development Details**

* **Thread Navigation**

  * Forum list items currently do not open thread detail view (`ThreadViewScreen`).
* **Locked Thread Handling**

  * `ThreadViewScreen` always assumes unlocked threads; composer is active even for locked ones.
* **Firestore Rules Duplication**

  * Two divergent rulesets exist: `firebase.rules` and `cloud_functions/firestore.rules`.
* **Voting**

  * No initial state query for a user’s vote.
  * No unvote/removal option.
  * Votes count not surfaced in UI.
* **Thread Types**

  * New thread form only supports `general` type.
  * No match/fixture integration; `MarketSnapshotAdapter` unused.
* **Post Editing**

  * UI allows edit icon beyond 15 minutes; Firestore rule rejects, but UI lacks feedback.
* **Quoting**

  * Model has `quotedPostId` but UI only inserts `@username`.
* **Reports**

  * Implemented against `/reports` root collection.
  * Inconsistent with the alternative rules file (subcollections).
* **UI Polish**

  * No “Thread locked” banner.
  * No clear pinned marker in `ThreadView`.
* **Moderation**

  * No admin UI for pinning/locking threads.

---

🧪 **Test Status**

* Unit, widget and integration tests exist for thread/post creation and Firestore rules.
* Missing tests:

  * Navigation into thread detail.
  * Locked thread composer disable.
  * Voting toggle/unvote flow.
  * Thread type = match creation.
* Rules tests diverge between the two rules files.

---

🌍 **Localization**

* Forum texts are localized in HU/EN/DE.
* New keys required:

  * `"forum_thread_locked_banner"`.
  * `"vote_count"`.
  * `"thread_type_match"`.
  * `"error_edit_time_expired"`.

---

📎 **Connections**

* **Firestore:** collections `threads`, `posts`, `votes`, `reports`.
* **Routing:** `AppRoute.threadView` for navigation.
* **Providers:** `forum_repository.dart`, `thread_query_builder.dart`.
* **UI:** `ForumScreen`, `NewThreadScreen`, `ThreadViewScreen`, `PostItem`.
* **Docs:** `docs/features/forum_module_plan_hu.md`, previous MVP canvases.

---

✅ **Checklist**

* [ ] Forum list items currently do not open thread detail view (`ThreadViewScreen`).
* [ ] `ThreadViewScreen` always assumes unlocked threads; composer is active even for locked ones.
* [ ] Two divergent rulesets exist: `firebase.rules` and `cloud_functions/firestore.rules`.
* [ ] No initial state query for a user’s vote.
* [ ] No unvote/removal option.
* [ ] Votes count not surfaced in UI.
* [ ] New thread form only supports `general` type.
* [ ] No match/fixture integration; `MarketSnapshotAdapter` unused.
* [ ] UI allows edit icon beyond 15 minutes; Firestore rule rejects, but UI lacks feedback.
* [ ] Model has `quotedPostId` but UI only inserts `@username`.
* [ ] Implemented against `/reports` root collection.
* [ ] Inconsistent with the alternative rules file (subcollections).
* [ ] No “Thread locked” banner.
* [ ] No clear pinned marker in `ThreadView`.
* [ ] No admin UI for pinning/locking threads.
