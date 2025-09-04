# Forum MVP indexes notes

Existing indexes cover forum collections:
- posts: threadId ASC, createdAt DESC
- threads: fixtureId ASC, type ASC, createdAt DESC
- notifications: threadId ASC, createdAt DESC (user-centric)

Run `firebase firestore:indexes:diff` after modifying indexes to ensure remote config is updated.
