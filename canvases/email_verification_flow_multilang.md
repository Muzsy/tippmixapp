# Auth – Email‑verifikáció Flow (hu · en · de) – Sprint 8

> **Sprint típusa**: Feature + UX‑finomhangolás
> **Becsült effort**: 2 nap (fejlesztés) + 0,5 nap (review / QA)

---

## 🎯 Cél

A regisztrációt követően a felhasználó csak akkor léphessen tovább az alkalmazásba, ha email‑címét **megerősítette**. A folyamat legyen háromnyelvű (hu, en, de), reszeljen UX‑szinten (interstitial képernyő, visszaszámláló a „Újraküldés” gombhoz), valamint illeszkedjen a meglévő Codex‑fedett teszt‑ és build‑rendszerhez.

### Funkcionális követelmények

| # | Követelmény                                                                                                                                                                         | L10n kulcs                      | Megjegyzés                                                   |
| - | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------- | ------------------------------------------------------------ |
| 1 | Regisztráció végén `sendEmailVerification()` hívás Firebase‑en                                                                                                                      | `emailVerify.sentTitle`         | `FirebaseAuth.instance.currentUser!.sendEmailVerification()` |
| 2 | **EmailNotVerifiedScreen**: üdvözlő ikon, rövid leírás, „Ellenőrző email újraküldése” gomb                                                                                          | több kulcs (lásd lent)          | Material 3 alapján                                           |
| 3 | „Újraküldés” gomb inaktív 60 s letelte előtt (throttle)                                                                                                                             | `emailVerify.resendDisabled(n)` | n = másodpercek                                              |
| 4 | Back‑endből beérkező **deep‑link** kezelés: ha a link megnyitása után a felhasználó visszatér az appba → `FirebaseAuth.instance.currentUser!.reload()` és ha verified → `HomeRoute` | —                               | Firebase Dynamic Links / App Links                           |
| 5 | Login esetén, ha a user emailje **nem** verifikált → automatikus redirect az EmailNotVerifiedScreen‑re                                                                              | —                               | Auth‑gate módosítás                                          |
| 6 | Lokalizáció hu / en / de ARB fájlokban, ICU‑pluralozással („{{seconds}} másodperc”)                                                                                                 | —                               | L10n generator fut                                           |
| 7 | Widget‑ és integration‑teszt: resend throttle, redirect verified → home                                                                                                             | —                               | coverage ≥ 80 %                                              |

### L10n kulcsok (példaértékek)

```jsonc
{
  "emailVerify_title": "Erősítsd meg az email‑címed!",
  "emailVerify_sub": "Kattints a linkre a kapott emailben, majd térj vissza az alkalmazásba.",
  "emailVerify_resend": "Újraküldés",
  "emailVerify_resendDisabled": "Próbáld újra {{seconds}}…",
  "emailVerify_sentSnack": "Ellenőrző email elküldve!",
  "emailVerify_errorSnack": "Hiba történt. Próbáld újra később!"
}
```

*(Fordítások → en, de a l10n mappában.)*

### Tesztelési jegyzetek

* **unit** – `EmailVerificationService` throttle‑logika
* **widget** – `EmailNotVerifiedScreen` UI állapotok (enabled/disabled, snack)
* **integration** – simulated deep‑link, user.reload → redirect

### Out‑of‑scope

* Telefon‑/SMS‑alapú igazolás
* SSO / social login verifikáció‑skip
* Backend‑oldali TTL módosítás

---

## Feladatlista (checkbox a reviewer‑nek)

* [ ] `EmailVerificationService` + 60 s throttle
* [ ] `AuthRepository.sendEmailVerification()` wrapper
* [ ] `EmailNotVerifiedScreen` (Material 3, responsive)
* [ ] L10n kulcsok hu / en / de
* [ ] Dynamic Links listener + user.reload flow
* [ ] AuthGate módosítás (redirect‑if‑unverified)
* [ ] Widget / integration tesztek
* [ ] CI `flutter analyze && flutter test` zöld

---

> **Minőségbiztosítás**
> A fejlesztő merge előtt futtassa: `flutter test --coverage`, `flutter analyze`, és ellenőrizze, hogy a l10n fájlok validak az `arb_validator` script alapján.
