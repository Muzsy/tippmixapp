// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get home_title => 'Startseite';

  @override
  String get home_guest_message => 'Melde dich an oder registriere dich, um dein Profil anzusehen';

  @override
  String get home_coin => 'TippCoin';

  @override
  String get home_stats => 'Statistik';

  @override
  String get home_nav_profile => 'Profil';

  @override
  String get home_nav_stats => 'Statistik';

  @override
  String get home_nav_messages => 'Nachrichten';

  @override
  String get home_nav_forum => 'Forum';

  @override
  String get home_tile_bets => 'Wetten';

  @override
  String get home_tile_news => 'Nachrichten';

  @override
  String get home_tile_my_bets => 'Meine Wetten';

  @override
  String get home_tile_friends => 'Freunde';

  @override
  String get home_highlight_tip => 'Tipp des Tages: Bayern gewinnt';

  @override
  String get home_highlight_motivation => 'Motivation: Probiere eine neue Strategie aus!';

  @override
  String get home_highlight_coin => 'TippCoin: Verdiene zusätzliche Münzen durch Aktivität!';

  @override
  String get login_title => 'Anmelden';

  @override
  String get login_tab => 'Login';

  @override
  String get register_tab => 'Registrieren';

  @override
  String get email_hint => 'E-Mail';

  @override
  String get password_hint => 'Passwort';

  @override
  String get confirm_password_hint => 'Passwort erneut';

  @override
  String get login_button => 'Login';

  @override
  String get register_button => 'Registrieren';

  @override
  String get forgot_password => 'Passwort vergessen?';

  @override
  String get google_login => 'Weiter mit Google';

  @override
  String get profile_title => 'Profil';

  @override
  String get profile_logout => 'Abmelden';

  @override
  String get profile_language => 'Sprache';

  @override
  String get profile_theme => 'Thema';

  @override
  String get profile_rank => 'Rang';

  @override
  String get profile_guest => 'Als Gast anmelden';

  @override
  String get createTicketTitle => 'Schein erstellen';

  @override
  String get stakeHint => 'Einsatz';

  @override
  String get placeBet => 'Wette abgeben';

  @override
  String get errorInvalidStake => 'Ungültiger Einsatz';

  @override
  String get errorDuplicate => 'Doppelte Tipps sind nicht erlaubt';

  @override
  String get errorMatchConflict => 'Konfliktierende Tipps auf dasselbe Spiel';

  @override
  String get my_tickets_title => 'Meine Scheine';

  @override
  String get ticket_status_pending => 'Ausstehend';

  @override
  String get ticket_status_won => 'Gewonnen';

  @override
  String get ticket_status_lost => 'Verloren';

  @override
  String get ticket_status_void => 'Ungültig';

  @override
  String get empty_ticket_message => 'Du hast noch keine Scheine';

  @override
  String get ticket_details_title => 'Schein Details';

  @override
  String get api_error_limit => 'Odds API Anfrage-Limit überschritten';

  @override
  String get api_error_key => 'Ungültiger Odds API Schlüssel';

  @override
  String get api_error_network => 'Netzwerkfehler beim Kontaktieren der Odds API';

  @override
  String get api_error_unknown => 'Unbekannter Fehler von der Odds API';

  @override
  String get events_title => 'Ereignisse';

  @override
  String get events_empty => 'Keine Ereignisse verfügbar';

  @override
  String get events_screen_no_events => 'Keine Ereignisse gefunden';

  @override
  String get events_screen_quota_warning =>
      'Warnung: API Kontingent fast aufgebraucht';

  @override
  String get events_screen_refresh => 'Aktualisieren';

  @override
  String get events_screen_no_odds => 'Keine Quoten verfügbar';

  @override
  String get events_screen_no_market => 'Kein Markt verfügbar';

  @override
  String events_screen_start_time(Object time) {
    return 'Startzeit: $time';
  }

  @override
  String get events_screen_tip_added => 'Tipp hinzugefügt';

  @override
  String get events_screen_tip_duplicate => 'Tipp bereits hinzugefügt';

  @override
  String get add_tip => 'Hinzufügen';

  @override
  String get no_tips_selected => 'Keine Tipps ausgewählt';

  @override
  String get ticket_submit_success => 'Schein erfolgreich gesendet';

  @override
  String get ticket_submit_error => 'Fehler aufgetreten:';

  @override
  String get odds_label => 'Quote';

  @override
  String get total_odds_label => 'Gesamtquote';

  @override
  String get potential_win_label => 'Möglicher Gewinn';

  @override
  String get ticket_id => 'Schein';

  @override
  String get tips_label => 'Tipps';

  @override
  String get ok => 'OK';

  @override
  String get not_logged_in => 'Du bist nicht angemeldet.';

  @override
  String get profile_email => 'E-Mail';

  @override
  String get profile_name => 'Name';

  @override
  String get drawer_title => 'Menü';
}
