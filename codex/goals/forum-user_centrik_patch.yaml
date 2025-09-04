# Forum – User‑centrikus kiegészítések (Firestore + Rules) – commit‑kész patch (2025‑09‑04)

> Cél: a korábbi **Forum Firestore Adatmodell + Rules** patch **kiegészítése** a user‑centrikus architektúra szerint. Új per‑user kollekciók: **relations/follows**, **notifications**, opcionálisan **forum\_prefs**, **forum\_stats**. A globális `threads/posts/votes/reports` változatlan.

---

## 1) Új Dart modellek (user‑centrikus ág)

### `lib/features/forum/domain/user_follow.dart`

```diff
*** Begin Patch
*** Add File: lib/features/forum/domain/user_follow.dart
+import 'package:cloud_firestore/cloud_firestore.dart';
+
+/// Követés egy targetre (user/thread/fixture)
+class UserFollow {
+  final String id; // doc id (pl. targetId)
+  final String targetType; // 'user' | 'thread' | 'fixture'
+  final String targetId; // uid | threadId | fixtureId
+  final DateTime createdAt;
+
+  const UserFollow({
+    required this.id,
+    required this.targetType,
+    required this.targetId,
+    required this.createdAt,
+  });
+
+  Map<String, dynamic> toMap() => {
+        'targetType': targetType,
+        'targetId': targetId,
+        'createdAt': Timestamp.fromDate(createdAt),
+      };
+
+  static UserFollow fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
+    final d = doc.data() ?? <String, dynamic>{};
+    return UserFollow(
+      id: doc.id,
+      targetType: (d['targetType'] ?? '').toString(),
+      targetId: (d['targetId'] ?? '').toString(),
+      createdAt: _toDateTime(d['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
+    );
+  }
+
+  static DateTime? _toDateTime(dynamic v) {
+    if (v is Timestamp) return v.toDate();
+    if (v is DateTime) return v;
+    return null;
+  }
+}
+
*** End Patch
```

### `lib/features/forum/domain/user_notification.dart`

```diff
*** Begin Patch
*** Add File: lib/features/forum/domain/user_notification.dart
+import 'package:cloud_firestore/cloud_firestore.dart';
+
+/// Per‑user értesítés (@mention, reply, followed thread activity)
+class UserNotification {
+  final String id; // doc id
+  final String type; // 'mention' | 'reply' | 'thread_activity'
+  final String threadId;
+  final String? postId; // lehet null thread‑activity esetén
+  final String? actorUid; // ki váltotta ki
+  final bool read;
+  final DateTime createdAt;
+
+  const UserNotification({
+    required this.id,
+    required this.type,
+    required this.threadId,
+    this.postId,
+    this.actorUid,
+    required this.read,
+    required this.createdAt,
+  });
+
+  Map<String, dynamic> toMap() => {
+        'type': type,
+        'threadId': threadId,
+        if (postId != null) 'postId': postId,
+        if (actorUid != null) 'actorUid': actorUid,
+        'read': read,
+        'createdAt': Timestamp.fromDate(createdAt),
+      };
+
+  static UserNotification fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
+    final d = doc.data() ?? <String, dynamic>{};
+    return UserNotification(
+      id: doc.id,
+      type: (d['type'] ?? '').toString(),
+      threadId: (d['threadId'] ?? '').toString(),
+      postId: d['postId']?.toString(),
+      actorUid: d['actorUid']?.toString(),
+      read: (d['read'] ?? false) == true,
+      createdAt: _toDateTime(d['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
+    );
+  }
+
+  static DateTime? _toDateTime(dynamic v) {
+    if (v is Timestamp) return v.toDate();
+    if (v is DateTime) return v;
+    return null;
+  }
+}
+
*** End Patch
```

### (Opcionális) `lib/features/forum/domain/user_forum_prefs.dart`

```diff
*** Begin Patch
*** Add File: lib/features/forum/domain/user_forum_prefs.dart
+/// Per‑user fórum beállítások (mute, default filters)
+class UserForumPrefs {
+  final List<String> mutedLeagues; // ligaId-k
+  final List<String> mutedThreads; // threadId-k
+  final String defaultTab; // 'tips' | 'comments' | 'poll'
+
+  const UserForumPrefs({
+    this.mutedLeagues = const [],
+    this.mutedThreads = const [],
+    this.defaultTab = 'tips',
+  });
+
+  Map<String, dynamic> toMap() => {
+        'mutedLeagues': mutedLeagues,
+        'mutedThreads': mutedThreads,
+        'defaultTab': defaultTab,
+      };
+
+  static UserForumPrefs fromMap(Map<String, dynamic>? m) {
+    final d = m ?? <String, dynamic>{};
+    return UserForumPrefs(
+      mutedLeagues: (d['mutedLeagues'] as List?)?.cast<String>() ?? const [],
+      mutedThreads: (d['mutedThreads'] as List?)?.cast<String>() ?? const [],
+      defaultTab: (d['defaultTab'] ?? 'tips').toString(),
+    );
+  }
+}
+
*** End Patch
```

---

## 2) Security Rules kiegészítése a `users/{uid}` ághoz

### `firestore.rules` (append a korábbi patch végéhez)

```diff
*** Begin Patch
*** Update File: firestore.rules
@@
   match /databases/{database}/documents {
@@
+    // === User‑centrikus fórum kiegészítések ===
+    match /users/{uid} {
+      // A user csak a saját ágát olvashatja/írhatja, kivéve admin/mod (moderációs esetek, értesítés fan‑out)
+      allow read, write: if request.auth != null && request.auth.uid == uid;
+      allow read, write: if isModerator();
+
+      // Követések: /users/{uid}/relations/follows/{targetId}
+      match /relations/{relDoc}/follows/{targetId} {
+        allow read, create, update, delete: if request.auth != null && request.auth.uid == uid;
+        allow read, write: if isModerator();
+      }
+
+      // Értesítések: /users/{uid}/notifications/{id}
+      match /notifications/{id} {
+        // Olvasás saját maga; írás tipikusan CF vagy mod által – de engedjük a user‑oldali read‑flag frissítést
+        allow read: if request.auth != null && request.auth.uid == uid;
+        allow update: if request.auth != null && request.auth.uid == uid && request.resource.data.diff(resource.data).changedKeys().hasOnly(['read']);
+        allow create, delete: if isModerator();
+      }
+
+      // Opcionális beállítások: /users/{uid}/forum_prefs/{doc}
+      match /forum_prefs/{doc} {
+        allow read, create, update, delete: if request.auth != null && request.auth.uid == uid;
+        allow read, write: if isModerator();
+      }
+
+      // Opcionális statisztika cache: /users/{uid}/forum_stats/{doc}
+      match /forum_stats/{doc} {
+        allow read, create, update, delete: if request.auth != null && request.auth.uid == uid;
+        allow read, write: if isModerator();
+      }
+    }
   }
 }
*** End Patch
```

---

## 3) (Opcionális) Indexek – per‑user olvasásokhoz

### `firestore.indexes.json` (add vagy patch – ha létezik más tartalom, a Codex merge‑elje)

```diff
*** Begin Patch
*** Add File: firestore.indexes.json
+{
+  "indexes": [
+    {
+      "collectionGroup": "posts",
+      "queryScope": "COLLECTION",
+      "fields": [
+        {"fieldPath": "threadId", "order": "ASCENDING"},
+        {"fieldPath": "createdAt", "order": "DESCENDING"}
+      ]
+    },
+    {
+      "collectionGroup": "threads",
+      "queryScope": "COLLECTION",
+      "fields": [
+        {"fieldPath": "fixtureId", "order": "ASCENDING"},
+        {"fieldPath": "type", "order": "ASCENDING"},
+        {"fieldPath": "createdAt", "order": "DESCENDING"}
+      ]
+    },
+    {
+      "collectionGroup": "notifications",
+      "queryScope": "COLLECTION",
+      "fields": [
+        {"fieldPath": "threadId", "order": "ASCENDING"},
+        {"fieldPath": "createdAt", "order": "DESCENDING"}
+      ]
+    }
+  ],
+  "fieldOverrides": []
+}
*** End Patch
```

> Ha már van projekt‑szintű `firestore.indexes.json`, ezt **merge‑elni** kell (a Codex patch lépése úgy készüljön, hogy *nem* írja felül a meglévő indexeket).

---

## 4) Mini repo‑jegyzet (könyvtárak + kollekciók)

### `docs/reports/forum_usercentric_NOTES.md`

```diff
*** Begin Patch
*** Add File: docs/reports/forum_usercentric_NOTES.md
+# Fórum – user‑centrikus kiegészítések

## Per‑user kollekciók
- `users/{uid}/relations/follows/{targetId}` – targetType: user|thread|fixture
- `users/{uid}/notifications/{id}` – type: mention|reply|thread_activity; read flag kliensről frissíthető
- (opcionális) `users/{uid}/forum_prefs/{doc}` – muted ligák/threads, default tab
- (opcionális) `users/{uid}/forum_stats/{doc}` – lightweight cache a kliensnek

## Indexek
- posts by threadId + createdAt DESC
- threads by fixtureId,type + createdAt DESC
- notifications by threadId + createdAt DESC (collectionGroup)

## Biztonság
- A saját `users/{uid}` ág írása/olvasása csak a usernek; általános kivétel: **isModerator()**.
- Értesítések létrehozása tipikusan **Cloud Functions** feladata; a kliens csak a `read` mezőt frissíti.
*** End Patch
```

---

## 5) Javasolt Codex‑step (beilleszthető a meglévő YAML végére)

```yaml
- name: Forum – user‑centrikus kiegészítések
  description: |
    Add per‑user collections (relations/follows, notifications, optional prefs/stats), extend firestore.rules accordingly,
    and add minimal indexes for notifications. Generate models and a short NOTES doc.
  outputs:
    - lib/features/forum/domain/user_follow.dart
    - lib/features/forum/domain/user_notification.dart
    - lib/features/forum/domain/user_forum_prefs.dart
    - firestore.rules
    - firestore.indexes.json
    - docs/reports/forum_usercentric_NOTES.md
```

---

### Elfogadási kritériumok

* `flutter analyze` hibamentes a hozzáadott Dart fájlokra.
* `firebase emulators:start --only firestore` alatt a szabályok:

  * saját `users/{uid}` alatt **írás/olvasás OK**;
  * más `uid` alatt **tiltás**;
  * `notifications.read` mező **user által frissíthető**; létrehozás **tiltott** a kliensnek;
  * moderátor tokennel mindenhol engedélyezett műveletek.
* Index deploy nem ütközik meglévő beállításokkal.
