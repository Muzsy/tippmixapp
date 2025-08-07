# Infra – Slack notification opcionálissá tétele (dev)

## Kontextus

* Dev környezetben jelenleg nincs Slack Bot-token → a **google\_monitoring\_notification\_channel.slack** resource `labels.auth_token` üres, ezért a `terraform apply` hibára fut.
* Production launchkor (Go‑Live) viszont szükségünk lesz a Slack-riasztásokra.

## Cél

* **Dev/staging**: `terraform apply` zöld legyen token nélkül.
* **Prod**: a Slack notification channel változtatás nélkül bekapcsolható, ha `slack_webhook_url` változóba token kerül.

## Megoldás

1. **`variables.tf`** – állítsunk be üres alapértelmezést:

   ```hcl
   variable "slack_webhook_url" {
     type        = string
     description = "Slack Bot User OAuth token (xoxb-…). Leave empty to disable Slack notification in non‑prod."
     default     = ""
   }
   ```
2. **`notification_channel.tf`** – tegyük feltételessé a resource‑ot:

   ```hcl
   resource "google_monitoring_notification_channel" "slack" {
     count        = var.slack_webhook_url == "" ? 0 : 1  # only create if token provided
     display_name = "Slack – #alerts"
     type         = "slack"
     labels = {
       auth_token   = var.slack_webhook_url
       channel_name = "alerts"
       team         = "tippmixapp"
     }
   }
   ```

## Done Definition

* [ ] `terraform validate` és `terraform apply` zöld token nélkül.
* [ ] Prod környezetben token beállításával a resource létrejön, állapota **ACTIVE**.

## Következő lépés (Go‑Live)

* Generálj Slack Bot‑tokent (ld. *Slack-webhook beállítás* leírás).
* Állítsd be `slack_webhook_url` → CI Secret vagy terraform.tfvars(prod).

## Codex goal YAML

* `/codex/goals/infra_slack_optional.yaml`
