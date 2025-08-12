# 📈 Odds Drift Prompt (EN)

This document describes the frontend dialog that warns users when bet odds change before finalizing a ticket.

## 📝 Overview

- Compares previous `oddsSnapshot` values with fresh odds from ApiFootballService.
- If difference exceeds the configurable threshold, a dialog lists the changes.
- Users may accept the new odds or cancel the ticket submission.

## Localization & Accessibility

- Dialog title and buttons use `AppLocalizations` for EN/HU/DE strings.
- Action buttons are wrapped with `Semantics` and `Tooltip` to aid screen readers.
