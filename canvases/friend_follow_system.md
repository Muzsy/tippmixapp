# Social Layer – Friend & Follow System – Sprint 7

## Overview

Add social connectivity by enabling users to **follow** others (one‑way) or send **friend requests** (mutual). This lays the groundwork for future social feed features and increases user engagement.

## Context

* *Engagement Opportunity*: Audit §5 shows drop‑off after bet placement; social features can boost retention.
* Backend Firestore rules already namespace `/relations/{uid}` for friendship docs but unused.

## Objectives

1. Implement following (one‑click) and friending (request/accept) mechanics.
2. Display follower count & Follow/Unfollow button on Profile & Leaderboard tiles.
3. Add **FriendsScreen** listing mutual friends.
4. Push notification on accepted friend request.

## User Stories

| Role             | Story                                                   |
| ---------------- | ------------------------------------------------------- |
| Competitive user | *“I want to follow top tipsters to see their streaks.”* |
| Casual bettor    | *“I’d like to friend my mates and compare scores.”*     |

## Functional Requirements

| ID    | Requirement                                                                                     | Priority |
| ----- | ----------------------------------------------------------------------------------------------- | -------- |
| SOC‑1 | `followUser(targetUid)` mutation; toggle instantly                                              | P1       |
| SOC‑2 | `sendFriendRequest(targetUid)`; `acceptFriendRequest(requestId)`                                | P1       |
| SOC‑3 | Render Follow button on `UserTile` (Profile, Leaderboard)                                       | P1       |
| SOC‑4 | `FriendsScreen` with search & pending tab                                                       | P1       |
| SOC‑5 | Firestore structure: `/relations/{uid}/followers/{followerUid}` & `/friendRequests/{requestId}` | P1       |
| SOC‑6 | Push notif `friend_request_accepted`                                                            | P2       |

## Non‑functional Requirements

* Realtime subscription using `StreamBuilder`.
* Privacy: default followers = public; friends list visible only if mutual.
* Unit‑test coverage ≥90 %.
* `flutter analyze` clean.

## Acceptance Criteria

1. Tapping Follow toggles state <300 ms (optimistic), reconciles on success.
2. Pending friend requests badge count on Profile header.
3. Accepting request moves both users to friends list.
4. Push received within 5 s after acceptance (using local FCM emulator in tests).

## Out of Scope

* Social activity feed (later sprint).

## Open Questions

* Should follow notifications be opt‑out topic?
* Limit on max friends/followers?

## Dependencies

* Cloud Functions (`onFriendRequestAccepted`) for push.

## Testing & QA Notes

* Widget: FollowButton state changes.
* Service: friend request create/accept docs.
* Integration: send → accept flow with two mock users.

## References

* `codex_docs/testing_guidelines.md`
* `codex_docs/routing_integrity.md`
