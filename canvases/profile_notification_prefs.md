# Profile – Notification Preferences (Sprint 6)

## Overview

Enable granular push‑notification topic control from the **Profile** screen so every user can decide which pushes they want to receive and which they don’t.

## Context

*Pain‑point highlighted in* **Funkcionális Bővítése Audit §3.4** *and* `/docs/user_feedback.md` → users describe some notifications as "spam‑like". No UI or backend field exists yet for per‑topic preferences.

## Objectives

* CRUD notification preference categories *(tips, friend‑activity, badge, rewards, system)*.
* Persist state to `UserModel.notificationPreferences` (Firestore document, `Map<String,bool>`).
* Live toggle feedback; disabled topics suppress downstream FCM.

## User Stories

1. **Casual bettor** → *"I only want big‑win tips, not every offer."*
2. **Privacy‑conscious user** → *"Let me silence friend‑activity pushes."*
3. **Rewards hunter** → *"Keep rewards alerts on while muting others."*

## Functional Requirements

| ID    | Requirement                                            | Priority |
| ----- | ------------------------------------------------------ | -------- |
| NPF‑1 | Add `notificationPreferences` map to `UserModel`       | P1       |
| NPF‑2 | Create `NotificationPreferencesTile` widget, 5 toggles | P1       |
| NPF‑3 | Extend `UserService.patchPreferences()`                | P1       |
| NPF‑4 | Localised labels (HU/EN/DE)                            | P1       |
| NPF‑5 | Fire analytics event `notif_pref_changed`              | P2       |

## Non‑functional Requirements

* WCAG 2.1 AA; screen‑reader friendly switch labels.
* ≥90 % unit‑test coverage on new code.
* `flutter analyze` passes with 0 issues.

## Acceptance Criteria

* Toggling “Tips” **off** prevents a simulated "Tip" FCM in ≤5 min.
* Preferences persist after logout/login cycle.
* Golden screenshot matches Figma spec on pixel‑ratio 3 device.
* ARB keys exist and validated by l10n‑CI.

## Out of Scope

* Custom notification sounds per topic.
* Email notification settings.

## Open Questions

* Should “System” topic be mandatory (non‑toggle)?
* Versioning of preference schema for future topics.

## Dependencies

* `firebase_messaging` ≥14.
* Localization ARB pipeline.

## Testing & QA Notes

* Widget test: toggle → Firestore update.
* Service test: patchTraces correct path.
* Integration: full flow with mock FCM.
* Golden: default state.

## References

* `codex_docs/testing_guidelines.md`
* `codex_docs/routing_integrity.md`
* `docs/notification_design_spec.pdf`
