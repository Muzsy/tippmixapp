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
  String get home_tile_daily_bonus_title => 'Tagesbonus';

  @override
  String get home_tile_daily_bonus_collect => 'Einsammeln';

  @override
  String get home_tile_daily_bonus_claimed => 'Eingesammelt';

  @override
  String get home_tile_new_badge_title => 'Neues Abzeichen';

  @override
  String get home_tile_badge_earned_title => 'Neues Abzeichen erhalten';

  @override
  String get home_tile_badge_earned_cta => 'Alle anzeigen';

  @override
  String get home_tile_ai_tip_title => 'AI Tipp';

  @override
  String home_tile_ai_tip_description(Object percent, Object team) {
    return 'Laut KI ist heute ein Sieg von $team am wahrscheinlichsten ($percent%).';
  }

  @override
  String get home_tile_ai_tip_cta => 'Details anzeigen';

  @override
  String get home_tile_top_tipster_title => 'Spieler des Tages';

  @override
  String home_tile_top_tipster_description(Object username) {
    return '$username hat heute alle Tipps in deinem Club getroffen.';
  }

  @override
  String get home_tile_top_tipster_cta => 'Tipps anzeigen';

  @override
  String get home_tile_challenge_title => 'Eine Herausforderung wartet!';

  @override
  String get home_tile_challenge_daily_description => 'Tagesaufgabe: Gewinne heute 3 Wetten.';

  @override
  String home_tile_challenge_friend_description(Object username) {
    return '$username hat dich zu einem Wettduell herausgefordert!';
  }

  @override
  String get home_tile_challenge_cta_accept => 'Annehmen';

  @override
  String get home_tile_educational_tip_title => 'Wetttipp';

  @override
  String get home_tile_educational_tip_1 => 'Wusstest du? Mit Kombiwetten kannst du höhere Quoten erzielen.';

  @override
  String get home_tile_educational_tip_2 => 'Einzelwetten sind risikoärmer als Kombis.';

  @override
  String get home_tile_educational_tip_3 => 'Führe ein Wettprotokoll, um aus vergangenen Ergebnissen zu lernen.';

  @override
  String get home_tile_educational_tip_cta => 'Mehr Tipps';

  @override
  String get home_tile_feed_activity_title => 'Neueste Aktivität';

  @override
  String home_tile_feed_activity_text_template(Object username) {
    return '$username hat einen Gewinn-Tipp geteilt!';
  }

  @override
  String get home_tile_feed_activity_cta => 'Ansehen';

  @override
  String get login_welcome => 'Willkommen bei Tippmix!';

  @override
  String get login_title => 'Anmelden';

  @override
  String get login_tab => 'Login';

  @override
  String get register_tab => 'Registrieren';

  @override
  String get email_hint => 'Email';

  @override
  String get password_hint => 'Password';

  @override
  String get confirm_password_hint => 'Confirm Password';

  @override
  String get login_button => 'Login';

  @override
  String get register_button => 'Registrieren';

  @override
  String get register_link => 'Konto erstellen';

  @override
  String get forgot_password => 'Passwort vergessen?';

  @override
  String get verification_email_sent => 'Bestätigungs-E-Mail gesendet';

  @override
  String get password_reset_title => 'Passwort zurücksetzen';

  @override
  String get password_reset_email_sent => 'Passwort-Zurücksetzen-E-Mail gesendet';

  @override
  String get google_login => 'Weiter mit Google';

  @override
  String get apple_login => 'Weiter mit Apple';

  @override
  String get facebook_login => 'Weiter mit Facebook';

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
  String get bets_title => 'Wetten';

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
  String get profile_nickname => 'Spitzname';

  @override
  String get profile_is_private => 'Privates Profil';

  @override
  String get profile_city => 'Stadt';

  @override
  String get profile_country => 'Land';

  @override
  String get profile_friends => 'Freunde';

  @override
  String get profile_favorite_sports => 'Lieblingssportarten';

  @override
  String get profile_favorite_teams => 'Lieblingsteams';

  @override
  String get profile_public => 'Öffentlich';

  @override
  String get profile_private => 'Privat';

  @override
  String get profile_toggle_visibility => 'Sichtbarkeit umschalten';

  @override
  String get profile_global_privacy => 'Globaler Privatschalter';

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
  String get feed_screen_title => 'Feed';

  @override
  String get menuLeaderboard => 'Bestenliste';

  @override
  String get menuProfile => 'Profil';

  @override
  String get myTickets => 'Meine Scheine';

  @override
  String get menuSettings => 'Einstellungen';

  @override
  String get drawer_feed => 'Feed';

  @override
  String get bottom_nav_feed => 'Feed';

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
  String get settings_dark_mode => 'Dunkler Modus';

  @override
  String get settings_language => 'Sprache';

  @override
  String get settings_logout => 'Abmelden';

  @override
  String get settings_ai_recommendations => 'AI-Empfehlungen';

  @override
  String get settings_push_notifications => 'Push-Benachrichtigungen';

  @override
  String get settings_skin => 'Skin';

  @override
  String get skin_dell_genoa_name => 'Tippmix Grün';

  @override
  String get skin_dell_genoa_description => 'Standard Tippmix-Farbschema (grün)';

  @override
  String get skin_pink_m3_name => 'Pink Party';

  @override
  String get skin_pink_m3_description => 'Verspieltes, fröhliches Skin';

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

  @override
  String reward_balance(Object coins) {
    return 'Guthaben: $coins';
  }

  @override
  String reward_streak(Object days) {
    return 'Serie: $days/7';
  }

  @override
  String get menuNotifications => 'Benachrichtigungen';

  @override
  String get notificationTitle => 'Ereignisse';

  @override
  String get notificationEmpty => 'Keine neuen Ereignisse';

  @override
  String get notificationMarkRead => 'Als gelesen markieren';

  @override
  String get notificationFilterAll => 'Alle';

  @override
  String get notificationFilterUnread => 'Ungelesen';

  @override
  String get notificationArchive => 'Archivieren';

  @override
  String get notificationUndo => 'Rückgängig';

  @override
  String get notificationType_reward => 'Belohnung';

  @override
  String get notificationType_badge => 'Abzeichen';

  @override
  String get notificationType_friend => 'Freundschaftsanfrage';

  @override
  String get notificationType_message => 'Nachricht';

  @override
  String get notificationType_challenge => 'Herausforderung';

  @override
  String get dialog_cancel => 'Abbrechen';

  @override
  String get dialog_send => 'Senden';

  @override
  String get dialog_reason_hint => 'Grund';

  @override
  String get dialog_comment_title => 'Kommentar';

  @override
  String get dialog_add_comment_hint => 'Kommentar hinzufügen';

  @override
  String get profile_stats => 'Statistiken';

  @override
  String get profile_badges => 'Abzeichen';

  @override
  String get profile_level => 'Stufe';

  @override
  String get profile_coins => 'TippCoin';

  @override
  String get profileAvatarGallery => 'Avatar Galerie';

  @override
  String get profileUploadPhoto => 'Eigenes Foto hochladen';

  @override
  String get profileResetAvatar => 'Standardavatar wiederherstellen';

  @override
  String get profileChooseAvatar => 'Avatar auswählen';

  @override
  String get profile_avatar_error => 'Fehler beim Aktualisieren des Avatars';

  @override
  String get profile_avatar_updated => 'Avatar aktualisiert';

  @override
  String get profile_avatar_cancelled => 'Avatar-Upload abgebrochen';

  @override
  String get notif_tips => 'Tipps';

  @override
  String get notif_friend_activity => 'Freunde-Aktivitäten';

  @override
  String get notif_badge => 'Abzeichen';

  @override
  String get notif_rewards => 'Belohnungen';

  @override
  String get notif_system => 'System';

  @override
  String get edit_title => 'Profil bearbeiten';

  @override
  String get name_hint => 'Anzeigename';

  @override
  String get name_error_short => 'Name zu kurz';

  @override
  String get name_error_long => 'Name zu lang';

  @override
  String get bio_hint => 'Bio';

  @override
  String get team_hint => 'Lieblingsteam';

  @override
  String get dob_hint => 'Geburtsdatum';

  @override
  String get dob_error_underage => 'Mindestens 18 Jahre erforderlich';

  @override
  String get dob_error_future => 'Datum darf nicht in der Zukunft liegen';

  @override
  String get profile_updated => 'Profil aktualisiert';

  @override
  String get security_title => 'Sicherheit';

  @override
  String get enable_two_factor => 'Zwei-Faktor-Authentifizierung aktivieren';

  @override
  String get disable_two_factor => 'Zwei-Faktor-Authentifizierung deaktivieren';

  @override
  String get otp_prompt_title => 'OTP eingeben';

  @override
  String get otp_enter_code => 'Code';

  @override
  String get otp_error_invalid => 'Ungültiger Code';

  @override
  String get backup_codes_title => 'Backup-Codes';

  @override
  String get verified_badge_label => 'Verifiziert';

  @override
  String get follow => 'Folgen';

  @override
  String get unfollow => 'Entfolgen';

  @override
  String get addFriend => 'Freund hinzufügen';

  @override
  String get requestSent => 'Anfrage gesendet';

  @override
  String get friends => 'Freunde';

  @override
  String get followers => 'Follower';

  @override
  String get pending => 'Ausstehend';

  @override
  String get accept => 'Akzeptieren';

  @override
  String get login_variant_b_promo_title => 'Bereits 50.000+ Nutzer';

  @override
  String get login_variant_b_promo_subtitle => 'Werde Teil unserer Community!';

  @override
  String get onboarding_place_bet => 'Platziere Wetten einfach';

  @override
  String get onboarding_track_rewards => 'Verfolge deine Belohnungen';

  @override
  String get onboarding_follow_tipsters => 'Folge Top-Tipstern';

  @override
  String get onboarding_skip => 'Überspringen';

  @override
  String get onboarding_next => 'Weiter';

  @override
  String get onboarding_done => 'Fertig';

  @override
  String get continue_button => 'Weiter';

  @override
  String get password_strength_weak => 'Schwach';

  @override
  String get password_strength_medium => 'Mittel';

  @override
  String get password_strength_strong => 'Stark';

  @override
  String get errorInvalidEmail => 'Ungültige E-Mail-Adresse';

  @override
  String get errorWeakPassword => 'Schwaches Passwort';

  @override
  String get errorEmailExists => 'Diese E-Mail-Adresse ist bereits vergeben';

  @override
  String get loaderCheckingEmail => 'E-Mail wird überprüft...';

  @override
  String get passwordStrengthVeryWeak => 'Sehr schwach';

  @override
  String get passwordStrengthStrong => 'Stark';

  @override
  String get btnContinue => 'Weiter';

  @override
  String get gdpr_consent => 'Ich stimme der Datenschutzerklärung zu';

  @override
  String get gdpr_required_error => 'GDPR-Zustimmung erforderlich';

  @override
  String get auth_error_invalid_nickname => 'Der Spitzname muss 3-20 Zeichen lang sein';

  @override
  String get auth_error_invalid_date => 'Ungültiges Datum';

  @override
  String get auth_error_nickname_taken => 'Der Spitzname ist bereits vergeben';

  @override
  String get register_take_photo => 'Foto aufnehmen';

  @override
  String get register_choose_file => 'Datei auswählen';

  @override
  String get register_finish => 'Fertig';

  @override
  String get register_skip => 'Überspringen';

  @override
  String get register_avatar_too_large => 'Avatar darf maximal 2 MB sein';

  @override
  String get back_button => 'Zurück';

  @override
  String get login_required_title => 'Anmeldung erforderlich';

  @override
  String get login_required_message => 'Bitte melde dich an, um fortzufahren';
}
