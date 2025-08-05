# OddsAPI kvótafigyelés – **quota-watcher-task**

## Kontextus

A ResultProvider minden OddsAPI válasznál kiolvassa az `x-requests-remaining` headert és **Cloud Logging**-ba ír:
`[quota] remaining=1234`
Ez a log‑sor képezi az alapját egy felügyelő riasztásnak, ami Slack‑en jelez, ha a kredit a **QUOTA\_WARN\_AT** küszöb alá esik (pl. prod‑on 1 000, dev‑en 50).

## Feladatok

* [ ] **Logs‑based metric** – `remaining_credits` (GAE) regexp: `\[quota] remaining=(\d+)`.
* [ ] **Alert Policy** – `credit_low_alert`, triggerelt ha `remaining_credits < ${QUOTA_WARN_AT}`

  * evaluation\_window: 5 m, 1 m alignment.
* [ ] **Slack notification channel** – Slack WebHook URL titkos (`SLACK_ALERT_URL` in Secret Manager vagy `.env`).
* [ ] **Terraform**: `infra/monitoring_alert.tf` + `infra/notification_channel.tf`.
* [ ] **Test**: jest‐regex, ellenőrzi hogy a TF tartalmazza az alert‑policy nevét és a filtert a metric‑re.

## Acceptance Criteria

* `terraform validate` hibamentes.
* Jest-teszt zöld.
* Notification channel reference helyes a policy‑ban.

## Függőségek

* env‑setup‑task (QUOTA\_WARN\_AT szükséges)
* result‑provider‑task (log‑sor formátum már adott)
