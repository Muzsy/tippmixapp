# CF deploy hibák javítása – régiódrift + Secret ütközés + healthcheck

🎯 **Funkció**
A legutóbbi deploy több hibával megállt:

* `match_finalizer(europe-central2)` frissítés: **Secret ütközés** – `API_FOOTBALL_KEY` már létező **nem‑secret** env‑változóként be volt állítva a Cloud Run szolgáltatáson, miközben a kód **secretként** próbálja csatolni.
* `coin_trx`, `daily_bonus`, `claim_daily_bonus`, `onFriendRequestAccepted` (us‑central1): **Container Healthcheck failed** + régió **us‑central1** – ez régiódriftre utal: a v2 global options **későn** fut le (import‑sorrend), így az ezekben a modulokban definiált v2 triggerek a **default (us‑central1)** régióban jönnek létre.
* A log szerint az `onUserCreate` v1/Gen1 is keveredik. A forráskódban a v2 `identity.onUserCreated` szerepel, ami a korábbi vitától függetlenül **megbízhatóbban** v1 `auth.user().onCreate()`-re cserélendő.

🧠 **Fejlesztési részletek**

1. **Secret ütközés feloldása**
   A `match-finalizer` Cloud Run szolgáltatáson korábban kézzel (gcloud) beállított **nem‑secret** env‑változó maradt vissza `API_FOOTBALL_KEY` néven. A Firebase deploy most secretet szeretne ugyanazzal a névvel felcsatolni → 400: *“Secret environment variable overlaps non secret environment variable”*. Megoldás: a régi **nem‑secret** env törlése ( `--update-env-vars API_FOOTBALL_KEY-` ).

2. **Régiódrift / import‑sorrend**
   A `setGlobalOptions({ region: 'europe-central2' ... })` hívás az `index.ts` **importok után** fut, ezért a `coin_trx.logic.ts`, `friend_request.ts`, `src/bonus_claim.ts`, `src/daily_bonus.ts` által **deklarált** v2 triggerek még a default régióban (us‑central1) regisztrálódnak. Megoldás: külön `global.ts` bootstrap modul, amely **elsőként** importálódik minden funkciómodulban, és beállítja a globális opciókat + (ha kell) a secreket.

3. **Auth trigger stabilizálása**
   A v2 `identity.onUserCreated` helyett egységesen v1 `functions.auth.user().onCreate()`-t használunk (a projektben minden más marad v2‑ben). Ez stabil, és nem hoz be extra blocking hook‑logikát.

🧪 **Tesztállapot**

* Build: `cd cloud_functions && npm ci && npm run build` zöld.
* Ellenőrzés: a buildelt `lib/index.js`‑ben minden v2 trigger **europe-central2** régióban jön létre; nincs `us-central1` megjelenés.
* Deploy: a titok‑ütközés törlése után a deploy átmegy; a korábbi healthcheck hibák megszűnnek (nem dől el modulbetöltéskor).

🌍 **Lokalizáció**
Nem érint fordítási kulcsokat.

📎 **Kapcsolódások**

* Bonus Engine – Firestore Tárolási Terv (v1)
* Tippmix App – User‑centrikus Firestore Architektúra (összefoglaló)
* **Log bizonyíték**: a feltöltött logban látszik a Secret ütközés és a us‑central1 régióra történő create; erre épül a javítás.
