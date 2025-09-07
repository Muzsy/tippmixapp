# Forum rules test log

```
$ npx firebase emulators:exec --only firestore "npm test -- test/forum.rules.test.ts"
PASS test/forum.rules.test.ts
  forum rules
    ✓ requires auth to create thread (630 ms)
    ✓ blocks post creation in locked thread (165 ms)
```
