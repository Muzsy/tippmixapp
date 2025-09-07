# 🎨 TippmixApp → Tipsterino — Rebrand Canvas

## 🎯 Funkció

A projekt teljes átnevezése **TippmixApp** → **Tipsterino** márkanévre, úgy, hogy sem jogi, sem technikai ütközés ne maradjon. Cél a név, az ikonok, a bundle/csomagnév, a szövegek, a linkek, a store‑meták és a közösségi/Patreon felületek egységesítése. A váltás közben a meglévő funkciók **nem sérülhetnek**.

## 🧠 Fejlesztési részletek

* **Kód & build‑azonosítók**

  * Flutter projekt: `pubspec.yaml` → `name: tipsterino`, app display name.
  * Android: `applicationId` → `com.tipsterino.app` (Gradle); package nyomok frissítése; `strings.xml` app\_name.
  * iOS: `CFBundleName`, `PRODUCT_BUNDLE_IDENTIFIER` → `com.tipsterino.app`.
  * Ikon/splash: `flutter_launcher_icons`, `flutter_native_splash` konfiguráció frissítése, új assetek.
* **Szöveg & UI**

  * Minden felhasználó felé látható „TippmixApp” string csere „Tipsterino”-ra (címek, AppBar, About, README‑k, changelog, in‑app linkek).
  * „Nem igazi pénzes szerencsejáték” diszklémer egyértelműsítése.
* **Backend / Firebase (ha használod)**

  * Bundle‑azonosító változása miatt *külön* Firebase app azonosítók (dev/prod). Offline emulátor mód esetén csak a lokális configokra figyelj.
* **Store & marketing**

  * Google Play Console: új appbejegyzés Tipsterino néven; leírás, grafika, privacy‑policy URL.
  * Domain: `tipsterino.com` / `tipsterino.app` (legalább az egyik), átirányítások, privacy‑policy statikus oldal.
  * Patreon oldal: „Tipsterino” brand, tier‑ek, üdvözlő poszt, béta‑teszt csatorna leírás.
* **Tesztelés és kiadás**

  * Belső/zárt teszt csatornák: Patreon email lista alapján hozzáférés.
  * Minimális regresszió: unit + widget tesztek futtatása (coverage nélkül), fő user‑flow kézi ellenőrzése.

## 🧪 Tesztállapot

* **Min. elvárás:** buildelhető debug/relase (Android), app név és ikon mindenhol frissült; fő képernyők működnek; régi névre hivatkozó stringek nincsenek.
* **Automata:** meglévő unit + widget tesztek futnak; CI‑ben coverage **nélkül** (korábbi projektelvárás szerint).
* **Kézi ellenőrző lista:** splash → home → szelvénykezelés → profil/beállítások → lokál nyelvváltás → hibaüzenetek → külső linkek (privacy, Patreon) nyílnak.

## 🌍 Lokalizáció

* Nyelvek: HU/EN/DE. Új kulcs: `app_name = Tipsterino`. Ellenőrizd, hogy a név **nem** kerül fordításra; a brand minden nyelven „Tipsterino”.
* „Nem szerencsejáték” figyelmeztetés HU/EN/DE külön kulcs alatt.

## 📎 Kapcsolódások

* Google Play Console regisztráció (fejlesztői fiók, app‑bejegyzés).
* Patreon (tier + béta teszt leírás; zárt Discord/Telegram).
* Domain + Privacy Policy + Support e‑mail (pl. `support@tipsterino.com`).

---

# 🧾 Patreon tier‑struktúra (Tipsterino)

* **Supporter – 2 € / hó**: heti dev‑update, kulisszák mögötti poszt.
* **Beta Tester – 5 € / hó**: zárt tesztcsatorna (belső/zárt track), korai funkciók, changelog.
* **Insider – 10 € / hó**: roadmap‑szavazás, név a támogatói falon, havi Q\&A.

Üdvözlő poszt minta címe: *„Bemutatkozik a Tipsterino – közösségi sporttipp app (nem valódi pénzzel)”*.

---

# ✅ Átadás / Done kritériumok

* Új app‑azonosítók és megjelenített név minden platformon.
* Új ikon/splash az appban és a store‑assetek között.
* Szövegek, linkek, diszklémerek frissítve.
* Belső teszt build feltöltve; 5–10 tesztelő meghívva (Patreon lista alapján).
