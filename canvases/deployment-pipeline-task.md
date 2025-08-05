# CI/CD – **deployment-pipeline-task**

## Cél

Automatizált build, teszt és kihelyezés a **tippmixapp** backendjére:

* **Terraform apply** az `infra/` erőforrásokra (Pub/Sub, Scheduler, Monitoring).
* **Cloud Functions deploy** – `match_finalizer` (Node 18).
* **Firebase Hosting / Rules deploy** (opcionális, csak ha van változás).
* **Multi‑env** (dev → prod) GitHub Actions matrix ütközés nélkül.

## Workflow lépcsők

1. **Checkout + cache** Node modulok.
2. **npm ci** a `functions` könyvtárban.
3. **Lint + unit + e2e tesztek** – minden zöld, különben stop.
4. **Terraform init/plan/apply** (dev branch → dev projekt, main → prod projekt).
5. **gcloud functions deploy** `match_finalizer` – `--set-env-vars=$(cat env.settings.${MODE} | xargs)` + `.env` titkos kulcs a GitHub Secrets‑ből (ODDS\_API\_KEY).
6. Slack értesítés siker/hibáról.

## Feladatok

* [ ] **deploy.yml** (`.github/workflows/deploy.yml`) – teljes workflow.
* [ ] **scripts/set-env.sh** – helper a settings-fájl sorainak `key=value` egy sorba illesztéséhez.
* [ ] **README-ci.md** – leírja a szükséges GitHub Secrets-et:

  * `GCLOUD_SERVICE_KEY_DEV`, `GCLOUD_PROJECT_ID_DEV`
  * `GCLOUD_SERVICE_KEY_PROD`, `GCLOUD_PROJECT_ID_PROD`
  * `ODDS_API_KEY`, `SLACK_WEBHOOK_URL`.
* [ ] Unit-teszt (jest regex) – ellenőrizze, hogy a deploy yml tartalmaz `gcloud functions deploy` és `terraform apply` parancsot.

## Acceptance Criteria

* Workflow dev‑branch buildje zöld GitHub‑on.
* `terraform plan` nem interaktív, `-auto-approve` csak dev‑ben, prod‑ban PR‑review szükséges.
* Slack értesítés megjelenik tesztcsatornán.

## Függőségek

* **integration-e2e-task** – tesztek futnak, pipeline‑ban is sikerülnie kell.
