# Mit találtam a most feltöltött zipben

* A kártya **meghívja** az odds lekérdezést: `FutureBuilder(... apiService.getH2HForFixture(int.tryParse(event.id) ?? 0, season: event.season) ...)`.
* A service **helyes URL-t** épít: `GET https://v3.football.api-sports.io/odds?fixture=<id>[&season][&bet=1]` és küldi a `x-apisports-key` fejlécet.
* **Probléma 1 – cache „befagyasztja” a hibát/üres választ:** `getH2HForFixture` a Future-t **mindenképp** elcacheli 60 mp-re. Ha a hívás 401/429/empty miatt `{}`-et kap (vagy kivétel), a kártya **60 mp-ig** újra sem próbálkozik → a UI „Nincs elérhető piac”.
* **Probléma 2 – 429/egyéb státuszra nincs jelzés az odds hívásnál:** a fixtures-nél szépen jelzed a limiteket, az odds-nál **csendben** `{}`-et adsz vissza. A dashboardon emiatt sokszor csak a `v3/fixtures` kéréseket látod, mert az odds-hívás egyszer futott korábban és utána cache-elt üreset – az adott 60 mp-es ablakban már nem indult új hívás.

# Következmény

* A kártyán gyakran „Nincs elérhető piac” látszik, még akkor is, ha egy újrapróba már hozna H2H-t.
* A műszerfalon a „Today Requests” nézetben jellemzően csak a `v3/fixtures` kérések látszanak (az odds ritkán vagy időablakon kívül jelent meg).

# Javítási terv (csak kliensoldal, funkciót nem tör)

1. **No-cache-on-null:** a `getH2HForFixture` csak **sikeres (nem null)** eredményt cache-eljen. Hibát/üreset **ne**.
2. **429/hibakód kezelés az odds hívásnál is:** ha 429 jön, 200 ms késleltetéssel **1× retry**, és add vissza a hibát információval (ne üres `{}` legyen „csendben”).
3. **Debug kliensazonosító + URL log (opcionális, devben):** tegyünk `X-Client: tippmixapp-mobile` fejlécet és `debugPrint`-et a kimenő `/odds` kéréseknél (csak debug), hogy a dashboardon biztosan felismerd a saját hívásaidat.

# Elfogadási kritériumok

* A H2H gombok számai megjelennek, amikor az API ad rá adatot.
* „Nincs elérhető piac” csak akkor jelenik meg, ha **valóban** nincs H2H (nem cache-elt hiba miatt).
* A Codex tesztek zöldek; az odds hívás képes 429-ből felállni.

# Megjegyzés a dashboardról

A `v3/fixtures` kérések most is rendben kimennek (ezt látod a képernyőképen). A `/odds` kérések is kimentek, de az adott 60 mp-es ablakban nem feltétlenül (cache miatt), vagy 429/üres miatt „némán” visszatértek. A lenti patch után újratöltéskor látni fogsz `/v3/odds` sorokat is.
