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
  → title, createdBy, createdAt, tags, lastActivityAt, postsCount
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
- Szál aggregátumok: `lastActivityAt` és `postsCount` frissítése poszt létrehozáskor/törléskor
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
| Rögzített szálak aktivitás szerint | `(pinned ASC, lastActivityAt DESC)` |
| Rögzített szálak legújabb | `(pinned ASC, createdAt DESC)` |
| Szálak típus szerint utolsó aktivitás | `(type ASC, lastActivityAt DESC)` |
| Szálak típus szerint legújabb | `(type ASC, createdAt DESC)` |

---

## ✅ Megvalósítás

- ForumScreen szál listával, szűrő tabokkal és rendező menüvel
- NewThreadScreen új szál létrehozásához (mezők validálása, siker esetén navigál a szál nézetre)
- Firestore security rules a szálakra, posztokra, szavazatokra és jelentésekre
- Központi router ThreadViewScreen-nel és komponálóval
- Fórumlista FAB megnyitja a NewThreadScreen-t
- Fórum fül az alsó navigációban
- threadDetailControllerProviderFamily export
- Auth UID bekötve a szál/poszt létrehozásnál; JSON csak rules által engedett mezőket küld
- ThreadViewScreen poszt műveletek (válasz, szerkesztés, törlés, szavazat, jelentés) hibakezeléssel
- Jelentés párbeszédpanel oka (spam, visszaélés, off-topic, egyéb) és opcionális megjegyzés bekérésével
- Zárolt szál esetén figyelmeztető sáv és letiltott komponáló
- Végtelen görgetés és lapozás a szál- és posztlistákban duplikációvédelemmel
- Központosított lekérdezésépítő a szűrési/rendezési kombinációkhoz
- Összetett Firestore indexek a lekérdezésekhez igazítva

## 🧪 Tesztelés

- Űrlap validáció teszt
- Lapozás a szál nézetben
- Írási jogosultság ellenőrzése
- Bővített security rules tesztek hibás azonosítókra, tiltott mezőkre és hitelesítetlen műveletekre
