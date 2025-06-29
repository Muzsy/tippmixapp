# T13 – NotificationCenter widget‑ és unit‑teszt vászon

## Cél

Biztosítani, hogy a **NotificationCenter** (lib/screens/notifications/notification\_center.dart) hibamentesen jelenjen meg, kezelje az értesítéseket és állapotváltozásokat:

* értesítések listázása (legfrissebb elöl)
* olvasatlan jelző (dot) és színváltás olvasottá tételkor
* szűrő (All / Unread)
* push (FCM) áram kezelés – új értesítés azonnal beszúródik
* pull‑to‑refresh → provider/stream reload
* üres lista esetén üzenet (3 nyelv)
* hálózati hiba → SnackBar / Alert
* hosszú lista stabil scroll

---

## Környezet

* **Flutter** stable (≥ 3.22)
* `flutter_test`, `riverpod` mockok, `mockito`
* `notificationStreamProvider` felülbírálása `FakeNotificationStream`
* FCM / Firebase nem inicializálódik, helyette `FakeFcmMessage`
* l10n beállítás: `AppLocalizations`

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      notificationStreamProvider.overrideWith((ref) => fakeStream),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: const NotificationCenter(),
    ),
  ),
);
```

---

## Tesztesetek

| ID    | Leírás                   | Előkészítés                       | Elvárt eredmény                              |
| ----- | ------------------------ | --------------------------------- | -------------------------------------------- |
| NC‑01 | **Lista rendezés**       | 3 notif különböző timestamp       | ListView 0. elem: legújabb `title1`          |
| NC‑02 | **Olvasatlan jelző**     | notif.unread = true               | Badge/dot látszik, text félkövér             |
| NC‑03 | **Olvasottá tétel**      | tap 0. elem                       | dot eltűnik, text normál weight              |
| NC‑04 | **Szűrő – Unread**       | 1 read, 1 unread, filter = Unread | Csak olvasatlan elem látszik                 |
| NC‑05 | **Push‑stream beszúrás** | fakeStream.add(newNotif)          | newNotif ListView top‑ra kerül `pump()` után |
| NC‑06 | **Pull‑to‑refresh**      | dragDown + pumpAndSettle          | provider reload hívódik, spinner eltűnik     |
| NC‑07 | **Empty state**          | \[]                               | `loc.noNotifications` szöveg középen         |
| NC‑08 | **Lokalizáció – HU**     | locale `hu`, \[]                  | Üres szöveg magyarul                         |
| NC‑09 | **Lokalizáció – DE**     | locale `de`                       | Üres szöveg németül                          |
| NC‑10 | **Hálózati hiba**        | provider throws Exception         | SnackBar `loc.errorFetching` jelenik meg     |
| NC‑11 | **Scroll stabilitás**    | 200 notif dummy                   | teljes scroll, nincs overflow                |

> **Megjegyzés**: részletes NotificationDetailsPage még nincs – a tap csak állapotot módosít, navigáció tesztje *skip*.

---

## Unit‑tesztek

| ID    | Leírás                           | Függvény                     | Elvárt                             |
| ----- | -------------------------------- | ---------------------------- | ---------------------------------- |
| NU‑01 | **NotificationModel fromJson**   | `NotificationModel.fromJson` | megfelelő property‑töltés          |
| NU‑02 | **NotificationService markRead** | `markRead(id)`               | adott ID unread→false, stream emit |
| NU‑03 | **filterUnread helper**          | `filterUnread(list)`         | csak `unread == true` elem marad   |

---

## DoD

* 11 widget‑ és 3 unit‑teszt CI‑ben zöld (flutter test)
* NotificationCenter, NotificationService lefedettség ≥ 90 %
* nincs `debugPrint` leak
* golden snapshot továbbra sem kell
* YAML‑cél: `codex/goals/fill_canvas_notification_center_test.yaml` lint tiszta

---

## Nyitott kérdések

1. SnackBar design fix vagy változhat? (ha változik, golden teszt?)
2. `markAllRead` funkció tervben – külön teszt, ha implementálva lesz.

---

## Hivatkozások

* notification\_center.dart, notification\_card.dart – **lib/screens/notifications/**
* notification\_service.dart, notification\_model.dart – **lib/services**, **lib/models**
* Sprint5 docs: Progress Overview2.pdf, Audit 2025‑06‑26.pdf
