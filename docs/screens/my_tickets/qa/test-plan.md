# Tesztterv – MyTickets (Szelvényeim)

## 🧭 Meta

- Képernyő: MyTicketsScreen
- Verzió/Dátum: 2025-08-30
- Felelős: TBD

## 🧪 Teszt típusok

- Unit: `Ticket.fromFirestore` mezőleképezés (`doc.id` → `Ticket.id`).
- Widget: loading/empty/error/data állapotok; kártya‑tap → dialog; pull‑to‑refresh.
- Integration: üres állapot CTA → GoRouter navigáció `AppRoute.bets`.
- Firestore Rules: olvasási jogosultság pozitív/negatív utak `users/{uid}/tickets` alatt (Emulator).

## 📋 Esetek

1. [x] Üres állapot bejelentkezett felhasználóval: megjelenik a CTA gomb (EN: "Submit Ticket").
2. [x] Lista megjelenítése mintatételekkel: `TicketCard` megjelenik n darabban.
3. [x] Pull‑to‑refresh újraolvassa a `ticketsProvider` streamet.
4. [x] Kártya‑tap megnyitja a `TicketDetailsDialog`‑ot, cím: `loc.ticket_details_title`.
5. [x] Hiba állapot: üzenet + Retry gomb látható; Retry frissít.
6. [ ] Golden: képernyő alapállapot képei hu/en/de nyelven elfogadva (AA kontraszt szemrevételezés).
7. [ ] Rules: saját uid → olvasás sikerül; más uid → olvasás elbukik.

## 🔧 Futtatás

```
flutter analyze lib test integration_test bin tool
flutter test --coverage
# Golden frissítés (szükség esetén):
# flutter test --tags=golden --update-goldens
```

