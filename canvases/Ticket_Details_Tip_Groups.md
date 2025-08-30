# Canvas: Ticket Details – Tippek státusz szerinti csoportosítása

## Cél
- A TicketDetails dialógusban a tippek megjelenítése három szekcióban: Nyertes → Vesztes → Függőben.
- Minden szekció ExpansionTile, fejlécben darabszám, elemek egységes sorokban (esemény, outcome•market, xODDS, mini státusz‑chip).

## Scope
- Tippszintű státusz bevezetése: `TipModel.status: TipStatus { won, lost, pending }`.
- Csoportosítás, rendezés (startTime szerint, növekvő).
- UI: három össze/kinyitható szekció, csak nem üres szekciók jelennek meg.
- I18n kulcsok: `ticket_details.section_won|lost|pending`, `ticket_details.no_items`, opcionálisan `ticket_details.friendly_id`.
- A11y: szekciófejlécek heading szereppel.
- Telemetria: `ticket_details_group_expanded(group, count)`, `ticket_details_item_viewed(eventId, outcome)`.

## DoD
- HU/EN/DE kulcsok mindhárom szekciócímhez + no_items.
- Min. 1 widget‑teszt/szekció variáns (összesen 3 teszt).
- Analyzer és a kapcsolódó tesztek zöldek.

