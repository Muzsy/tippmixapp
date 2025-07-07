# Notification Center v2 – Sprint 9

## Overview

Upgrade the existing **Notification Center** with category filtering, swipe‑to‑archive, rich previews (image/cta), and local caching for offline viewing to increase engagement with delivered notifications.

## Context

* *Audit finding*: Users see an undifferentiated list; hard to find tips vs. system alerts.
* *Backend*: Cloud Functions now include `category` and `previewUrl` fields in payloads (see `docs/fcm_schema_v2.md`).

## Objectives

1. Introduce **Category Tabs** (All, Tips, Social, Rewards, System) with badge counts.
2. Implement swipe left → archive & undo snackbar.
3. Render image preview if `previewUrl` provided.
4. Persist last 50 notifications locally (Hive box) for offline access.

## User Stories

| Role         | Story                                         |
| ------------ | --------------------------------------------- |
| Busy bettor  | *“Show me only tips, hide system spam.”*      |
| Badge‑hunter | *“Clear my badge count quickly via Archive.”* |

## Functional Requirements

| ID   | Requirement                                       | Priority |
| ---- | ------------------------------------------------- | -------- |
| NC-1 | Category filter tabs with live badge counts       | P1       |
| NC-2 | Swipe‑to‑archive, undo within 5 s                 | P1       |
| NC-3 | Rich preview card with image & CTA button         | P1       |
| NC-4 | Local cache last 50, purge FIFO                   | P1       |
| NC-5 | Notification tap deep‑links to destination screen | P1       |
| NC-6 | Analytics `notif_opened` with `category`          | P2       |

## Non-functional Requirements

* Smooth tab switch ≤150 ms.
* WCAG AA (labels, hit areas).
* Unit‑test coverage ≥90 %.

## Acceptance Criteria

1. Tabs correctly filter categories.
2. Archived notification disappears and badge decrements.
3. Offline mode shows cached list.
4. Preview image loads lazy with shimmer placeholder.

## Out of Scope

* Push subscription management (handled Sprint 6).

## Dependencies

* `hive` ≥2, `pull_to_refresh`.

## Testing & QA Notes

* Widget: swipe archive.
* Integration: receive FCM→ deep‑link.
* Golden: preview card states.

## References

* `Screen Development Priority.pdf`
* `codex_docs/testing_guidelines.md`
