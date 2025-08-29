# Migration Plan: Case-insensitive, unique nicknames

## Goal
Ensure nicknames are unique in a case-insensitive way (e.g., "Jani" ≡ "jani"). Make nickname the primary display/lookup handle. Display name (full name) remains optional on profile.

## Data Model
- users/{uid}
  - nickname: String (preserve case, for display)
  - nicknameNormalized: String (lowercased + trimmed, for uniqueness)
  - displayName: String (optional full name)
- usernames/{nicknameNormalized}
  - ownerUid: String (uid of the claimant)
  - createdAt: timestamp

Rationale: Firestore has no native unique constraint. A reservation document keyed by the normalized nickname enables atomic uniqueness guarantees.

## Write Path (New)
1) On nickname set/change:
   - Compute `norm = normalize(nickname)` → lowercase, trim, collapse spaces, remove diacritics (optional, see below).
   - Execute a transaction/callable CF:
     - If user already owns the current reservation (usernames/{oldNorm}), allow switching to {norm} in a single atomic flow.
     - Create `usernames/{norm}` with `ownerUid = uid` IFF it does not exist.
     - Update `users/{uid}.nickname = nickname` and `.nicknameNormalized = norm`.
     - If switching from old nickname, delete `usernames/{oldNorm}`.
   - On conflict (doc exists with different owner), return “nickname taken”.

2) Registration:
   - Require nickname, validate via the same reservation mechanism before creating the profile.

## Read Path
- UI shows `nickname` (original case).
- Queries/filters/search use `nicknameNormalized` or `usernames/*` when appropriate.

## Normalization Strategy
- Baseline: `toLowerCase().trim().replaceAll(RegExp(r"\\s+"), " ")`.
- Optional diacritics folding for HU/DE names (recommended): map accented characters to ASCII for the normalized key (e.g., `á→a, ö→o, ü→u`). Implement in one place to keep consistent.

## Security Rules (Sketch)
```
match /databases/{db}/documents {
  function isOwner(uid) { return request.auth != null && request.auth.uid == uid; }

  // Reservation collection
  match /usernames/{norm} {
    allow create: if isOwner(request.resource.data.ownerUid)
                  && !exists(/databases/$(db)/documents/usernames/$(norm));
    allow read: if true; // public availability checks
    allow update, delete: if resource.data.ownerUid == request.auth.uid;
  }

  match /users/{uid} {
    allow update: if isOwner(uid)
      && (request.resource.data.nicknameNormalized == null
          || exists(/databases/$(db)/documents/usernames/$(request.resource.data.nicknameNormalized))
          && get(/databases/$(db)/documents/usernames/$(request.resource.data.nicknameNormalized)).data.ownerUid == uid);
    allow create: if isOwner(uid);
    allow read: if isOwner(uid) || !(resource.data.isPrivate == true);
  }
}
```
Notes:
- Rules prevent creating two reservations with the same key and ensure user writes are aligned with the claimed key.
- Final enforcement still relies on client/CF transaction to avoid TOCTOU race.

## Migration Phases
1) Prepare (safe to deploy)
   - Add `nicknameNormalized` field support in app schemas (read optional).
   - Add `usernames` collection support in backend (CF callable or client txn).
   - Add security rules stanza (behind a feature flag if needed).

2) Backfill
   - Script/CF: iterate all `users`, compute `norm`, write `nicknameNormalized` if missing.
   - For each user create `usernames/{norm}` if not exists; on conflict:
     - Choose a conflict resolution policy: append numeric suffix (`norm-2`, `norm-3`, …) or mark `requiresNicknameChange = true` and notify the user.
     - Log conflicts to a report for manual follow-up.

3) Cutover
   - Update app nickname validation to check `usernames/{norm}` existence instead of collectionGroup query by `nickname`.
   - Write both fields (nickname, nicknameNormalized) and the reservation in one operation.
   - Switch all UI searches/filters to `nicknameNormalized` as needed.

4) Cleanup
   - Remove legacy nickname uniqueness checks based on case-sensitive queries.
   - Keep backfill idempotent runnable.

## Backfill Implementation Options
- Node.js script (preferred for control):
  - Batches of 200; uses Admin SDK.
  - Writes `nicknameNormalized` and attempts reservation create with retries.
  - Emits CSV report of conflicts.
- CF Admin task (on-demand HTTPS callable restricted to admins) if running from CI.

## App Changes Summary
- Registration Step 2: nickname mandatory; validate uniqueness via usernames/{norm}.
- Profile Edit (when added): nickname change uses reservation flow.
- Profile reads: prefer nickname; displayName remains optional full name.
- Stats/search: use normalized key.

## Observability & Monitoring
- Log reservations creates/deletes in CF.
- Metric: conflicts during backfill; conflicts in runtime nickname changes.
- Alert if conflict rate > threshold (unexpected).

## Rollback Plan
- If reservation introduces issues, disable usernames flow in app via feature flag and revert to case-sensitive query temporarily.
- Keep `nicknameNormalized` field; it is harmless read‑only.
- Delete `usernames/*` only if fully decommissioned.

## Risks & Mitigations
- Conflict during backfill → choose deterministic resolution + user notification.
- TOCTOU race → enforce via transaction/CF callable; rules assist.
- Diacritics mapping disagreements → define a single normalization lib used by app + scripts.

## Indexes
- Likely not required for `usernames/*` (keyed by id). Optional index on `users.nicknameNormalized` for sorting/searching.

## CI Tasks
- Add rules tests for usernames/* create/update/delete and users/* nicknameNormalized alignment.
- Add unit test for normalization utility.

