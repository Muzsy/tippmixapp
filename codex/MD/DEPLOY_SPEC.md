KONTEKSTUS:
- Alkönyvtár: ~/projects/tippmixapp/cloud_functions
- Elfogadási kritérium: a smoke-teszt utáni logokban NEM szerepel:
  "TypeError: Cannot read properties of undefined (reading 'messageId')".

FELADAT:
1) Stabil build + függőségek.
2) Deploy.
3) Smoke-teszt üzenet publikálása.
4) Friss log olvasása.
5) Ha hiba van, automatikus javítás, majd ismétlés 2–4.

KONKRÉTUMOK:
- PROJECT=tippmix-dev
- REGION=europe-central2
- FUNCTION=match_finalizer
- TOPIC=result-check
- SERVICE_ACCOUNT=match-finalizer@tippmix-dev.iam.gserviceaccount.com

JAVÍTÁSI ESZKÖZTÁR:
- onMessagePublished('result-check', handler) használata.
- Secret olvasás handler-scope-ban.
- package.json: peer-kompatibilis páros (pl. functions 4.9.0 + admin 12.7.0), gcp-build: npm install && npm run build (tsc elérhető).
- Tiszta install (node_modules + lock újra), build.

A VÉGÉN:
- Lépéslista, csomagverziók, és a sikeres logkivonat.
