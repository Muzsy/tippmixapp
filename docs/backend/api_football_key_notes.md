# API_FOOTBALL_KEY beállítása

- GitHub Secrets: `API_FOOTBALL_KEY`
- Google Secret Manager: hozz létre `API_FOOTBALL_KEY` titkot
- Adj **Secret Manager Secret Accessor** jogosultságot a Functions runtime service accountnak
- A kulcsot kódban a `defineSecret('API_FOOTBALL_KEY')` köti be, így futásidőben a `process.env.API_FOOTBALL_KEY` változóban érhető el
- Ne logold és ne írd ki a kulcsot semmilyen naplóba.
