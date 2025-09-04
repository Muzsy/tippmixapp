# Fórum – user-centrikus kiegészítések

## Per-user kollekciók
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
