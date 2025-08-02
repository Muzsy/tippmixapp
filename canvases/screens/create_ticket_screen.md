# 🎫 Fogadószelvény létrehozás (CreateTicketScreen)

Ez a vászon a fogadószelvény véglegesítésére és beküldésére szolgáló képernyőt írja le.  A `CreateTicketScreen` lehetővé teszi a felhasználóknak, hogy megadják a tétet, áttekintsék az aktuálisan kiválasztott tippeket, majd a szelvényt a megfelelő azonosítással menthessék el【985473509556952†L2-L4】.

## 🎯 Funkció

- **Tét megadása** – a felhasználó TippCoin összeg megadásával fogadhat【985473509556952†L2-L4】.
- **Szelvény előnézet** – a képernyő felsorolja a kiválasztott tippeket és azok adatait (meccs, odds, stb.).
- **Mentés** – a `submitTicket()` művelet a `BetSlipService` segítségével véglegesíti a szelvényt【985473509556952†L6-L9】.  A jelenlegi megoldás FirebaseAuth‑ből kéri le a `uid`‑t; Codex audit alapján javasolt a `authProvider` használata a konzisztens állapotkezeléshez【985473509556952†L10-L14】.

## 🧠 Felépítés

- A képernyő `ConsumerStatefulWidget`, Riverpod alapú állapotfigyeléssel【985473509556952†L6-L8】.
- Az autentikációs ág javasolt módosítása:

```dart
final user = ref.watch(authProvider);
if (user == null) {
  // UI hibaüzenet, ne engedjük a mentést
} else {
  submitTicket(user.uid, …);
}
```

- Az űrlap validációt végez a tét mezőn, és hiba esetén figyelmeztető üzenetet jelenít meg.

## 🧪 Tesztállapot

Jelenleg nincsenek widget tesztek; javasolt unit teszt a sikeres és sikertelen mentésre, valamint az autentikáció hiányának kezelésére【985473509556952†L16-L21】.

## 🌍 Lokalizáció

A hibaüzenetek lokalizált kulcsokkal (`errorNotLoggedIn`, stb.) jelennek meg【985473509556952†L22-L25】.

## 📎 Modul hivatkozások

- `auth_provider.md` – a bejelentkezett felhasználó azonosítása.
- `bet_slip_service.dart` – a fogadószelvény elmentésének logikája.
- Codex szabályzat: `auth_best_practice.md`, `service_dependencies.md`, `codex_context.yaml`【985473509556952†L27-L32】.
