# Post-build/deploy emlékeztető
- cd cloud_functions && npm ci && npm run build
- gcloud functions deploy match_finalizer --gen2 --runtime=nodejs20 --region=europe-central2 --trigger-topic=result-check --entry-point=match_finalizer --quiet
- gcloud functions deploy coin_trx --gen2 --runtime=nodejs20 --region=europe-central2 --trigger-http --allow-unauthenticated --entry-point=coin_trx --quiet
- Ellenőrzés: a Firestore Rules a frissített firebase.rules alapján legyen deployolva.
