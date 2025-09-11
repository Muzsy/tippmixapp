# Supabase Migration Audit – Checklist

- [x] RLS engedélyezése és alapértelmezett policy-k létrehozása (összes releváns tábla)
- [x] Admin szerepkör bevezetése és jogosultságok frissítése (profiles.is_admin + admin policy-k)
- [x] Supabase Auth integráció ellenőrzése (Firebase helyett – Flutter szolgáltatások/UI)
- [x] Supabase Realtime frissítések implementálása (forum_threads/forum_posts)
- [x] Pontszám számítás trigger + értesítési Edge Function (profiles.score frissítés, notify_user)
- [x] Hibakezelés és offline jelzés a kliensoldalon (Supabase hívások után error kezelés)
- [x] CI/CD pipeline felülvizsgálat Supabase-re (migrációk, funkció deploy – zöld futás)
- [x] Dokumentáció frissítése (Supabase átállás, RLS, setup)
- [x] Firebase-specifikus kód és konfiguráció eltávolítása (maradékok felkutatása)
