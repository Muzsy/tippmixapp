# Infra – Terraform hibajavítás **(v3 – aktuális tippmixapp.zip)**

## Kontextus

A 2025‑08‑07-én feltöltött, friss **tippmixapp.zip** `infra/` mappájának valódi állapota alapján három blokkoló hiba akadályozza a `terraform apply` futását:

| # | Fájl                                                                     | Talált hiba                                                                                                                                                          | Várt / helyes megoldás                                                                                 |
| - | ------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| 1 | `scheduler_jobs.tf` (3 db `google_cloud_scheduler_job`)                  | Hiányzik a kötelező **`region`** vagy **`location`** attribútum → `Error: Missing required argument`                                                                 | Adj hozzá `region = var.region` mindegyik job‑hoz.                                                     |
| 2 | `monitoring_alert.tf` – `google_logging_metric.remaining_credits_metric` | `metric_descriptor.metric_kind` **GAUGE** típusúra állítva, de a *logs‑based* metrikák csak **DELTA**/**CUMULATIVE** lehetnek → `Error 400: Unsupported metric kind` | Állítsd `metric_kind = "DELTA"`‑ra **vagy** töröld a teljes `metric_descriptor { … }` blokkot.         |
| 3 | (opcionális) `notification_channel.tf`                                   | Struktúra rendben ( `auth_token`, `channel_name`, `team` ), de az üres `slack_webhook_url` futtatáskor hibát okozhat.                                                | A Codex patch nem módosítja, de README‑ben jelezd: futtatáskor add át nem üres tokent / vagy count =0. |

## Cél (Goal)

`terraform apply` legyen **zöld** dev & prod környezetben; a **match\_finalizer** Cloud Function trigger‑lánc (Scheduler → Pub/Sub → Cloud Function) hibamentesen működjön.

## Feladatlista

* [ ] **Scheduler-jobok** – add hozzá `region = var.region` mindhárom job resource‑hoz.
* [ ] **Monitoring metrika** – cseréld `metric_kind = "GAUGE"`‑t **"DELTA"**‑ra a `metric_descriptor` blokkban.
* [ ] Futtasd `terraform fmt`, `terraform validate` lokálisan.
* [ ] Ellenőrizd, hogy `terraform apply -auto-approve` dev & prod zöld.

## Done Definition / Acceptance Criteria

* [ ] `terraform validate` / `terraform apply` errors = 0.
* [ ] Cloud Scheduler jobok létrejönnek **europe‑west1** régióban.
* [ ] Logs‑based metrika sikeresen létrejön, AlertPolicy beáll.
* [ ] CI *Backend Deploy* workflow zöld.

## Hivatkozások

* Codex goal YAML: `/codex/goals/infra_terraform_fix_v3.yaml`
* Kapcsolódó audit: *Infra Fix Summary.pdf*, *TippmixApp audit 2025\_08\_02.md*
