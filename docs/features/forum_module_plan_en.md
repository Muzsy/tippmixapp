# 💬 Forum Module Plan (EN)

This document defines the design and vision for the forum feature in TippmixApp.

---

## 🎯 Purpose

* Allow users to discuss matches, tips, and trends
* Support social interaction in the app
* Enable thread-style conversation

---

## 📁 Firestore Structure (suggested)

```
threads/{threadId}
  → title, createdBy, createdAt, tags
threads/{threadId}/posts/{postId}
  → content, userId, createdAt, upvotes
```

---

## ✏️ Content Types

* Text posts
* Reactions / upvotes (later)
* Reply support (optional threading)

---

## 🔐 Permissions

* Only logged-in users can post
* Editable by author for 15 min (planned)
* Moderation via `role` field in UserModel (future)

---

## 📱 UI Concept

* ForumScreen with thread list
* ThreadViewScreen with all posts
* NewThreadScreen for posting
* WYSIWYG editor (basic)

---

## 🔁 Backend Logic

* Basic spam filter (length, profanity)
* Post count per user stored in profile (e.g. for badges)
* Optional: pinned threads or featured discussions

---

## 🧪 Testing

* Form validation tests
* Pagination in thread view
* Write-permission logic