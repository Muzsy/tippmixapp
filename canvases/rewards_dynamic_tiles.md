# Rewards – Weekly Streak & Dynamic Tiles – Sprint 9

## Overview

Revamp the **RewardsScreen** to show a **Weekly Streak Tracker** and dynamic reward tiles that adapt to user progress, aiming to boost daily engagement with tipping challenges.

## Context

* *Motivation*: Audit §6 reveals users unaware of streak bonuses; TippCoin economy under‑utilized.
* New Cloud Function delivers `streakDays` and `nextReward` in `/users/{uid}/stats` doc.

## Objectives

1. Display **Weekly Streak Progress Bar** (0–7) with animated increment on daily login.
2. Show dynamic reward tiles (daily, weekly, special) sorted by eligibility.
3. Claim button triggers `claimReward` Cloud Function and updates balance.
4. Fire `reward_claimed` analytics with `rewardId` & `type`.

## User Stories

| Role          | Story                                               |
| ------------- | --------------------------------------------------- |
| Habit‑builder | *“I want to keep my 7‑day streak for extra coins.”* |
| Casual user   | *“Highlight which reward I can claim now.”*         |

## Functional Requirements

| ID   | Requirement                                                      | Priority |
| ---- | ---------------------------------------------------------------- | -------- |
| RW-1 | Progress bar increments if `lastLogin` within 24 h               | P1       |
| RW-2 | Dynamic tile list sorted: claimable → in‑progress → locked       | P1       |
| RW-3 | Claim button disabled if not eligible; on success shows confetti | P1       |
| RW-4 | Live TippCoin balance update                                     | P1       |
| RW-5 | Local notification at 22:00 if streak at risk                    | P2       |

## Non‑functional Requirements

* Animation ≤120 ms frame; confetti ≤4 MB.
* Unit‑test coverage ≥90 %.

## Acceptance Criteria

1. After 7 consecutive days, streak resets and bonus awarded.
2. Claimable tile moves to claimed state immediately.
3. Balance updates in header.
4. Scheduled local notif triggers on emulator.

## Out of Scope

* Monthly mega rewards.

## Dependencies

* `provider`, `rive` for confetti.

## Testing & QA Notes

* Widget: progress bar animation.
* Service: claimReward flow.
* Integration: login 7 days loop.

## References

* `Funkcionalis Bovitese Audit.pdf`
* `codex_docs/testing_guidelines.md`
