## 🛠 fix_router_missing_routes

A navigátor konfigban hiányoztak bizonyos útvonalak (pl. `leaderboard` és `settings`), ami miatt ezekre a képernyőkre nem lehetett navigálni【669709208504965†L4-L6】.  A javítás részeként a router definícióját kiegészítettük a hiányzó `GoRoute` szakaszokkal, és bevezettük az enum alapú névkonvenciót az útvonalakhoz【669709208504965†L10-L26】, így a képernyők elérhetővé váltak.
