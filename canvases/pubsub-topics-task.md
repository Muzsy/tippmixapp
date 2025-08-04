# Pub/Sub Infrastructure – **pubsub-topics-task**

## Kontextus

A `match_finalizer` Cloud Function Pub/Sub triggerre fog előfizetni. Ehhez legalább egy téma kell (`result-check`), opcionálisan egy Dead‑Letter Queue (DLQ) a sikertelen üzeneteknek. A projektet Terraformmal menedzseljük, így a témák deklaratív módon kerülnek létrehozásra.

## Cél

* **Hozzunk létre két Pub/Sub topic‑ot** declarative módon:

  1. `result-check`  – fő téma, 7 napos message retention.
  2. `result-check-dlq` – DLQ, szintén 7 nap retention.
* A témák Terraform kóddal legyenek definiálva (`infra/pubsub_topics.tf`).
* Basic egységteszt – ellenőrzi, hogy a .tf fájlban szerepel mindkét topic‑név.

## Feladatok

* [ ] `infra/pubsub_topics.tf` létrehozása a két `google_pubsub_topic` erőforrással.
* [ ] Egységteszt (`infra/test/pubsub_topics.spec.ts`), ami fájl‑szinten ellenőrzi, hogy a resource‑blokkok tartalmazzák a `name = "result-check"` és `name = "result-check-dlq"` sorokat.
* [ ] CI script: `terraform fmt -check` + `terraform validate` (ha Terraform telepítve), majd jest‑tesztek futtatása.

## Acceptance Criteria

* [ ] A TF fájl `terraform validate` futtatáskor hibamentes.
* [ ] Jest teszt zöld, mindkét topicnév megtalálható.
* [ ] CI log jelzi a két resource‑ot a `terraform plan` kimenetben (opcionális, ha plan fut).

## Hivatkozások

* [Terraform Google Provider – Pub/Sub Topic](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic)
* Codex Canvas Yaml Guide (task/goal definíció)
