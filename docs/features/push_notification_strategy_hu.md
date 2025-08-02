# 🔔 Push értesítési stratégia (HU)

Ez a dokumentum a TippmixApp push értesítéseinek bevezetési tervét foglalja össze.

---

## 🎯 Célja

- Értesítések küldése fontos eseményekről
- Felhasználók aktivitásának növelése
- Visszatérési arány javítása

---

## 🔧 Használt eszközök

- **Firebase Cloud Messaging (FCM)**
- `firebase_messaging` Flutter csomag
- Backend: Cloud Functions (értesítés küldéshez)

---

## 📋 Értesítéstípusok

- ✅ Fogadás eredménye: „Szelvényed nyert/elveszett!”
- 🏆 Új badge: „Új badge megszerezve!”
- 🔔 Inaktivitás: „Hiányoztál! Nézz vissza!”
- 📈 Heti összefoglaló (tervezett)
- 💬 Fórum válasz (jövőben)

---

## 📱 UI és élmény

- `NotificationIcon`: olvasatlan jelzés
- Első indításkor engedélykérés
- Értesítésre kattintva megnyílik a kapcsolódó képernyő (szelvény, badge, fórum)

---

## 🔐 Biztonság / adatvédelem

- Csak a szerver küldhet értesítést
- Payloadban nincs személyes adat
- Token tárolható a user profilban (opcionális)

---

## 🧪 Tesztelés

- Firebase Emulator Suite helyi próbához
- `flutter_local_notifications` a foreground megjelenítéshez
- Teljes folyamat tesztelése: küldés + fogadás + megjelenítés
