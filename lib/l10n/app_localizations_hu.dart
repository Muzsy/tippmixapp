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
  String get home_tile_daily_bonus_title => 'Napi bónusz';

  @override
  String get home_tile_daily_bonus_collect => 'Begyűjtés';

  @override
  String get home_tile_daily_bonus_claimed => 'Begyűjtve';

  @override
  String get home_tile_new_badge_title => 'Új jelvény';

  @override
  String get home_tile_badge_earned_title => 'Új jelvényt szereztél';

  @override
  String get home_tile_badge_earned_cta => 'Megtekintés';

  @override
  String get home_tile_ai_tip_title => 'AI ajánlás';

  @override
  String home_tile_ai_tip_description(Object percent, Object team) {
    return 'AI szerint ma a $team győzelme a legvalószínűbb ($percent%).';
  }

  @override
  String get home_tile_ai_tip_cta => 'Részletek';

  @override
  String get home_tile_top_tipster_title => 'A nap játékosa';

  @override
  String home_tile_top_tipster_description(Object username) {
    return '$username ma 5/5 tippet talált el a klubodban.';
  }

  @override
  String get home_tile_top_tipster_cta => 'Megnézem a tippjeit';

  @override
  String get home_tile_challenge_title => 'Kihívás vár rád!';

  @override
  String get home_tile_challenge_daily_description => 'Napi kihívás: nyerj ma 3 fogadást.';

  @override
  String home_tile_challenge_friend_description(Object username) {
    return '$username kihívott egy tipppárbajra!';
  }

  @override
  String get home_tile_challenge_cta_accept => 'Elfogadom';

  @override
  String get home_tile_educational_tip_title => 'Fogadási tipp';

  @override
  String get home_tile_educational_tip_1 => 'Tudtad? Kombinált fogadással magasabb oddsszal nyerhetsz.';

  @override
  String get home_tile_educational_tip_2 => 'Egyszerűbb fogadással kisebb a kockázat.';

  @override
  String get home_tile_educational_tip_3 => 'Vezesd a fogadási naplód, hogy tanulhass a múltból.';

  @override
  String get home_tile_educational_tip_cta => 'További tippek';

  @override
  String get home_tile_feed_activity_title => 'Legújabb aktivitás';

  @override
  String home_tile_feed_activity_text_template(Object username) {
    return '$username megosztott egy nyertes tippet!';
  }

  @override
  String get home_tile_feed_activity_cta => 'Megnézem';

  @override
  String get login_welcome => 'Üdvözlünk a Tippmixen!';

  @override
  String get login_title => 'Bejelentkezés';

  @override
  String get login_tab => 'Belépés';

  @override
  String get register_tab => 'Regisztráció';

  @override
  String get email_hint => 'Email';

  @override
  String get password_hint => 'Password';

  @override
  String get confirm_password_hint => 'Confirm Password';

  @override
  String get login_button => 'Login';

  @override
  String get register_button => 'Regisztráció';

  @override
  String get register_link => 'Fiók létrehozása';

  @override
  String get forgot_password => 'Elfelejtett jelszó?';

  @override
  String get verification_email_sent => 'Megerősítő email elküldve';

  @override
  String get password_reset_title => 'Jelszó visszaállítása';

  @override
  String get password_reset_email_sent => 'Jelszó visszaállító email elküldve';

  @override
  String get google_login => 'Folytatás Google-lel';

  @override
  String get apple_login => 'Folytatás Apple-lel';

  @override
  String get facebook_login => 'Folytatás Facebookkal';

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
  String get bets_title => 'Fogadások';

  @override
  String get events_empty => 'Nincs elérhető esemény';

  @override
  String get events_screen_no_events => 'Nincs esemény';

  @override
  String get events_screen_quota_warning => 'Figyelem: az API kvóta hamarosan elfogy';

  @override
  String get events_screen_refresh => 'Frissítés';

  @override
  String get events_screen_no_odds => 'Nincs elérhető odds';

  @override
  String get events_screen_no_market => 'Nincs elérhető piac';

  @override
  String events_screen_start_time(Object time) {
    return 'Kezdés: $time';
  }

  @override
  String get events_screen_tip_added => 'Tipp hozzáadva';

  @override
  String get events_screen_tip_duplicate => 'A tipp már hozzá van adva';

  @override
  String get add_tip => 'Hozzáadás';

  @override
  String get no_tips_selected => 'Nincs kiválasztott tipp';

  @override
  String get ticket_submit_success => 'Szelvény sikeresen elküldve';

  @override
  String get ticket_submit_error => 'Hiba történt:';

  @override
  String get odds_label => 'Odds';

  @override
  String get total_odds_label => 'Össz odds';

  @override
  String get potential_win_label => 'Várható nyeremény';

  @override
  String get ticket_id => 'Szelvény';

  @override
  String get tips_label => 'Tippek';

  @override
  String get ok => 'OK';

  @override
  String get not_logged_in => 'Nem vagy bejelentkezve.';

  @override
  String get errorNotLoggedIn => 'Nem vagy bejelentkezve.';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_name => 'Név';

  @override
  String get profile_nickname => 'Becenév';

  @override
  String get profile_is_private => 'Privát profil';

  @override
  String get profile_city => 'Város';

  @override
  String get profile_country => 'Ország';

  @override
  String get profile_friends => 'Barátok';

  @override
  String get profile_favorite_sports => 'Kedvenc sportok';

  @override
  String get profile_favorite_teams => 'Kedvenc csapatok';

  @override
  String get profile_public => 'Publikus';

  @override
  String get profile_private => 'Privát';

  @override
  String get profile_toggle_visibility => 'Mező láthatósága';

  @override
  String get profile_global_privacy => 'Globális privát kapcsoló';

  @override
  String get drawer_title => 'Menü';

  @override
  String get errorUserNotFound => 'Felhasználó nem található. Jelentkezz be újra.';

  @override
  String get go_to_create_ticket => 'Szelvény elküldése';

  @override
  String get insufficient_permissions => 'Nincs jogosultság.';

  @override
  String get invalid_transaction_type => 'Érvénytelen tranzakció típus.';

  @override
  String get missing_transaction_id => 'Hiányzik a tranzakció azonosító.';

  @override
  String get amount_must_be_integer => 'Az összegnek egész számnak kell lennie.';

  @override
  String get admin_only_field => 'Ezt a mezőt csak admin módosíthatja.';

  @override
  String get leaderboard_title => 'Ranglista';

  @override
  String get leaderboard_you => 'Te';

  @override
  String get leaderboard_empty => 'Nincs megjeleníthető felhasználó';

  @override
  String get leaderboard_mode_coin => 'TippCoin';

  @override
  String get leaderboard_mode_winrate => 'Nyerési arány';

  @override
  String get leaderboard_mode_streak => 'Sorozat';

  @override
  String get feed_screen_title => 'Hírfolyam';

  @override
  String get menuLeaderboard => 'Ranglista';

  @override
  String get menuProfile => 'Profil';

  @override
  String get myTickets => 'Szelvényeim';

  @override
  String get menuSettings => 'Beállítások';

  @override
  String get drawer_feed => 'Hírfolyam';

  @override
  String get bottom_nav_feed => 'Hírfolyam';

  @override
  String get settings_title => 'Beállítások';

  @override
  String get settings_theme => 'Téma';

  @override
  String get settings_theme_system => 'Rendszer';

  @override
  String get settings_theme_light => 'Világos';

  @override
  String get settings_theme_dark => 'Sötét';

  @override
  String get settings_dark_mode => 'Sötét mód';

  @override
  String get settings_language => 'Nyelv';

  @override
  String get settings_logout => 'Kijelentkezés';

  @override
  String get settings_ai_recommendations => 'AI ajánlások';

  @override
  String get settings_push_notifications => 'Értesítések';

  @override
  String get settings_skin => 'Skin';

  @override
  String get skin_dell_genoa_name => 'Tippmix Zöld';

  @override
  String get skin_dell_genoa_description => 'Alap Tippmix színséma (zöld)';

  @override
  String get skin_pink_m3_name => 'Pink Party';

  @override
  String get skin_pink_m3_description => 'Lányos, vidám skin';

  @override
  String get badge_rookie_title => 'Újonc';

  @override
  String get badge_rookie_description => 'Első nyertes fogadásod.';

  @override
  String get badge_hot_streak_title => 'Forró széria';

  @override
  String get badge_hot_streak_description => 'Három egymást követő győzelem.';

  @override
  String get badge_parlay_pro_title => 'Kombi szakértő';

  @override
  String get badge_parlay_pro_description => '5+ eseményes kombi szelvény nyerése.';

  @override
  String get badge_night_owl_title => 'Éjjeli bagoly';

  @override
  String get badge_night_owl_description => 'Éjfél utáni nyerő szelvény.';

  @override
  String get badge_comeback_kid_title => 'Visszatérő';

  @override
  String get badge_comeback_kid_description => 'Három vereség után nyert szelvény.';

  @override
  String get profile_badges_empty => 'Még nem szereztél badge-et';

  @override
  String get bonus_daily_received => 'Napi bónusz: +50 TippCoin!';

  @override
  String get bonus_daily_received_description => 'Köszönjük, hogy aktív vagy!';

  @override
  String get feed_event_bet_placed => 'Fogadást tett';

  @override
  String get feed_event_ticket_won => 'Szelvényt nyert';

  @override
  String get feed_event_comment => 'Komment';

  @override
  String get feed_event_like => 'Lájk';

  @override
  String get feed_report_success => 'A bejegyzést jelentettük moderátorainknak.';

  @override
  String get feed_empty_state => 'Nincs megjeleníthető bejegyzés';

  @override
  String get feed_like => 'Tetszik';

  @override
  String get feed_comment => 'Hozzászólás';

  @override
  String get feed_report => 'Jelentés';

  @override
  String get copy_success => 'Szelvény másolva!';

  @override
  String get copy_edit_title => 'Másolt szelvény szerkesztése';

  @override
  String get copy_submit_button => 'Szelvény feladása';

  @override
  String get copy_invalid_state => 'A szelvény nem módosult, így nem adható fel.';

  @override
  String get auth_error_user_not_found => 'Felhasználó nem található';

  @override
  String get auth_error_wrong_password => 'Hibás jelszó';

  @override
  String get auth_error_email_already_in_use => 'Az email cím már használatban van';

  @override
  String get auth_error_invalid_email => 'Érvénytelen email cím';

  @override
  String get auth_error_weak_password => 'Gyenge jelszó';

  @override
  String get auth_error_unknown => 'Ismeretlen hiba';

  @override
  String get menuBadges => 'Jelvényeim';

  @override
  String get badgeScreenTitle => 'Megszerezhető jelvények';

  @override
  String get badgeFilterAll => 'Összes';

  @override
  String get badgeFilterOwned => 'Megvan';

  @override
  String get badgeFilterMissing => 'Hiányzik';

  @override
  String get menuRewards => 'Jutalmaim';

  @override
  String get rewardTitle => 'Átvehető jutalmak';

  @override
  String get rewardClaim => 'Átvétel';

  @override
  String get rewardClaimed => 'Már átvetted';

  @override
  String get rewardEmpty => 'Nincs elérhető jutalom';

  @override
  String reward_balance(Object coins) {
    return 'Egyenleg: $coins';
  }

  @override
  String reward_streak(Object days) {
    return 'Sorozat: $days/7';
  }

  @override
  String get menuNotifications => 'Értesítések';

  @override
  String get notificationTitle => 'Események';

  @override
  String get notificationEmpty => 'Nincs új esemény';

  @override
  String get notificationMarkRead => 'Olvasottként jelölés';

  @override
  String get notificationFilterAll => 'Összes';

  @override
  String get notificationFilterUnread => 'Olvasatlan';

  @override
  String get notificationArchive => 'Archiválás';

  @override
  String get notificationUndo => 'Visszavonás';

  @override
  String get notificationType_reward => 'Jutalom';

  @override
  String get notificationType_badge => 'Jelvény';

  @override
  String get notificationType_friend => 'Barátkérés';

  @override
  String get notificationType_message => 'Üzenet';

  @override
  String get notificationType_challenge => 'Kihívás';

  @override
  String get dialog_cancel => 'Mégse';

  @override
  String get dialog_send => 'Küldés';

  @override
  String get dialog_reason_hint => 'Indok';

  @override
  String get dialog_comment_title => 'Hozzászólás';

  @override
  String get dialog_add_comment_hint => 'Adj hozzá megjegyzést';

  @override
  String get profile_stats => 'Statisztikák';

  @override
  String get profile_badges => 'Kitüntetések';

  @override
  String get profile_level => 'Szint';

  @override
  String get profile_coins => 'TippCoin';

  @override
  String get profileAvatarGallery => 'Avatar galéria';

  @override
  String get profileUploadPhoto => 'Saját kép feltöltése';

  @override
  String get profileResetAvatar => 'Alap avatar visszaállítása';

  @override
  String get profileChooseAvatar => 'Válassz avatart';

  @override
  String get profileCropImage => 'Kép kivágása';

  @override
  String get profile_avatar_error => 'Hiba történt az avatar beállításakor';

  @override
  String get profile_avatar_updated => 'Avatar frissítve';

  @override
  String get profile_avatar_cancelled => 'Avatar feltöltés megszakítva';

  @override
  String get notif_tips => 'Tippek';

  @override
  String get notif_friend_activity => 'Barátok aktivitása';

  @override
  String get notif_badge => 'Jelvények';

  @override
  String get notif_rewards => 'Jutalmak';

  @override
  String get notif_system => 'Rendszer';

  @override
  String get edit_title => 'Profil szerkesztése';

  @override
  String get name_hint => 'Megjelenített név';

  @override
  String get name_error_short => 'Túl rövid név';

  @override
  String get name_error_long => 'Túl hosszú név';

  @override
  String get bio_hint => 'Bemutatkozás';

  @override
  String get team_hint => 'Kedvenc csapat';

  @override
  String get dob_hint => 'Születési dátum';

  @override
  String get dob_error_underage => 'Legalább 18 évesnek kell lenned';

  @override
  String get dob_error_future => 'A dátum nem lehet jövőbeni';

  @override
  String get profile_updated => 'Profil frissítve';

  @override
  String get security_title => 'Biztonság';

  @override
  String get enable_two_factor => 'Kétlépcsős hitelesítés bekapcsolása';

  @override
  String get disable_two_factor => 'Kétlépcsős hitelesítés kikapcsolása';

  @override
  String get otp_prompt_title => 'OTP megadása';

  @override
  String get otp_enter_code => 'Kód';

  @override
  String get otp_error_invalid => 'Érvénytelen kód';

  @override
  String get backup_codes_title => 'Mentőkódok';

  @override
  String get verified_badge_label => 'Ellenőrzött';

  @override
  String get follow => 'Követés';

  @override
  String get unfollow => 'Követve';

  @override
  String get addFriend => 'Ismerősnek jelöl';

  @override
  String get requestSent => 'Kérelem elküldve';

  @override
  String get friends => 'Barátok';

  @override
  String get followers => 'Követők';

  @override
  String get pending => 'Függőben';

  @override
  String get accept => 'Elfogad';

  @override
  String get login_variant_b_promo_title => 'Már 50 000+ felhasználó';

  @override
  String get login_variant_b_promo_subtitle => 'Csatlakozz és játssz velünk!';

  @override
  String get onboarding_place_bet => 'Fogadj könnyedén';

  @override
  String get onboarding_track_rewards => 'Kövesd a jutalmakat';

  @override
  String get onboarding_follow_tipsters => 'Kövesd a tippmestereket';

  @override
  String get onboarding_skip => 'Kihagyom';

  @override
  String get onboarding_next => 'Tovább';

  @override
  String get onboarding_done => 'Kész';

  @override
  String get continue_button => 'Folytatás';

  @override
  String get password_strength_weak => 'Gyenge';

  @override
  String get password_strength_medium => 'Közepes';

  @override
  String get password_strength_strong => 'Erős';

  @override
  String get gdpr_consent => 'Elfogadom az adatkezelési tájékoztatót';

  @override
  String get gdpr_required_error => 'A GDPR hozzájárulás kötelező';

  @override
  String get auth_error_invalid_nickname => 'A becenév 3-20 karakter hosszú legyen';

  @override
  String get auth_error_invalid_date => 'Érvénytelen dátum';

  @override
  String get auth_error_nickname_taken => 'A becenév már foglalt';

  @override
  String get register_take_photo => 'Készíts fotót';

  @override
  String get register_choose_file => 'Fájl kiválasztása';

  @override
  String get register_finish => 'Befejezés';

  @override
  String get register_skip => 'Kihagyás';

  @override
  String get register_avatar_too_large => 'Az avatar mérete legfeljebb 2 MB lehet';

  @override
  String get back_button => 'Vissza';
}
