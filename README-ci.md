# CI/CD Secrets
Add the following secrets to the GitHub repository:
| Name | Description |
|------|-------------|
| **GCLOUD_SERVICE_KEY_DEV** | JSON key for dev service account with Cloud Functions & Terraform perms |
| **GCLOUD_PROJECT_ID_DEV** | GCP project ID for dev |
| **GCLOUD_SERVICE_KEY_PROD** | JSON key for prod service account (restricted apply) |
| **GCLOUD_PROJECT_ID_PROD** | GCP project ID for prod |
| **ODDS_API_KEY** | The same key stored in `.env` locally |
| **SLACK_WEBHOOK_URL** | Incoming webhook for alert & deploy notifications |
