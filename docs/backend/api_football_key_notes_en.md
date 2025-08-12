# API_FOOTBALL_KEY setup

- GitHub Secrets: `API_FOOTBALL_KEY`
- Firebase Functions config: `firebase functions:config:set apifootball.key="<SECRET>"`
- The key becomes available in the Cloud Functions environment as `process.env.API_FOOTBALL_KEY` (loaded by the deploy pipeline).
- Do not log or print the key in any logs.
