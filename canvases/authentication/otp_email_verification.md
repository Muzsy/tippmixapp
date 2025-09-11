# OTP email‑verifikáció (Supabase) – migrációs vászon

🎯 **Funkció**

* A jelenlegi e‑mail/link alapú megerősítés helyett **e‑mailes OTP (6 jegyű kód)** megerősítés használata **redirect és domain nélkül**.
* Regisztráció után a felhasználó e‑mailben kódot kap; az appban beírja → e‑mail verifikáció lezárva Supabase‑en → bejelentkeztetjük.

🧠 **Fejlesztési részletek**
**Érintett fájlok (csak létező utak):**

* `lib/services/auth_service_supabase.dart`
* `lib/services/auth_service_base.dart`
* `lib/providers/auth_provider.dart`
* `lib/screens/auth/login_form.dart`
* `lib/screens/auth/otp_prompt_screen.dart`
* `lib/l10n/app_hu.arb`, `lib/l10n/app_en.arb`, `lib/l10n/app_de.arb`

**Követelmények / módosítások:**

1. **Supabase adapter bővítése (OTP támogatás)**

   * `registerWithEmail(email, password)`: ne adjon át `emailRedirectTo`‑t (nincs link), a regisztráció után térjen vissza sikerrel/hibával, **OTP e‑mail automatikusan kimegy** (a Supabase sablonban `{{ .Token }}` legyen).
   * Új publikus metódusok:

     * `Future<void> verifyEmailOtp(String email, String code)` → `supabase.auth.verifyOtp(email:…, token:…, type: OtpType.email)` majd **`signInWithPassword`** azonnal (ha nincs aktív session), végül `_ensureProfile`.
     * `Future<void> resendSignupOtp(String email)` → `supabase.auth.resend(type: OtpType.signup, email: email)`.

2. **AuthServiceBase szerződés frissítése**

   * Interface kiegészítése a fenti két metódussal.

3. **Auth Provider / Notifier**

   * Publikus hívások az UI számára: `requestVerifyEmailOtp(email, code)`, `resendSignupOtp(email)`; hiba‑ és állapotkezelés meglévő mintára.

4. **UI flow (regisztráció → OTP)**

   * `login_form.dart`: regisztrációs ágban **sikeres signup után** navigálj az **OTP képernyőre**.
   * `otp_prompt_screen.dart`:

     * Használja az `authProvider`‑t; vegyen át **`email`** paramétert (string) a SecurityService helyett/mellett.
     * `Küldés` gomb → `authProvider.requestVerifyEmailOtp(email, code)` → siker esetén `pop(true)` és navigáció a főképernyőre.
     * „Nem jött meg?” → `authProvider.resendSignupOtp(email)` + rövid cooldown.

5. **Lokalizáció**

   * Már létező kulcsok vannak (HU/EN)/DE: `otp_enter_code`, `otp_error_invalid`, `otp_prompt_title`.
   * Adj hozzá rövid üzeneteket (ha hiányoznak): `otp_resend`, `otp_sent_to`, `otp_expired`, `otp_new_code_sent`.

6. **Supabase e‑mail sablon (MANUÁLIS)**

   * Dashboard → Auth → Email Templates → **Confirm signup**: cseréld linkről kódra → csak `{{ .Token }}` szerepeljen a törzsben (és opcionális érvényességi idő szöveg).
   * Ez a lépés a kódbázison kívül történik; a Codex csak **megjegyzésként** jelzi a teendőt a README‑ben.

7. **Biztonság / UX**

   * Rate limit üzenet kezelése (pl. 60 mp újraküldés előtt).
   * Kód bevitel 6 mező / egy mező, auto‑focus, csak számok.
   * Hibák: `invalid_otp`, `expired_otp` külön megjelenítve.

🧪 **Tesztállapot**

* Cél: widget teszt az OTP képernyő gomb‑ és hibaállapotaira; smoke teszt a regisztrációs ágra (mockolt AuthService‑szel).
* Minimalista megközelítés: meglévő teszt infrastruktúra használata, új fájlok csak ha szükségesek.

🌍 **Lokalizáció**

* HU/EN/DE értékeket frissíten.
* `flutter gen-l10n` futtatás a sztringek után.

📎 **Kapcsolódások**

* `lib/ui/auth/auth_gate.dart`, `lib/providers/auth_guard.dart` (navigáció, verifikált státusz).
* Supabase tábla: `profiles` (profil upsert `id` alapján az OTP utáni első belépéskor).
* Doksi frissítés: `docs/auth/otp_verification.md` (ha létezik; ha nem, egy rövid README‑szakasz a gyökérben `AUTH_OTP_NOTES.md`).

---

## Pipálható checklist (P0 → P2)

**P0 – Kötelező**

* [ ] `auth_service_supabase.dart`: `verifyEmailOtp`, `resendSignupOtp` metódusok
* [ ] `auth_service_base.dart`: interface bővítés
* [ ] `auth_provider.dart`: publikus hívások + állapotkezelés
* [ ] `login_form.dart`: regisztráció után OTP képernyőre navigálás
* [ ] `otp_prompt_screen.dart`: e‑mail alapú OTP ellenőrzésre átvezetve
* [ ] HU/EN/DE kulcsok: `otp_resend`, `otp_sent_to`, `otp_expired`, `otp_new_code_sent`

**P1 – Ajánlott**

* [ ] Cooldown gomb komponens használata/finomhangolása
* [ ] README megjegyzés a Supabase e‑mail sablonról (MANUÁLIS lépés)

**P2 – Opcionális**

* [ ] Widget teszt(ek) az OTP képernyőre
* [ ] Rövid jegyzet a fejlesztői kézikönyvbe (docs/)
