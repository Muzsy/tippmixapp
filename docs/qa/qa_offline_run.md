# QA Offline Run — Checklist

- Login with `user@example.com` / `Passw0rd!` (Auth emulator)
- Create a ticket with at least 2 tips (pending expected)
- Trigger finalizer: call callable `force_finalizer` (inline mode enabled)
- Verify ticket status updates (win/lost/void) and payout
- Verify avatar list/download from Storage emulator
- Verify RC-dependent UI (login variant) shows default A

Artifacts
- Screenshots: docs/qa/images/* (not committed here)
- Parity report: docs/qa/offline_parity_report.md
