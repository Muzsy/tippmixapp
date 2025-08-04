# Cloud Scheduler – **scheduler-jobs-task**

## Kontextus

A `result-check` Pub/Sub topic már létezik (pubsub-topics-task). Most három Cloud Scheduler jobot kell definiálnunk, hogy a meccs‑kiértékelő pipeline időzítetten fusson.

| Job név                 | Cron                      | Céltopic       | Payload                        | Környezet‑függő?                |
| ----------------------- | ------------------------- | -------------- | ------------------------------ | ------------------------------- |
| **kickoff-tracker-job** | `${KICKOFF_TRACKER_CRON}` | `result-check` | `{ "job": "kickoff-tracker" }` | igen (dev/prod cron különbözik) |
| **result-poller-job**   | `${SCORE_POLL_CRON}`      | `result-check` | `{ "job": "result-poller" }`   | igen                            |
| **final-sweep-job**     | `${SCORE_SWEEP_CRON}`     | `result-check` | `{ "job": "final-sweep" }`     | igen                            |

A cron stringeket **nem kódba írjuk**, hanem a környezeti változókból (`env.settings.*`) töltjük be, így dev/prod között konfigurációval váltható.

## Feladatok

* [ ] Terraform erőforrások a három Scheduler jobhoz.
* [ ] Mindegyik Pub/Sub‑ra küld, `data` mezője a fenti JSON‑payload Base64‑elve.
* [ ] IAM: a Scheduler service‑account kapjon *pubsub.publisher* jogot (implicit, terraform handle‑li).
* [ ] Unit‑teszt, ami regexszel megnézi, hogy mindhárom job deklarálva van a TF‑fájlban, és a topicjuk `result-check`.

## Acceptance Criteria

* `terraform validate` warning‑mentes.
* Jest‑teszt zöld.
* Cron stringek a **variables.tf**‑ből vagy locals‑ból jönnek, nem hard‑code‑oltak.

## Függőségek

* **pubsub-topics-task** – a topicnak léteznie kell.
* **env-setup-task** – cron‑változók rendelkezésre állnak.

---

*README/memo:* A `match_finalizer` Cloud Function majd a payload alapján eldönti, milyen alműveletet futtasson (kickoff‑tracker vs result‑poller vs sweep).
