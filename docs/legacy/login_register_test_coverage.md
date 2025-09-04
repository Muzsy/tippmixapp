# Login és regisztrációs folyamatok tesztlefedettsége

Ez a dokumentum összefoglalja a LoginRegisterScreen-hez kapcsolódó widget tesztek lefedettségét.

## Lefedett folyamatok

- Email alapú bejelentkezés és regisztráció
- Jelszó visszaállítási dialógus
- Verifikációs email küldése regisztrációkor
- Hibakódok lokalizációja minden támogatott nyelven
- Különböző megjelenési módok (Login vs Register tab)

## Tesztfájlok

- `test/screens/login_register_screen_test.dart` – összes widget viselkedés, hibakezelés és lokalizáció tesztje

## Teszt futtatás

A teljes tesztcsomag a projekt gyökeréből indítható:

```bash
flutter test --concurrency=4
# Lefedettséghez futtasd külön:
# flutter test --coverage
```

Ez lefuttatja az összes tesztet párhuzamosan. Ha lefedettségi riport kell, külön futtasd a fenti `flutter test --coverage` parancsot vagy hagyd a CI-re.
