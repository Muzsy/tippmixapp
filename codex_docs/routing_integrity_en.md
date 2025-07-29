version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[codex\_context.yaml]

# 🛰️ Routing Integrity Guidelines

> **Purpose**
> Define mandatory patterns and best‑practices for `GoRouter` so navigation remains predictable, testable and deep‑link friendly.

---

## Core Architecture

The app follows a **ShellRoute + nested routes** approach to keep a persistent bottom navigation bar while maintaining independent navigation stacks per tab.

```mermaid
graph LR
  shell(ShellRoute)
  shell --> home[/home]
  shell --> bets[/bets]
  shell --> profile[/profile]
  bets --> betDetail[/bets/:ticketId]
```

---

## Mandatory Rules

1. **Central path constants** – Declare every path in `lib/src/routing/app_route.dart`; never hard‑code strings in widgets.
2. **Named routes only** – Each route must have a `name` matching its `AppRoute` enum value.
3. **Auth guard** – Wrap private stacks with `AuthRedirect()` that sends anonymous users to `/sign‑in`.
4. **Parameter validation** – Reject deep‑links with missing or malformed parameters using `typed_params`.
5. **No wildcard routes** (`*`) – Use an explicit 404 fallback route instead (`/not-found`).
6. **Single‑source query decoding** – All query parsing lives in `RouteData.fromState()`, *not* in UI code.
7. **Unit tests** – Every new route must add at least one test in `test/routing/`.

---

## Quick Checklist

| ✅ Check                | How to verify                                        |
| ---------------------- | ---------------------------------------------------- |
| Path constant exists   | `grep '/new-path' lib/src/routing` returns **1 hit** |
| Deep link opens screen | `flutter test test/routing/new_path_test.dart`       |
| Unauthorized redirect  | Launch deep link in guest mode → Sign‑in view        |

---

## Changelog

| Date       | Author   | Notes           |
| ---------- | -------- | --------------- |
| 2025‑07‑29 | docs‑bot | Initial version |
