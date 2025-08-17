# 🎯 Function

Switch the Bookmaker Strategy to **ID-based selection** using API-Football bookmaker integer IDs. Prefer Bet365 by **id = 8** for deterministic odds; if not present, fall back to any valid bookmaker.

# 🧠 Implementation details

* **Preferred bookmaker ID**: Introduce `defaultBookmakerId = 8` (Bet365) in `ApiFootballService`.
* **Parsing priority**: Update `MarketMapping.h2hFromApi(...)` to accept `preferredBookmakerId` (int) and check `bookmaker.id == preferredBookmakerId` first. If not found, run the existing generic scan.
* **Event card snapshot**: When creating a tip, store the integer `bookmakerId` (not name-based). If the model previously stored a string name, prefer the numeric field `bookmakerId` for forward compatibility.
* **Scope**: Frontend-only change. Backend payout remains driven by stored snapshot.

**Touched files**

* `lib/services/market_mapping.dart`
* `lib/services/api_football_service.dart`
* `lib/widgets/event_bet_card.dart`

# 🧪 Test scope

* H2H shows correctly when bookmaker id=8 exists; falls back when missing.
* Tip creation stores `bookmakerId = 8`.
* `flutter analyze` and existing widget tests pass.

# 🌍 Localization

No new strings.

# 📎 Notes

* This canvas complements the earlier Bookmaker Strategy, replacing name-based selection with **integer ID**-based selection.
* Keep the parsing tolerant to response variations (some feeds expose `name`, `key`, or `title`; the ID is consistent).
