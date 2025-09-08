# 💬 Forum Module Plan (EN)

This document defines the design and vision for the forum feature in TippmixApp.

---

## 🎯 Purpose

- Allow users to discuss matches, tips, and trends
- Support social interaction in the app
- Enable thread-style conversation

---

## 📁 Firestore Structure (suggested)

```
threads/{threadId}
  → title, createdBy, createdAt, tags, lastActivityAt, postsCount
threads/{threadId}/posts/{postId}
  → content, userId, createdAt, upvotes
```

---

## ✏️ Content Types

- Text posts
- Reactions / upvotes (later)
- Reply support (optional threading)

---

## 🔐 Permissions

- Only logged-in users can post
- Editable by author for 15 min (planned)
- Moderation via `role` field in UserModel (future)

---

## 📱 UI Concept

- ForumScreen with thread list
- ThreadViewScreen with all posts
- NewThreadScreen for posting
- WYSIWYG editor (basic)

---

## 🔁 Backend Logic

- Basic spam filter (length, profanity)
- Post count per user stored in profile (e.g. for badges)
- Thread aggregates: update `lastActivityAt` and `postsCount` on post create/delete
- Optional: pinned threads or featured discussions
- MarketSnapshotAdapter caches ApiFootball odds snapshots for the composer

---

## 📇 Query → Index Mapping

| Query | Firestore index |
| --- | --- |
| Threads by fixture | `(fixtureId ASC, type ASC, createdAt DESC)` |
| Posts by thread | `(threadId ASC, createdAt DESC)` |
| Votes by entity | `(entityType ASC, entityId ASC, createdAt DESC, userId ASC)` |
| Reports by status | `(status ASC, createdAt DESC)` |
| Pinned threads by activity | `(pinned ASC, lastActivityAt DESC)` |
| Pinned threads newest | `(pinned ASC, createdAt DESC)` |
| Threads by type latest | `(type ASC, lastActivityAt DESC)` |
| Threads by type newest | `(type ASC, createdAt DESC)` |

---

## ✅ Implemented

- ForumScreen with thread list, filters and sort
- NewThreadScreen for creating threads (validates fields and navigates to thread view on success)
- Firestore security rules for threads, posts, votes and reports
- Central routing with ThreadViewScreen and composer
- Forum list FAB navigates to NewThreadScreen
- Bottom navigation entry for forum
- threadDetailControllerProviderFamily export
- Auth UID wired for thread/post creation; JSON payloads limited to rule-allowed fields
- ThreadViewScreen post actions (reply, edit, delete, upvote, report) with error handling
- Locked thread banner and composer disabled
- Infinite scroll and pagination for thread lists and posts with duplicate prevention
- Centralized query builder for filter/sort combinations
- Composite Firestore indexes aligned with queries

## 🧪 Testing

- Form validation tests
- Pagination in thread view
- Write-permission logic
- Expanded security rules tests for mismatched IDs, disallowed fields, and unauthenticated actions
