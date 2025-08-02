## 🛠 fix_router_named_routes

Ez a vászon a navigációs útvonalakhoz tartozó `name:` mezők hiányából adódó hibákat dokumentálja.  Az eredeti `GoRoute` definíciókban a `name` mező hiánya navigációs problémákat és kontextus nélküli `pop` hívásoknál hibát okozott【700978910646508†L4-L7】.  A javítás során minden útvonalhoz (például `leaderboard` és `settings`) hozzáadtuk a megfelelő `name: AppRoute.leaderboard.name` stb. mezőt【700978910646508†L18-L33】, és az `AppRoute` enumot ennek megfelelően frissítettük, hogy a név alapú navigáció megfelelően működjön.
