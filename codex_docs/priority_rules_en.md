version: "2025-07-29"
last\_updated\_by: docs-bot
depends\_on: \[]

# 🚦 Priority & Severity Rules

> **Purpose**
> Provide a unified scale so Codex and human developers triage issues the same way, ensuring the most business‑critical bugs are fixed first.

---

## Priority Matrix

| Level  | Label                      | Criteria                                                                                                         | Expected Fix SLA                    |
| ------ | -------------------------- | ---------------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| **P0** | **Critical / App‑blocker** | • Application crashes on launch  <br>• Data loss or corruption  <br>• Security breach with live exploit          | **Immediately** (≤ 2 hours)         |
| **P1** | **High**                   | • Core feature unusable (e.g. cannot place bet)  <br>• No viable workaround  <br>• Performance degradation >50 % | **Within 24 h**                     |
| **P2** | **Medium**                 | • Feature partially broken but workaround exists  <br>• Minor performance issue  <br>• Incorrect translation     | **Next sprint**                     |
| **P3** | **Low**                    | • Cosmetic UI glitch  <br>• Copy change  <br>• Non‑blocking suggestion                                           | **Backlog** (when capacity permits) |

> **Note**: Timeframes reference business hours in the Europe/Budapest timezone.

---

## Workflow Rules

1. **Reporter responsibility** – Tag the ticket with an initial priority (`P?`) based on the matrix above.
2. **Triage meeting** – Product Owner + Tech Lead confirm or adjust the priority within 24 h.
3. **Escalation path** – Any team member may escalate a bug one level up with justification; Tech Lead has final say.
4. **SLA tracking** – CI pipeline auto‑labels PRs that fix `P0/P1` issues; failing SLA triggers a red status in Slack.

---

## Examples

| Scenario                                                  | Mapped Priority | Reason                         |
| --------------------------------------------------------- | --------------- | ------------------------------ |
| Sign‑in screen shows white page on iOS, app unusable      | **P0**          | Blocker, no workaround         |
| Odds refresh freezes for 3‑4 s but betting still possible | **P1**          | Core feature impacted, poor UX |
| Dutch translation for “Stake” is wrong                    | **P2**          | Minor content error            |
| Padding misaligned on Settings icon                       | **P3**          | Purely cosmetic                |

---

### Changelog

| Date       | Author   | Notes                    |
| ---------- | -------- | ------------------------ |
| 2025‑07‑29 | docs-bot | Initial document created |
