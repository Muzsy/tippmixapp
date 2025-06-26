## 🔔 NotificationCenterScreen – Eseménykezelő képernyő

### 🌟 Funkció

A NotificationCenterScreen egy központi eseménykezelő felület, ahol a felhasználó áttekintheti a rá váró aktív értesítéseket: jutalmak, kihívások, badge-ek, barátkérések, üzenetek.

---

### 🧠 Fejlesztési részletek

* Route: `/notifications`
* AppBar jobb szélén a NotificationBell ikon navigál ide
* Lista títusával csoportosítva vagy egy listaként:

  * Reward értesítés: "Napi bónusz elérhető!"
  * Badge unlock: "Megszerezted a Night Owl jelvényt!"
  * Barátkérés: "Zoli szeretne ismerősöd lenni."
* Kattintható sorok: navigálnak a megfelelő képernyőre (pl. RewardsScreen, BadgeScreen, FriendsScreen)

---

### 🔍 Működési logika

* `NotificationModel`:

  * id, type, title, description, timestamp, isRead
* `NotificationService`:

  * Firestore stream: `users/{userId}/notifications`
  * Olvasottsági állapot frissítése
* Új értesítés: badge, reward, push trigger vagy bármely user event generálja

---

### 🚪 AppBar NotificationBell widget

* Kis piros jelzőszám: összes nem olvasott notification darabszáma
* Riverpod vagy Provider alapú store-ból frissül
* Kattintáskor navigál a NotificationCenterScreen-re

---

### 🧪 Tesztállapot

* Widget teszt: megjelenik-e az értesítések listája, helyes route navigáció
* Service teszt: olvasottság mentése, stream helyes működése

---

### 🌍 Lokalizáció

ARB kulcsok:

```json
{
  "menuNotifications": "Értesítések",
  "notificationTitle": "Események",
  "notificationEmpty": "Nincs új esemény",
  "notificationMarkRead": "Olvasottként jelölés",
  "notificationType_reward": "Jutalom",
  "notificationType_badge": "Jelvény",
  "notificationType_friend": "Barátkérés",
  "notificationType_message": "Üzenet",
  "notificationType_challenge": "Kihívás"
}
```

---

### 📌 Kapcsolódások

* `NotificationBellWidget` → appbar elem
* `notification_service.dart`, `notification_model.dart`
* `rewards_screen.dart`, `badge_screen.dart`, `friends_screen.dart` → navigációs célok
* `routing_integrity.md` → named route
* `localization_logic.md` → kulcskezelés
* `firestore_rules` → users/{userId}/notifications jogosultság
