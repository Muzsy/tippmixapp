# TippmixApp — Coding Conventions

## Általános
- Kisebb, fókuszált diffek; Conventional Commits (feat/fix/refactor/test/chore/docs).
- Aider csak a /add-olt fájlokat módosíthatja.

## Backend (Cloud Functions Gen2, Node.js 20, TypeScript)
- Pub/Sub esetén CloudEvent handler (onMessagePublished).
- `event?.data?.message` null/undefined védelem; base64→JSON parse `try/catch`-ben.
- Részletes, konzisztens log: messageId, attributes, payload rövid kivonat.

## Flutter/Dart
- `dart format` kötelező; `flutter analyze` tiszta.
- Riverpod állapotkezelés; unit/widget tesztek, ahol értelmezhető.

## Tesztelés
- Gyors unit → célzott e2e: Pub/Sub publish → GCF log ellenőrzés.