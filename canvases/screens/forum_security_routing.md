# Fórum modul – Security Rules + Routing/ThreadView

## 🎯 Funkció

Ez a canvas a fórum modul két kritikus hiányosságának lezárását célozza:

1. **Firestore Security Rules** kiegészítése a fórum kollekciókra.
2. **Routing + ThreadViewScreen** implementálása (útvonalak, bottom‑nav, résznézet UI, provider export, widget/rules tesztek).

---

## 🧠 Fejlesztési részletek

* **Security Rules:** Auth-kötelező írásra; creator tulajdon‑védelem; mező‑whitelisting; locked thread poszt-tiltás; report `status` csak admin által módosítható; időablakos szerkesztés/törlés.
* **Routing:** `/forum`, `/forum/new`, `/forum/:threadId` útvonalak a GoRouterben; új `AppRoute.forum` konvenció.
* **Bottom‑nav:** új fórum tab, i18n kulcs: `home_nav_forum`.
* **ThreadViewScreen:** posztlista (lapozással), fejléckomponens (thread meta + opcionális fixture), composer (locked esetén tiltva), akciók: reply/quote/edit/delete/vote/report.
* **Provider export:** `threadDetailControllerProviderFamily(threadId)` a ThreadDetailControllerhez.
* **Indexek:** meglévő `firestore.indexes.json` elég, integrációs teszt kiegészíti ha kell.
* **Tesztelés:** rules tesztek futtatása emulátorral; widget tesztek (ForumScreen + ThreadViewScreen); opcionális integrációs teszt teljes user‑útvonallal.

---

## 🧪 Tesztállapot

* **Rules tesztek:** auth nélküli írás tiltás, locked thread poszt tiltás, saját poszt szerkesztés/törlés csak időablakban, report státusz csak admin.
* **Widget tesztek:** nav‑fül működik, ThreadView composer tiltás locked esetben, vote/report gombok.
* **Integrációs teszt:** (opcionális) új szál → listában → résznézet → új poszt → vote → report, index igények naplózva.

---

## 🌍 Lokalizáció

* Új kulcsok: `thread_title`, `thread_locked`, `thread_pinned`, `post_reply`, `post_quote`, `post_edit`, `post_delete`, `post_report`, `post_like`, `post_unlike`, `composer_placeholder`, `composer_disabled_locked`, `confirm_delete_post`, `report_reason_*`, `report_submitted`.
* Nyelvek: HU/EN/DE.

---

## 📎 Kapcsolódások

* **Auth modul**: kötelező userId íráskor; avatar/név poszt mellett.
* **API‑Football**: thread fejlécben opcionális meccs meta.
* **Admin kezelése**: `app_meta/admins/{uid}` dokumentum alapján (később customClaims is lehet).
