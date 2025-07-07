# Profile – Edit Flow (Sprint 6)

## Overview

Complete the **Edit Profile** experience as a dedicated form screen that lets users safely update their public-facing data (display name, avatar, bio, favourite team, etc.) while enforcing validation and accessibility best‑practices.

## Context

The current ProfileScreen only shows static data. *Profile Screen Status Report §2.1* notes that users must email support to change a typo in their display name – a P1 UX pain. The backend already stores the related fields, but there is no in‑app CRUD.

## Objectives

* Provide full‑screen **EditProfileScreen** reachable from the Profile header (pencil icon).
* Sync changes to Firestore document `users/{uid}` via `UserService.updateProfile()`.
* Ensure unique, trimmed display names; allow avatar replacement with crop + compression.
* Maintain deterministic routing (`context.goNamed('editProfile')`).

## User Stories

| Role               | Story                                                  |
| ------------------ | ------------------------------------------------------ |
| Casual bettor      | *“I mistyped my nickname, let me correct it quickly.”* |
| Power user         | *“I want to update my avatar after every big win.”*    |
| Accessibility user | *“The form must be fully screen‑reader friendly.”*     |

## Functional Requirements

| ID    | Requirement                                                                                                                                                                          | Priority |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| EPF‑1 | `EditProfileScreen` with fields: displayName (required, 3–24 chars, unique); avatar upload (crop 1:1); bio (≤160 chars); favouriteTeam (dropdown); dateOfBirth (optional, 18+ guard) | P1       |
| EPF‑2 | Inline validation; `Save` disabled until form is valid **and** dirty                                                                                                                 | P1       |
| EPF‑3 | Persist via `UserService.updateProfile()`; merge patch                                                                                                                               | P1       |
| EPF‑4 | On success: Snackbar *“Profile updated”* and pop back                                                                                                                                | P1       |
| EPF‑5 | Fire analytics `profile_edit` with changed fields list                                                                                                                               | P2       |

## Non‑functional Requirements

* WCAG 2.1 AA (labels, inputs, contrast, focus order).
* ≥95 % unit‑test coverage on new Dart lines.
* `flutter analyze` passes with 0 issues; deterministic diff.

## Acceptance Criteria

1. Duplicate display name shows inline error in ≤300 ms (server check via Cloud Function mock in tests).
2. Avatar >2 MB compressed to <300 KB without visible artefacts (golden comparison diff <0.5 %).
3. Date picker disallows future dates and <18‑year ages.
4. All locale strings present in HU/EN/DE ARBs and pass l10n‑CI.

## Out of Scope

* Changing e‑mail or phone (handled in Auth settings).
* Social link metadata (handled in later sprint).

## Open Questions

* Should we block emojis in display name?
* Should avatar be re‑generated for leaderboard thumbnails or handled lazily?

## Dependencies

* `image_picker` ≥1.1, `image_cropper` ≥5.0, `flutter_form_builder` ≥9.

## Testing & QA Notes

* Widget test: invalid form keeps Save disabled.
* Service test: updateProfile merges only diff fields.
* Integration: happy path edit → FCM token remains intact.
* Golden: avatar picker states.

## References

* `Profile Screen Status Report.pdf`
* `codex_docs/testing_guidelines.md`
* `codex_docs/routing_integrity.md`
