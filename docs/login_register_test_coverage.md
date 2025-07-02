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
flutter test --coverage
```

A parancs lefuttatja az összes tesztet és frissíti a `coverage/` mappát. Sikertelen futtatás esetén ellenőrizd, hogy a Flutter környezet telepítve van-e.
