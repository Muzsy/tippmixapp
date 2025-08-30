# Elfogadási kritérium – MyTickets (Szelvényeim)

## 🧭 Meta

- Képernyő: MyTicketsScreen
- Verzió/Dátum: 2025-08-30
- Felelős: TBD

## ✅ Kritériumok

- AC1: Bejelentkezett felhasználó esetén a képernyő a saját `users/{uid}/tickets` kollekcióból listáz, `createdAt` desc sorrendben.
- AC2: Üres kollekció esetén üres állapot jelenik meg elsődleges CTA gombbal (szöveg: `loc.go_to_create_ticket`), amely a `AppRoute.bets` név szerinti route‑ra navigál.
- AC3: Hibás adatbetöltéskor hibaüzenet és „Retry” művelet jelenik meg; Retry frissíti a `ticketsProvider`‑t.
- AC4: Listaelemre tap esetén részletező dialog nyílik, amely tartalmazza: `ticket_id`, `stake`, `totalOdd`, `potentialWin`, `createdAt`, `tips` darabszám és `TicketStatusChip`.
- AC5: Részletező dialógus: a tippek státusz szerinti szekciókban látszanak (Nyertes/Vesztes/Függőben) darabszámmal; 1 elemnél nincs össze/kinyitás, 2+ elemnél ExpansionTile.
- AC6: Tipp sorok: esemény cím, `outcome • market`, helyes eredeti odds (nem 1.00 fallback), mini státusz‑chip a téma színeivel.
- AC7: Telemetria: a képernyő első megjelenésekor egyszer küldi a `tickets_list_viewed` eseményt; kártya‑tapkor `ticket_selected`; dialog nyitásakor `ticket_details_opened`; hibaállapotnál `error_shown`; üres CTA gomb megnyomásakor `tickets_empty_cta_clicked`; szekció kinyitásakor `ticket_details_group_expanded`; tételsor megtekintésénél `ticket_details_item_viewed`.
- AC8: i18n: Minden UI szöveg a `loc()` rétegen keresztül lokalizált; hu/en/de nyelveken futtatva nem dob kivételt.
- AC9: A komponensek nem használnak hard‑coded színt; színek `Theme.of(context).colorScheme`‑ből érkeznek.

## 🔎 Jegyzetek

- Edge case‑ek: nagyon hosszú `ticket.id` esetén eltolás/vágás azonosító megjelenítésnél; üres `tips` lista támogatott.
- Függőségek: Firestore, FirebaseAuth, GoRouter; Analytics (FirebaseAnalytics wrapper).
- Nem‑célok: szerkesztés/törlés; más felhasználó szelvényeinek böngészése; lapozás (külön feladat).
