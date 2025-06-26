# fill_canvas_notification_center.yaml

canvas: canvases/notification_center_screen.md
inputs:
  - codex_docs/routing_integrity.md
  - codex_docs/localization_logic.md
  - lib/widgets/notification_bell_widget.dart
  - lib/services/notification_service.dart
  - lib/models/notification_model.dart
  - lib/screens/rewards/rewards_screen.dart
  - lib/screens/badges/badge_screen.dart
  - lib/screens/friends/friends_screen.dart
steps:
  - name: NotificationCenter képernyő létrehozása
    description: Hozz létre egy NotificationCenterScreen-t, amely listázza az összes felhasználóra vonatkozó értesítést. Az elemek kattinthatók legyenek, és a típusnak megfelelő képernyőre navigáljanak.
    outputs:
      - lib/screens/notifications/notification_center_screen.dart
      - lib/widgets/notification_item.dart

  - name: NotificationBellWidget bővítése számlálóval
    description: A jobb felső sarokban lévő csengő ikon egészítse ki egy badge számlálóval, amely a még nem olvasott értesítések számát mutatja.
    outputs:
      - lib/widgets/notification_bell_widget.dart

  - name: NotificationModel és NotificationService definiálása
    description: Készítsd el a NotificationModel típust, és a NotificationService osztályt, amely a Firestore-ból olvassa a `users/{userId}/notifications` kollekciót és biztosítja az olvasottsági állapot kezelését.
    outputs:
      - lib/models/notification_model.dart
      - lib/services/notification_service.dart

  - name: Navigáció és útvonal regisztrálása
    description: Regisztráld a NotificationCenterScreen-t a GoRouter konfigurációban, és add hozzá a drawer menühöz `menuNotifications` kulccsal.
    outputs:
      - lib/router/app_router.dart
      - lib/widgets/main_drawer.dart
      - lib/models/app_route.dart

  - name: Lokalizációs kulcsok hozzáadása
    description: Adj hozzá minden szükséges értesítési típushoz lokalizációs kulcsokat (reward, badge, friend, message, challenge) az ARB fájlokhoz.
    outputs:
      - lib/l10n/app_hu.arb
      - lib/l10n/app_en.arb
      - lib/l10n/app_de.arb

  - name: Widget és service tesztek készítése
    description: Készíts teszteket, amelyek ellenőrzik, hogy az értesítések helyesen jelennek meg, kattinthatók, és az olvasottsági állapot frissül.
    outputs:
      - test/screens/notification_center_screen_test.dart
      - test/services/notification_service_test.dart
