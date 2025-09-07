# 💬 Fórum modul terv (HU)

Ez a dokumentum a TippmixApp fórum (közösségi beszélgetés) moduljának tervét és struktúráját írja le.

---

## 🎯 Célja

- Lehetőséget adni meccsek, tippek és trendek megvitatására
- Erősíteni a közösségi kapcsolatokat
- Támogatni a szál-alapú beszélgetést

---

## 📁 Firestore struktúra (javasolt)

```
threads/{threadId}
  → title, createdBy, createdAt, tags
threads/{threadId}/posts/{postId}
  → content, userId, createdAt, upvotes
```

---

## ✏️ Tartalom típusok

- Szöveges hozzászólás
- Reakciók / szavazatok (később)
- Válasz egy másik bejegyzésre (opcionális)

---

## 🔐 Jogosultságok

- Csak bejelentkezett felhasználó írhat
- Saját poszt szerkesztése 15 percig (terv)
- Moderálás `role` mező alapján (jövőbeli funkció)

---

## 📱 UI koncepció

- `ForumScreen`: szál lista
- `ThreadViewScreen`: posztok listája
- `NewThreadScreen`: új szál létrehozása
- Egyszerű WYSIWYG szerkesztő

---

## 🔁 Backend logika

- Alap spam szűrés (hossz, trágár szavak)
- Felhasználói statisztika: posztok száma (badge alap)
- Opcionális: kiemelt szálak, rögzített témák
- MarketSnapshotAdapter cache-eli az ApiFootball odds pillanatképet a komponálóhoz

---

## 📇 Lekérdezés → Index megfeleltetés

| Lekérdezés | Firestore index |
| --- | --- |
| Szálak fixture alapján | `(fixtureId ASC, type ASC, createdAt DESC)` |
| Posztok szál szerint | `(threadId ASC, createdAt DESC)` |
| Szavazatok entitás szerint | `(entityType ASC, entityId ASC, createdAt DESC, userId ASC)` |
| Jelentések státusz szerint | `(status ASC, createdAt DESC)` |

---

## ✅ Megvalósítás

- ForumScreen szál listával, szűrő tabokkal és rendező menüvel
- NewThreadScreen új szál létrehozásához
- Firestore security rules a szálakra, posztokra, szavazatokra és jelentésekre
- Központi router ThreadViewScreen-nel és komponálóval
- Fórum fül az alsó navigációban
- threadDetailControllerProviderFamily export

## 🧪 Tesztelés

- Űrlap validáció teszt
- Lapozás a szál nézetben
- Írási jogosultság ellenőrzése
