# 🔔 Értesítések központ (NotificationCenterScreen)

A NotificationCenterScreen egy központi eseménykezelő felület, ahol a felhasználó áttekintheti az aktív értesítéseket, például jutalmakat, kihívásokat, badge‑eket, barátkéréseket és üzeneteket【742591530855780†L0-L17】.

## 🌟 Funkció

* A képernyő `/notifications` útvonalon érhető el, és a jobb felső sarokban elhelyezett NotificationBell ikonról nyílik meg【742591530855780†L10-L17】.
* A különféle értesítések típusokra vannak csoportosítva (jutalom, badge, barátkérés), és kattintás esetén a megfelelő képernyőre navigálnak (pl. `RewardsScreen`, `BadgeScreen`)【742591530855780†L12-L18】.

## 🧠 Felépítés

* **NotificationModel** – leírja az értesítések adatait (id, típus, cím, leírás, időbélyeg, olvasottság)【742591530855780†L21-L29】.
* **NotificationService** – Firestore streamet nyit a felhasználó értesítéseire (`users/{userId}/notifications`), kezeli az olvasottság frissítését, és új értesítés generálását【742591530855780†L21-L31】.
* **NotificationBell widget** – az AppBarban elhelyezett ikon, amely piros jelzőszámot mutat az olvasatlan értesítések számára és navigál a NotificationCenterScreen‑re【742591530855780†L34-L38】.

## 🧪 Tesztállapot

Widget tesztek ellenőrzik a lista megjelenését és a helyes útvonalnavigációt, a service tesztek pedig az olvasottsági állapot mentését és a stream működését【742591530855780†L42-L46】.

## 🌍 Lokalizáció

Az értesítésekhez tartozó lokalizációs kulcsok (`menuNotifications`, `notificationTitle`, `notificationEmpty`, stb.) az ARB fájlokban definiáltak【742591530855780†L49-L64】.

## 📎 Modul hivatkozások

- `NotificationBellWidget` – appbar elem.
- `notification_service.md` és `notification_model.md` – modulok a `modules/` mappában.
- Navigációs célok: `rewards_screen.md`, `badge_screen.md`, `friends_screen.md`.