# Odds-api Integráció – MVP Canvas

## 🎯 Funkció

Az MVP-ben az OddsAPI-ból érkező sportesemény- és odds-adatok képezik a fogadási logika alapját. Csak élő, valós adatot fogadunk el, mock vagy statikus adat kizárt. A felhasználó csak azokat az eseményeket láthatja és azokra fogadhat, amelyeket az OddsAPI ténylegesen szolgáltat. A fogadási szelvény minden eleme kizárólag odds-api adatokon alapul, a fogadás pillanatában befagyasztott odds-al.

*Fontos*: A befagyasztott odds-on történő fogadás csalásmegelőzés és átláthatóság szempontjából is elengedhetetlen.

## 🧠 Fejlesztési részletek

### Adatmodell

- **Szelvény (Ticket)**: több *bet* elemet tartalmazhat.
- **Bet mezők**:
  - `match_id`: OddsAPI esemény azonosító
  - `bookmaker`: fogadóiroda azonosító
  - `market_key`: piac azonosító
  - `selection`: választott kimenetel azonosító
  - `odd`: az adott pillanatban rögzített odds
  - `[point]`: opcionális érték, például hendikep
  - `status`: pending, won, lost, void
  - `evaluated_at`: lezárás időpontja

Minden adat az OddsAPI-ból érkezik, a kiválasztott esemény és piac szerint. Fogadás rögzítése előtt mindig az aktuális odds-ot kell lekérni (submitTicket workflow), a szelvénybe az épp aktuális odds érték kerül. Az odds a fogadás után nem változik, minden eredmény- és kifizetés-számítás a rögzített odds alapján történik.

#### Adattárolás

- Szelvény és TippCoin adatok: Firestore-ban
- Historikus elemzés (tervezett): BigQuery-ben

#### API-kulcs és biztonság

- Az OddsAPI kulcs semmilyen módon nem kerülhet kliensoldali kódba.
- Kulcs: `.env` vagy *backend proxy* (pl. Cloud Functions) segítségével használható.
- Ingyenes kvóta figyelése, cache-elés, hibakezelés kötelező.

#### Statusz kezelés

- Minden "bet" állapota külön frissül (pending/won/lost/void)
- Szelvény aggregált státusz: a benne lévő fogadások alapján kerül meghatározásra

#### Fejlesztési javaslatok

- OddsAPI proxy endpoint bevezetése (akár már MVP-ben), hogy később is skálázható maradjon a rendszer, és az API kulcs sose kerüljön ki frontendre.
- Polling interval, rate limit stratégiák (pl. 30 mp-enként frissítés, 429-es válaszok kezelése)
- Fogadási workflow: szekvencia-diagram vagy folyamatábra készítése ajánlott.
- Service-ek, provider-ek és widgetek listázása: OddsApiService, TicketService, BetService, OddsApiProvider, EventScreen, TicketScreen stb.

### Adatmodell – példa

```dart
class Bet {
  final String matchId;
  final String bookmaker;
  final String marketKey;
  final String selection;
  final double odd;
  final double? point;
  final BetStatus status; // enum: pending, won, lost, void
  final DateTime? evaluatedAt;
}
```

## 🧪 Tesztállapot

- Az MVP-ben kizárólag élő OddsAPI adatokból generálható fogadás/szelvény, mock/stub adat használata tilos.
- Minden "bet" pontosan az OddsAPI válaszait tükrözi.
- Szelvény létrehozása: odds frissítése → rögzítés → Firestore mentés.
- Kiértékelés: esemény lezárása után, OddsAPI vagy manuális input alapján.
- Adatvesztés, hibás API válasz vagy eltűnt esemény esetén a bet VOID státuszba kerülhet.
- Widget- és unit-tesztek minden kritikus workflow-ra (szelvény létrehozás, TippCoin tranzakciók, API-hibák kezelése) kötelezőek.
- Tesztkörnyezet sandbox API kulccsal; error handling tesztesetek: timeout, rate limit, rossz válasz, eltűnt esemény.

## 🌍 Lokalizáció

- Minden piac, kimenetel, odds az eredeti OddsAPI kulcson jelenik meg.
- Fordítás MVP-ben nem kötelező, de enum-alapú lokalizáció előkészítése ajánlott, hogy később egyszerű legyen bővíteni.
- AppLocalization vagy hasonló enum előkészítése a piac- és kimenetel-kulcsokra.

## 📎 Kapcsolódások

- **Esemény- és odds-lista**: OddsAPI integráció (OddsApiService, OddsApiProvider)
- **Fogadási szelvény**: Ticket és Bet adatmodell, minden adat OddsAPI-ból
- **TippCoin**: fogadási tét és kifizetés virtuális egyenleggel, tranzakciók Firestore-ban
- **Eredményfrissítés**: OddsAPI-ból vagy manuális input alapján (pl. admin panel)
- **Biztonság**: OddsAPI kulcs kezelése, Firestore security rules
- **Tesztelhetőség**: minden kritikus workflow widget- és unit-teszttel ellenőrizhető
- **Historikus elemzés** (tervezett): BigQuery

## 💬 Kiegészítő magyarázat

A jelen vászon minden MVP-hez szükséges szempontot rögzít: kizárólag élő OddsAPI-adat használata, kulcs biztonságos kezelése, workflow-k, tesztelési és adatmodellezési alapelvek. A projekt továbbfejlesztéséhez, auditálásához vagy új fejlesztők belépéséhez ajánlott a folyamatábrák, konkrét endpoint listák, valamint a service- és provider-kapcsolatok pontos dokumentálása.
