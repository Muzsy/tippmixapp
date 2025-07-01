# 👤 ProfileScreen – Publikus/privát logika (UI és megjelenítés)

---

## 🎯 Funkció

A felhasználói profil UI-ban minden, a privacy logikához kapcsolódó elem:
- Minden olyan mezőnél, amely a felhasználói adatmodell szerint priváttá tehető (`fieldVisibility`), jelenjen meg publikus/privát toggle.
- Legyen globális privát profil kapcsoló is. Ha aktív, minden mezőt elrejt a nyilvános nézetből, csak az avatar és a nickname marad látható.
- A profilnézet UI alkalmazza automatikusan a privacy szabályokat:  
  - Saját profilnál minden látható és szerkeszthető.
  - Más profiljának megtekintésekor csak a publikus (vagy ha globális privát aktív, csak avatar+nickname) látható.

---

**Bemenet:**
- `/docs/tippmix_app_teljes_adatmodell.md` – A privacy flag logika, mezőlista, alapmegvalósítás forrása.

---

## 🧠 Fejlesztési részletek

- **Publikus/privát toggle UI minden érintett mezőnél:**  
  - Város, ország, barátlista, kedvenc sport/csapat (bool switch).
- **Globális privát kapcsoló UI:**  
  - Egyetlen kapcsolóval minden extra adatot el lehet rejteni.
- **Profilnézet komponensek:**  
  - `ProfileScreen`: saját adatainak szerkesztése, minden toggle szerkeszthető.
  - `PublicProfileScreen`: más user profilja, csak a privacy szabályok szerint megengedett mezőket jeleníti meg.
- **Megjelenítési logika:**  
  - A privacy mezők beállításai automatikusan befolyásolják a profiloldal publikus nézetét.
  - Globális privát esetén override-olja az összes egyedi mező visibility-t (kivéve avatar+nickname).

---

## 🧪 Tesztállapot

- Minden privacy toggle megfelelően frissíti a UI-t.
- Globális privát kapcsoló elrejti a többi mezőt a publikus nézetben.
- PublicProfileScreen csak a publikusra állított adatokat mutatja, vagy csak avatar+nickname-et.
- Saját profil vs. más profilnézet között a privacy szabályok helyesen érvényesülnek.

---

## 🌍 Lokalizáció

- Új kulcsok:
  - `profile.is_private`: "Privát profil"
  - `profile.public`: "Publikus"
  - `profile.private`: "Privát"
  - `profile.toggle_visibility`: "Mező láthatósága"
  - `profile.global_privacy`: "Globális privát kapcsoló"

---

## 📎 Kapcsolódások

- **UI:** profil szerkesztő, public profil nézet, privacy toggle komponensek.
- **Backend:** privacy flag mezők kiolvasása/mentése (már létező backend mezőkre építve, asset kezelés nélkül).
- **Lokalizáció:** privacy toggle-ok, UI feliratok.
- **Későbbi fázisban:** avatar választó, barátlista, statisztikák, badge-ek megjelenítése.
