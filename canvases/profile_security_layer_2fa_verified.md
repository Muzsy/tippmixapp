# Profile – Security Layer (2FA + Verified Badge) – Sprint 7

## Overview

Introduce optional **Two‑Factor Authentication (2FA)** and grant a blue **Verified Badge** to users who successfully complete the security flow. The badge will be displayed next to the display name across the app (Profile header, Leaderboard, Comments).

## Context

* *Security Gap*: Audit §4.2 flagged missing MFA; single‑factor auth raises account‑takeover risk.
* *Trust Signal*: UX research shows users perceive verified badges as credibility boosters.

## Objectives

1. Allow users to enable 2FA via SMS or TOTP (Authy/Google Authenticator).
2. Store 2FA status (`twoFactorEnabled: bool`) and `verifiedAt: Timestamp?` in `UserModel`.
3. Show verification badge if `verifiedAt` != null.
4. Update login flow to require OTP when 2FA enabled.

## User Stories

| Role        | Story                                                            |
| ----------- | ---------------------------------------------------------------- |
| High‑roller | *“I want extra protection for my account balance.”*              |
| New user    | *“Seeing a badge next to a tipster reassures me they’re legit.”* |

## Functional Requirements

| ID    | Requirement                                                           | Priority |
| ----- | --------------------------------------------------------------------- | -------- |
| SEC‑1 | Security Settings tile on Profile → opens **SecurityScreen**          | P1       |
| SEC‑2 | 2FA enable wizard (method select → verify → backup codes)             | P1       |
| SEC‑3 | Persist `twoFactorEnabled`, `twoFactorType`, `totpSecret` (encrypted) | P1       |
| SEC‑4 | Display `VerifiedBadge` widget next to displayName everywhere         | P1       |
| SEC‑5 | On login with 2FA: prompt OTP; 3 wrong attempts lock for 5 min        | P1       |
| SEC‑6 | Analytics event `2fa_toggle` with `method` and `enabled`              | P2       |

## Non‑functional Requirements

* WCAG AA (focus traps, OTP input semantics).
* Cryptographically secure secret generation.
* Unit‑test coverage ≥90 %.
* `flutter analyze` clean.

## Acceptance Criteria

1. Enabling 2FA sends SMS/TOTP and confirms code within 60 s.
2. Login with 2FA enabled refuses wrong OTP, accepts correct; session persists.
3. Badge visible in Leaderboard list tile for verified users.
4. Backup codes generate 10 one‑time tokens downloadable as txt.

## Out of Scope

* Biometric auth (handled by OS, later sprint).

## Open Questions

* Should badge require ID verification in addition to 2FA?
* How to revoke TOTP secret on reset?

## Dependencies

* `firebase_auth` multi‑factor, `otp` pkg.

## Testing & QA Notes

* Widget test: toggle 2FA → badge appears.
* Service test: verifyOtp returns true on valid code.
* Integration: full enable‑login cycle.

## References

* `codex_docs/testing_guidelines.md`
* `codex_docs/routing_integrity.md`
