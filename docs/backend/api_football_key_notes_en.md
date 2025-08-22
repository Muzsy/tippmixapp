# API_FOOTBALL_KEY setup

- GitHub Secrets: `API_FOOTBALL_KEY`
- Google Secret Manager: create secret `API_FOOTBALL_KEY`
- Grant the Functions runtime service account the `roles/secretmanager.secretAccessor` role
- The key is bound in code via `defineSecret('API_FOOTBALL_KEY')` and becomes available at runtime as `process.env.API_FOOTBALL_KEY`
- Do not log or print the key in any logs.
