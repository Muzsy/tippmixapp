# 🥇 Badge rendszer (HU)

Ez a dokumentum a TippmixApp badge (teljesítmény jelvény) rendszerének logikáját és tervezett felépítését írja le.

---

## 🎯 Célja

* Jutalmazni a felhasználókat mérföldkövekért
* Játékos motivációt adni (gamifikáció)
* Badge-ek megjelenítése a profilban

---

## 🧾 Badge típusok (példák)

* 🎯 **Precíz Tippelő** – 3 nyertes szelvény egymás után
* 🧠 **Stratéga** – Nyeremény 4.00+ oddsszal
* 🕓 **Veterán** – 100+ aktív nap
* 🏅 **Első lépés** – Első fogadás megtétele

---

## 📁 Firestore struktúra

Javasolt:

```
users/{uid}/badges/{badgeId}
```

Badge objektum:

```json
{
  "id": "veteran",
  "name": "Veterán",
  "description": "100 nap aktív részvétel",
  "earnedAt": "timestamp"
}
```

* Központi konfig: `badges_config` (kódban vagy Firestore rootban)
* Lokalizált szövegek (ARB vagy kulcs alapján)

---

## 🔁 Értékelés

* Akkor fut: szelvény beküldés, eredmény frissítés, napi belépés
* Központi `BadgeService` végzi a szabály ellenőrzést
* Új badge bekerül: `users/{uid}/badges/`

---

## 🧠 Felhasználói felület

* Profilban megjelennek megszerzett + rejtett badge-ek
* Új badge felugró ablakban vagy snackbar-ben jelzett
* Lehet 🔔 jelzés vagy pötty ikon

---

## 🧪 Tesztelés

* Unit teszt: minden badge szabály logikája
* Widget teszt: badge panel megjelenés
* Integrációs teszt: megszerzés folyamata
