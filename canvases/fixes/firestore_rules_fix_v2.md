# Sprint P0 – Firestore rules **kiegészítés** (v2)

A frissített szabályok után is `PERMISSION_DENIED` hibákat kapunk. A log és a kódbázis elemzése alapján további, szabályozatlan kollekciók érintettek:

| Kollekció            | Művelet         | Mi használja?                                      | Szükséges engedély                                |
| -------------------- | --------------- | -------------------------------------------------- | ------------------------------------------------- |
| `public_feed`        | **READ+CREATE** | `FeedService`; főlista, feedbe írás tipp leadáskor | READ: bárki, CREATE: bejelentkezett felhasználó   |
| `users/{uid}/badges` | **READ+CREATE** | `BadgeService`, badge képernyő                     | READ: bejelentkezett mindenki, CREATE: csak tulaj |
| `moderation_reports` | **CREATE**      | `FeedService.reportFeedItem`                       | CREATE: bejelentkezett felhasználó                |
| `copied_bets/{uid}`  | **READ+WRITE**  | `CopyBetFlow` (MVP‑ben csak tulaj)                 | READ/WRITE: tulajdonos                            |

> **Megjegyzés:** A `users` gyökérkollekciónál a hibát valószínűleg a `badges` subcollection hiánya okozta: Firestore‑query korlátozásnál *bármely* doc‑ra vonatkozó szabály hiánya teljes lekérdezést blokkol.

## Feladatok

* [ ] Bővítsük a `firebase.rules`-t a fenti kollekciókkal és helper függvényekkel (`isOwner`, `signedIn`).
* [ ] Tartsuk meg a korábbi védelmi logikát (no delete, shape‑ellenőrzés csak ahol már volt).
* [ ] CI: `flutter analyze`.

## Acceptance Criteria

* [ ] A **public feed** stream és feed‑bejegyzés létrehozás működik.
* [ ] A **Szelvény beküldés** már nem dob permission‑denied‑et (feed írás + tickets create + coin\_logs update stimmel).
* [ ] **Badge képernyő** megjelenik; új badge hozzáadása működik.
* [ ] **Ranglista** lekérdezés sikeres (users read ok).
* [ ] Lekérdezések emulator és production környezetben zöldek.

## Hivatkozások

* Canvas: `/codex/goals/firestore_rules_fix_v2.yaml`
