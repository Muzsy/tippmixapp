// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get home_title => 'Főképernyő';

  @override
  String get home_guest_message => 'Jelentkezz be vagy regisztrálj a profilod megtekintéséhez';

  @override
  String get home_coin => 'TippCoin';

  @override
  String get home_stats => 'Statisztika';

  @override
  String get home_nav_profile => 'Profil';

  @override
  String get home_nav_stats => 'Statisztika';

  @override
  String get home_nav_messages => 'Üzenetek';

  @override
  String get home_nav_forum => 'Fórum';

  @override
  String get home_tile_bets => 'Fogadás';

  @override
  String get home_tile_news => 'Hírcsatorna';

  @override
  String get home_tile_my_bets => 'Fogadásaim';

  @override
  String get home_tile_friends => 'Barátok';

  @override
  String get home_highlight_tip => 'Napi tipp: Bayern győz';

  @override
  String get home_highlight_motivation => 'Motiváció: Próbálj ki egy új stratégiát!';

  @override
  String get home_highlight_coin => 'TippCoin: Nyerj extra coinokat aktivitással!';

  @override
  String get login_title => 'Bejelentkezés';

  @override
  String get login_tab => 'Belépés';

  @override
  String get register_tab => 'Regisztráció';

  @override
  String get email_hint => 'Email';

  @override
  String get password_hint => 'Jelszó';

  @override
  String get confirm_password_hint => 'Jelszó újra';

  @override
  String get login_button => 'Belépés';

  @override
  String get register_button => 'Regisztráció';

  @override
  String get forgot_password => 'Elfelejtett jelszó?';

  @override
  String get google_login => 'Folytatás Google-lel';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_logout => 'Kijelentkezés';

  @override
  String get profile_language => 'Nyelv';

  @override
  String get profile_theme => 'Téma';

  @override
  String get profile_rank => 'Rang';

  @override
  String get profile_guest => 'Bejelentkezés vendégként';

  @override
  String get createTicketTitle => 'Szelvény készítése';

  @override
  String get stakeHint => 'Tét';

  @override
  String get placeBet => 'Fogadás leadása';

  @override
  String get errorInvalidStake => 'Érvénytelen tét';

  @override
  String get errorDuplicate => 'Duplikált tippek nem engedélyezettek';

  @override
  String get errorMatchConflict => 'Ütköző tippek ugyanarra a meccsre';

  @override
  String get my_tickets_title => 'Szelvényeim';

  @override
  String get ticket_status_pending => 'Függőben';

  @override
  String get ticket_status_won => 'Nyert';

  @override
  String get ticket_status_lost => 'Veszített';

  @override
  String get ticket_status_void => 'Érvénytelen';

  @override
  String get empty_ticket_message => 'Még nincs szelvényed';

  @override
  String get ticket_details_title => 'Szelvény részletei';

  @override
  String get api_error_limit => 'Túl sok kérés az OddsAPI felé';

  @override
  String get api_error_key => 'Érvénytelen OddsAPI kulcs';

  @override
  String get api_error_network => 'Hálózati hiba az OddsAPI elérésekor';

  @override
  String get api_error_unknown => 'Ismeretlen hiba az OddsAPI-tól';

  @override
  String get events_title => 'Események';

  @override
  String get events_empty => 'Nincs elérhető esemény';

  @override
  String get add_tip => 'Hozzáadás';
}
