# Infra – Terraform hibajavítás **(v2 – tényleges forrás alapján)**

## Kontextus

A *tippmixapp* `infra/` könyvtárának valós Terraform‑fájljait átnézve (l. `scheduler_jobs.tf`, `monitoring_alert.tf`, `notification_channel.tf`) a következő blocker hibák jelentkeznek:

| Fájl                      | Hiba                                                                                                                                              | Terraform hibaüzenet (rövid)                  |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| `scheduler_jobs.tf`       | `topic_name = google_pubsub_topic.result_check.name` → csak a topic rövid neve, de a Scheduler a teljes `projects/<id>/topics/<name>` URI‑t várja | *"Invalid topic name"* (400)                  |
| `monitoring_alert.tf`     | `value_extractor` kulcs GAUGE/INT64 metrikánál nem támogatott a provider 5.x-ben                                                                  | *"value\_extractor is not allowed for GAUGE"* |
| `notification_channel.tf` | Slack `labels` blokkban `token` kulcson érkezik a webhook, de az elvárt kulcs `auth_token`                                                        | *"Unsupported label key token"*               |

## Cél (Goal)

`terraform apply` dev **és** prod környezetben hiba nélkül lefusson, így a Cloud Function **match\_finalizer** ütemezési lánca (Scheduler → Pub/Sub → CF) működőképes legyen.

## Teendők

* [ ] **Scheduler topic javítása** – mindhárom jobban cseréld `google_pubsub_topic.result_check.name` → `google_pubsub_topic.result_check.id` (teljes URI‑t adja vissza).
* [ ] **Monitoring metric** – töröld a `value_extractor` sort az `google_logging_metric.remaining_credits_metric` erőforrásból.
* [ ] **Slack notification** – a `labels` blokkban nevezd át `token` → `auth_token`; opcionálisan add meg a `channel_name`, `team` kulcsokat.
* [ ] Futtasd `terraform fmt`, `terraform validate` – ne adjon hibát.

## Done Definition / Acceptance Criteria

* [ ] `terraform validate` és `terraform apply -auto-approve` zöld mindkét env‑ben.
* [ ] Scheduler jobok létrejönnek és a Pub/Sub topic `result-check` URI-t használják.
* [ ] `google_logging_metric.remaining_credits_metric` GAUGE metrika sikeresen létrejön.
* [ ] Slack notification channel ACTIVE státuszban a Console‑on.
* [ ] CI pipeline *Deploy Backend* workflow sikeres.

## Hivatkozások

* Codex goal YAML: `/codex/goals/infra_terraform_fix_v2.yaml`
