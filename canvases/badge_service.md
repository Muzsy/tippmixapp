## 🎯 Funkció

A `badge_service.dart` fájl felelős a badge-ek valós idejű kiosztásáért a TippmixApp alkalmazásban. A szolgáltatás minden olyan esemény után meghívható, amely potenciálisan új badge kiosztását vonhatja maga után.

## 🧠 Fejlesztési részletek

* A szolgáltatás bemenete lehet:

  * szelvény lezárása (pl. nyertes tipp)
  * statisztika változása
  * napváltás esemény (pl. éjfél utáni tét)

* Fő metódusok:

  * `List<BadgeData> evaluateUserBadges(UserStats stats)`

    * Meghatározza, hogy a felhasználó aktuális statisztikái alapján mely badge-eket érdemelte ki
  * `Future<void> assignNewBadges(String userId)`

    * Lekéri az eddigi badge-eket a Firestore-ból
    * Új badge esetén beírja a `badges` kollekcióba

* A `badgeConfigs` lista alapján iterál minden badge-en, és kiértékeli a `BadgeCondition` enumhoz tartozó szabályokat.

* Minden felhasználónak a `/users/{userId}/badges` kollekcióban tárolódnak az elnyert badge-ek (kulcs + timestamp).

## 🧪 Tesztállapot

* Egységtesztek:

  * Minden `BadgeCondition` külön metódusban kiértékelve, tesztelhető input statokkal
  * Új badge elnyerése → Firestore írás mockolva
* A teljes `evaluateUserBadges()` függvény viselkedése tesztelhető `UserStats` példányokkal

## 🌍 Lokalizáció

* A szolgáltatás nem lokalizál közvetlenül, de az UI-nak lokalizált badge-kulcsokat ad vissza.
* Az ikonkezelés és címfordítás a `profile_badge.dart` és az ARB fájlok feladata

## 📎 Kapcsolódások

* `badge_config.dart`: forrás badge lista
* `badge.dart`: modell
* `stats_service.dart`: felhasználói statisztikák
* Firestore: `/users/{userId}/badges` kollekció
* Codex szabályzat: `codex_context.yaml`, `service_dependencies.md`, `priority_rules.md`
* Háttérdokumentum: `tippmix_app_teljes_adatmodell.md`, `auth_best_practice.md`
