# Interactive Onboarding – Sprint 8

## Overview

Deliver a **multi‑step interactive onboarding** sequence after first login to teach new users the core actions (placing bets, tracking rewards, following tipsters) using animated highlights and lightweight quizzes.

## Context

* *Retention*: Funnel in *Tippmixapp Screens Summary §5* shows 37 % D1 retention; onboarding is currently a static slideshow many users skip.
* *Tech*: `introduction_screen` package used but lacks interactivity.

## Objectives

1. Create **OnboardingFlowScreen** with 3 interactive pages, each requiring a lightweight interaction to continue.
2. Persist `onboardingCompleted=true` in `UserModel` and skip flow on future launches.
3. Allow users to **Skip** at any time → fire `onboarding_skipped` analytics.
4. Launch flow automatically after successful login if not yet completed.

## User Stories

| Role           | Story                                              |
| -------------- | -------------------------------------------------- |
| New bettor     | *“Show me how to place my first bet.”*             |
| Returning user | *“Don’t show onboarding again once I’ve seen it.”* |

## Functional Requirements

| ID    | Requirement                                                                | Priority |
| ----- | -------------------------------------------------------------------------- | -------- |
| ONB-1 | OnboardingFlowScreen with 3 required interactions (tap, drag, yes/no quiz) | P1       |
| ONB-2 | Persist completion flag and timestamp                                      | P1       |
| ONB-3 | Skip button visible at top‑right                                           | P1       |
| ONB-4 | Fire analytics `onboarding_completed` or `onboarding_skipped`              | P1       |
| ONB-5 | Localize all instructional text                                            | P1       |

## Non‑functional Requirements

* Animations at 60 fps (use `rive` or `lottie` ≤4 MB total).
* Unit‑test coverage ≥90 %.
* `flutter analyze` clean.

## Acceptance Criteria

1. First login shows onboarding; subsequent launches bypass.
2. Interactions cannot be bypassed except via Skip.
3. Analytics events recorded with `duration` param.
4. Golden tests pass on devicePixelRatio 2 & 3.

## Out of Scope

* Personalized onboarding tips (future work).

## Open Questions

* Should we store progress mid‑flow to resume if app closed?
* Dark‑mode asset variants?

## Dependencies

* `lottie` ≥3, `provider` state management.

## Testing & QA Notes

* Widget: interaction enables Next.
* Integration: login → onboarding → main screen.
* Golden: each stage.

## References

* `Tippmixapp Screens Summary.pdf`
* `codex_docs/testing_guidelines.md`
