## 🧪 MyTicketsScreen – Widget‑teszt (Sprint5 ✓ T05)

### 🎯 Cél

Biztosítani, hogy a **MyTicketsScreen** felület helyesen viselkedjen a következő fő esetekben:

1. **Üres állapot** – ha nincs bejelentkezett felhasználó *vagy* a felhasználónak nincs egyetlen szelvénye sem, jelenjen meg az `EmptyTicketPlaceholder` widget.
2. **Jegy‑lista** – ha a `ticketsProvider` valós szelvénylistát szolgáltat, a képernyő jelenítse meg mindet `TicketCard` widgetekkel.
3. **Pull‑to‑refresh** – a felhasználó lehúzza a listát → hívódjon a `ref.refresh(ticketsProvider.future)` és frissüljön a UI.

### 🧠 Fejlesztési részletek

* **Provider‑override setup**

  * A `ticketsProvider` a `lib/screens/my_tickets_screen.dart`-ban van definiálva ( `StreamProvider.autoDispose<List<Ticket>>` ). A tesztben `overrideWithProvider`‑rel cseréljük le → `Stream.value([])` illetve `Stream.value(sampleTickets)`.
  * Az `authProvider`‑t szintén override-oljuk: *signed‑out* scenarióhoz null user, *signed‑in* scenarióhoz fake user.
* **Teszt‑architektúra**

  * `setUpAll(() { Intl.defaultLocale = 'en'; });` – lokalizáció alapértelmezése.
  * `MaterialApp` + `AppLocalizations.delegate` + `supportedLocales` (`hu`, `en`, `de`).
  * `ProviderScope` root, benne a widget‑fa.
* **Mintajegyek**

  ```dart
  final sampleTickets = [
    Ticket(
      id: 't1',
      createdAt: DateTime(2025, 6, 15),
      totalOdd: 3.5,
      stake: 100,
      status: TicketStatus.open,
      tips: [],
    ),
  ];
  ```
* **Ellenőrzések**

  1. `expect(find.byType(EmptyTicketPlaceholder), findsOneWidget);`
  2. `expect(find.byType(TicketCard), findsNWidgets(sampleTickets.length));`
  3. Lehúzás után a fake provider `refreshCalled` flagje igaz.

### 🌍 Lokalizáció

Az alkalmazás 3 nyelven ( **hu / en / de** ) fut. A tesztben angol szövegeket ellenőrzünk (`loc.my_tickets_title`, `loc.no_tickets_message`). A `flutter_localizations` és `AppLocalizations` delegate kötelező.

### 📎 Kapcsolódások

* `lib/screens/my_tickets_screen.dart` – a tesztelendő widget + `ticketsProvider`
* `lib/models/ticket_model.dart` – `Ticket`, `TicketStatus` típusok
* `lib/providers/auth_provider.dart` – bejelentkezési állapot
* `lib/widgets/empty_ticket_placeholder.dart` – üres állapot UI
* `lib/widgets/ticket_card.dart` – jegy megjelenítés
* `codex_docs/codex_context.yaml`
* `codex_docs/localization_logic.md`
* `codex_docs/routing_integrity.md`
* `codex_docs/service_dependencies.md`
* `codex_docs/priority_rules.md`
* `docs/tippmix_app_teljes_adatmodell.md`

---

> **Definition of Done (DoD)**
>
> * Zölden futó widget‑teszt a CI‑pipeline‑ben (\`dart run test  # Codex környezetben nem futtatunk Flutter-parancsot; a tesztet a CI rendszer hajtja végre
> * Nem sérti a globális tiltásokat ( `pubspec.yaml`, hard‑coded stringek, route‑naming ).
> * Lokalizáció: minden szöveg `loc()` wrapperrel, `.arb` kulcs változás nélkül.
> * Kizárólag a fenti fájlokat érinti, új service / route / enum **nem** keletkezik.
