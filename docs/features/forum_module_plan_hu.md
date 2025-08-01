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

---

## 🧪 Tesztelés

- Űrlap validáció teszt
- Lapozás a szál nézetben
- Írási jogosultság ellenőrzése
