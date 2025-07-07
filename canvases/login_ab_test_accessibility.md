# Login UX – A/B Test & Accessibility Audit – Sprint 8

## Overview

Run a controlled **A/B experiment** on the login flow (Control vs **Variant B: Split‑Screen promo layout**) and simultaneously fix all WCAG 2.1 AA accessibility issues in the authentication screens.

## Context

* *Conversion*: Audit §1.3 shows a 12 % drop‑off at email/password step.
* *Accessibility*: `flutter analyze --enable-experiment=accessibility-review` revealed 14 contrast & semantics violations.
* Remote Config and Analytics SDKs are already initialized project‑wide but unused here.

## Objectives

1. Fetch `login_variant` ("A"|"B") from **Firebase Remote Config**; cache for 28 days.
2. Render **Variant B** that features a right‑side promo panel with brand image & “Trusted by 50 000+” copy.
3. Track exposure (`login_variant_exposed`) and conversion (`login_success`) analytics with `variant` param.
4. Fix all reported accessibility issues (contrast, semantics labels, focus order) in both variants.

## User Stories

| Role            | Story                                            |
| --------------- | ------------------------------------------------ |
| Product Owner   | *“I want to know which layout converts better.”* |
| Low‑vision user | *“All text must have sufficient contrast.”*      |
| New bettor      | *“The promo panel convinces me to register.”*    |

## Functional Requirements

| ID    | Requirement                                                            | Priority |
| ----- | ---------------------------------------------------------------------- | -------- |
| LUX-1 | Fetch `login_variant` from Remote Config on app start; default "A"     | P1       |
| LUX-2 | Render **Variant B** split‑screen when variant=="B"                    | P1       |
| LUX-3 | Fire `login_variant_exposed` (once per install)                        | P1       |
| LUX-4 | Fire `login_success` with `variant` param on successful auth           | P1       |
| LUX-5 | Fix contrast ratios to ≥4.5:1; add semantics for form fields & buttons | P1       |
| LUX-6 | Provide manual override via Debug Menu                                 | P2       |

## Non‑functional Requirements

* Variant selection must be **deterministic** per‑device until cleared.
* Offline mode: default to variant "A".
* ≥90 % test coverage; `flutter analyze` clean.

## Acceptance Criteria

1. 10 000 simulated sessions split 50/50 (±2 %) between variants.
2. Screen reader announces "Login, Email, Password" correctly.
3. Contrast checker passes all elements on WCAG AA.
4. Analytics dashboard shows separate funnels for variants.

## Out of Scope

* Multi‑variant (>2) experiments.
* Registration flow (handled Sprint 9).

## Open Questions

* Should we bucket by userId or deviceId?
* Do we force logout on variant switch?

## Dependencies

* `firebase_remote_config` ≥4, `firebase_analytics` ≥11.

## Testing & QA Notes

* Widget test: variant switch renders correct widget tree.
* Integration: simulate exposure + login; verify analytics hits via debug view.
* Accessibility audit: run `flutter_a11y_report` script.

## References

* `Jelentes Login Register Screen Bovites.pdf`
* `codex_docs/testing_guidelines.md`
* `codex_docs/routing_integrity.md`
