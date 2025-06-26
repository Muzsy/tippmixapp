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
  String get home_nav_feed => 'Feed';

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
  String get events_screen_quota_warning => 'Warnung: API Kontingent fast aufgebraucht';

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
  String get errorNotLoggedIn => 'Du bist nicht angemeldet.';

  @override
  String get profile_email => 'E-Mail';

  @override
  String get profile_name => 'Name';

  @override
  String get drawer_title => 'Menü';

  @override
  String get errorUserNotFound => 'Benutzer nicht gefunden. Bitte melde dich erneut an.';

  @override
  String get go_to_create_ticket => 'Wettschein abschicken';

  @override
  String get insufficient_permissions => 'Keine Berechtigung.';

  @override
  String get invalid_transaction_type => 'Ungültiger Transaktionstyp.';

  @override
  String get missing_transaction_id => 'TransactionId fehlt.';

  @override
  String get amount_must_be_integer => 'Betrag muss Ganzzahl sein.';

  @override
  String get admin_only_field => 'Dieses Feld darf nur von Admins geändert werden.';

  @override
  String get leaderboard_title => 'Bestenliste';

  @override
  String get leaderboard_you => 'Du';

  @override
  String get leaderboard_empty => 'Keine Benutzer vorhanden';

  @override
  String get leaderboard_mode_coin => 'TippCoin';

  @override
  String get leaderboard_mode_winrate => 'Gewinnrate';

  @override
  String get leaderboard_mode_streak => 'Serie';

  @override
  String get feed_title => 'Feed';

  @override
  String get menuLeaderboard => 'Bestenliste';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get menuFeed => 'Feed';

  @override
  String get settings_title => 'Einstellungen';

  @override
  String get settings_theme => 'Thema';

  @override
  String get settings_theme_system => 'System';

  @override
  String get settings_theme_light => 'Hell';

  @override
  String get settings_theme_dark => 'Dunkel';

  @override
  String get settings_language => 'Sprache';

  @override
  String get settings_logout => 'Abmelden';

  @override
  String get settings_ai_recommendations => 'AI-Empfehlungen';

  @override
  String get settings_push_notifications => 'Push-Benachrichtigungen';

  @override
  String get badge_rookie_title => 'Anfänger';

  @override
  String get badge_rookie_description => 'Erster Gewinn erzielt.';

  @override
  String get badge_hot_streak_title => 'Heiße Serie';

  @override
  String get badge_hot_streak_description => 'Drei Siege in Folge.';

  @override
  String get badge_parlay_pro_title => 'Parlay-Profi';

  @override
  String get badge_parlay_pro_description => 'Kombi mit 5+ Ereignissen gewonnen.';

  @override
  String get badge_night_owl_title => 'Nachteule';

  @override
  String get badge_night_owl_description => 'Schein nach Mitternacht gewonnen.';

  @override
  String get badge_comeback_kid_title => 'Comeback-Kid';

  @override
  String get badge_comeback_kid_description => 'Nach drei Niederlagen gewonnen.';

  @override
  String get profile_badges_empty => 'Noch keine Abzeichen';

  @override
  String get bonus_daily_received => 'Tagesbonus: +50 TippCoin!';

  @override
  String get bonus_daily_received_description => 'Danke für deine Aktivität!';

  @override
  String get feed_event_bet_placed => 'Wette platziert';

  @override
  String get feed_event_ticket_won => 'Schein gewonnen';

  @override
  String get feed_event_comment => 'Kommentar';

  @override
  String get feed_event_like => 'Gefällt mir';

  @override
  String get feed_report_success => 'Der Beitrag wurde unseren Moderatoren gemeldet.';

  @override
  String get feed_empty_state => 'Keine Beiträge vorhanden';

  @override
  String get feed_like => 'Gefällt mir';

  @override
  String get feed_comment => 'Kommentieren';

  @override
  String get feed_report => 'Melden';

  @override
  String get copy_success => 'Schein kopiert!';

  @override
  String get copy_edit_title => 'Kopierten Schein bearbeiten';

  @override
  String get copy_submit_button => 'Schein abgeben';

  @override
  String get copy_invalid_state => 'Schein wurde nicht geändert, daher kann er nicht abgegeben werden.';

  @override
  String get auth_error_user_not_found => 'Benutzer nicht gefunden';

  @override
  String get auth_error_wrong_password => 'Falsches Passwort';

  @override
  String get auth_error_email_already_in_use => 'E-Mail-Adresse bereits verwendet';

  @override
  String get auth_error_invalid_email => 'Ungültige E-Mail-Adresse';

  @override
  String get auth_error_weak_password => 'Schwaches Passwort';

  @override
  String get auth_error_unknown => 'Unbekannter Authentifizierungsfehler';

  @override
  String get menuBadges => 'Abzeichen';

  @override
  String get badgeScreenTitle => 'Verfügbare Abzeichen';

  @override
  String get badgeFilterAll => 'Alle';

  @override
  String get badgeFilterOwned => 'Vorhanden';

  @override
  String get badgeFilterMissing => 'Fehlend';

  @override
  String get menuRewards => 'Belohnungen';

  @override
  String get rewardTitle => 'Verfügbare Belohnungen';

  @override
  String get rewardClaim => 'Einsammeln';

  @override
  String get rewardClaimed => 'Bereits eingesammelt';

  @override
  String get rewardEmpty => 'Keine Belohnungen verfügbar';
}
