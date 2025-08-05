# Firestore szabályjavítás – Ticket kulcslista

## Kontextus

A szelvény beküldés (POST `/tickets/{ticketId}`) továbbra is **cloud\_firestore/permission-denied** hibát dobott. A legutóbbi patch során a kulcslista `hasOnly([...])` javítása hibás volt: a `...` placeholder véletlenül belekerült a prod szabályba, így a megengedett kulcsok listája rosszul definiálódott (`['id','userId','...tus']`). Ez elvágta minden beküldési kísérletet, hiszen a kliens valós kulcsai (tips, stake, totalOdd, potentialWin, createdAt, updatedAt, status) **hiányoztak** a listából.

## Cél (Goal)

Az `/tickets/{ticketId}` szabály kulcslistáját helyes, **teljes** felsorolásra cserélni, hogy a kliens-oldali `Ticket.toJson()` által küldött mezők átmenjenek az ellenőrzésen.

## Feladatok

* [ ] Frissíteni a `firebase.rules` fájlt: `hasOnly(['id','userId','tips','stake','totalOdd','potentialWin','createdAt','updatedAt','status'])`.
* [ ] Futtatni `flutter analyze` – nincs linter hiba.
* [ ] Lefuttatni a `scripts/test_firebase_rules.sh` CI tesztet – zöld.

## Acceptance Criteria / Done Definition

* [ ] A szelvény beküldése már **nem** dob `permission-denied` hibát.
* [ ] `flutter analyze` hibamentes.
* [ ] Firestore Rules teszt 100 %‐os siker.

## Hivatkozások

* YAML: `/codex/goals/fix_ticket_permission_denied.yaml`
* Log hibakimenet: `log.txt` fileciteturn1file0
