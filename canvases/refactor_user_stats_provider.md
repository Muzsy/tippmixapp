**Refaktor: User statisztikák betöltésének helyes működése a HomeScreen-en**

A jelenlegi kódban a `home_screen.dart` fájl a nem létező `statsProvider`-t próbálja használni:

```dart
final stats = ref.watch(statsProvider);
```

Ez hibához vezet, mert ilyen provider **nem szerepel** a `stats_provider.dart` fájlban.

---

## 🔧 Cél

Biztosítsuk, hogy a `UserStatsHeader` komponens valós, aszinkron statisztika-adatok alapján jelenik meg a HomeScreen-en.

---

## 📁 Változtatások

### 1. 🖉 Hozzunk létre egy valós `userStatsProvider`-t a `stats_provider.dart` fájlban:

```dart
final userStatsProvider = FutureProvider<UserStatsModel>((ref) {
  final service = ref.watch(statsServiceProvider);
  return service.getUserStats();
});
```

Ez a provider aszinkron lekéri a `UserStatsModel` objektumot a `StatsService`-ből.

---

### 2. 🔄 Cseréljük le a `home_screen.dart` fájlban a hibás sort:

**Ezt:**

```dart
final stats = ref.watch(statsProvider);
```

**Erre:**

```dart
final stats = ref.watch(userStatsProvider);
```

A további `.when(...)` logika megtartható, mivel a FutureProvider AsyncValue-t ad vissza.

---

### 3. 🔧 Tesztkörnyezet javítása

A `test/screens/home_screen_test.dart` fájlban mockolni kell a `userStatsProvider`-t, pl.:

```dart
userStatsProvider.overrideWith((ref) => AsyncData(UserStatsModel(
  uid: 'u1',
  displayName: 'Me',
  coins: 1000,
  totalBets: 0,
  totalWins: 0,
  winRate: 0.75,
)))
```

Ezután a `UserStatsHeader` widget meg fog jelenni, a teszt sikeresen lefut.

---

## 🔒 Ellenőrzés

* A `home_screen.dart` és a `stats_provider.dart` konzisztens.
* A tesztek mockolható providert használnak.
* A `UserStatsHeader` megjelenése tesztelhető és stabil.
