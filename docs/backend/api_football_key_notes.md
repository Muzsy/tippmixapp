# API_FOOTBALL_KEY beállítása

- GitHub Secrets: `API_FOOTBALL_KEY`
- Firebase Functions config: `firebase functions:config:set apifootball.key="<SECRET>"`
- A kulcs a Cloud Functions környezetben `process.env.API_FOOTBALL_KEY` változóba kerül (deploy pipeline tölti be).
- Ne logold és ne írd ki a kulcsot semmilyen naplóba.
