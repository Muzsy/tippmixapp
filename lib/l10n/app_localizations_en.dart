// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home_title => 'Home';

  @override
  String get home_guest_message => 'Log in or register to view your profile';

  @override
  String get home_coin => 'TippCoin';

  @override
  String get home_stats => 'Stats';

  @override
  String get home_nav_profile => 'Profile';

  @override
  String get home_nav_stats => 'Stats';

  @override
  String get home_nav_messages => 'Messages';

  @override
  String get home_nav_forum => 'Forum';

  @override
  String get home_tile_bets => 'Bets';

  @override
  String get home_tile_news => 'News Feed';

  @override
  String get home_tile_my_bets => 'My Bets';

  @override
  String get home_tile_friends => 'Friends';

  @override
  String get home_highlight_tip => 'Daily Tip: Bayern wins';

  @override
  String get home_highlight_motivation => 'Motivation: Try a new strategy!';

  @override
  String get home_highlight_coin => 'TippCoin: Earn extra coins with activity!';

  @override
  String get login_title => 'Sign In';

  @override
  String get login_tab => 'Login';

  @override
  String get register_tab => 'Register';

  @override
  String get email_hint => 'Email';

  @override
  String get password_hint => 'Password';

  @override
  String get confirm_password_hint => 'Confirm Password';

  @override
  String get login_button => 'Login';

  @override
  String get register_button => 'Register';

  @override
  String get forgot_password => 'Forgot password?';

  @override
  String get google_login => 'Continue with Google';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_logout => 'Logout';

  @override
  String get profile_language => 'Language';

  @override
  String get profile_theme => 'Theme';

  @override
  String get profile_rank => 'Rank';

  @override
  String get profile_guest => 'Sign in as guest';

  @override
  String get createTicketTitle => 'Create Ticket';

  @override
  String get stakeHint => 'Stake';

  @override
  String get placeBet => 'Place Bet';

  @override
  String get errorInvalidStake => 'Invalid stake';

  @override
  String get errorDuplicate => 'Duplicate tips are not allowed';

  @override
  String get errorMatchConflict => 'Conflicting tips on the same match';

  @override
  String get my_tickets_title => 'My Tickets';

  @override
  String get ticket_status_pending => 'Pending';

  @override
  String get ticket_status_won => 'Won';

  @override
  String get ticket_status_lost => 'Lost';

  @override
  String get ticket_status_void => 'Void';

  @override
  String get empty_ticket_message => 'You have no tickets yet';

  @override
  String get ticket_details_title => 'Ticket Details';

  @override
  String get api_error_limit => 'Odds API rate limit exceeded';

  @override
  String get api_error_key => 'Invalid Odds API key';

  @override
  String get api_error_network => 'Network error while contacting Odds API';

  @override
  String get api_error_unknown => 'Unknown error from Odds API';

  @override
  String get events_title => 'Events';

  @override
  String get events_empty => 'No events available';

  @override
  String get events_screen_no_events => 'No events found';

  @override
  String get events_screen_quota_warning => 'API quota is nearly exceeded';

  @override
  String get events_screen_refresh => 'Refresh';

  @override
  String get events_screen_no_odds => 'No odds available';

  @override
  String get events_screen_no_market => 'No market data';

  @override
  String events_screen_start_time(Object time) {
    return 'Start time: $time';
  }

  @override
  String get events_screen_tip_added => 'Tip added';

  @override
  String get events_screen_tip_duplicate => 'Tip already added';

  @override
  String get add_tip => 'Add';

  @override
  String get no_tips_selected => 'No tips selected';

  @override
  String get ticket_submit_success => 'Ticket submitted successfully';

  @override
  String get ticket_submit_error => 'Error occurred:';

  @override
  String get odds_label => 'Odds';

  @override
  String get total_odds_label => 'Total odds';

  @override
  String get potential_win_label => 'Potential win';

  @override
  String get ticket_id => 'Ticket';

  @override
  String get tips_label => 'Tips';

  @override
  String get ok => 'OK';

  @override
  String get not_logged_in => 'You are not logged in.';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_name => 'Name';

  @override
  String get drawer_title => 'Drawer';

  @override
  String get menuLeaderboard => 'Leaderboard';

  @override
  String get menuSettings => 'Settings';

  @override
  String get errorUserNotFound => 'User not found. Please log in again.';

  @override
  String get go_to_create_ticket => 'Submit Ticket';
@override
  String get leaderboard_title => 'Leaderboard';
  @override
  String get leaderboard_you => 'You';
  @override
  String get leaderboard_empty => 'No users yet';
  @override
  String get leaderboard_mode_coin => 'TippCoin';
  @override
  String get leaderboard_mode_winrate => 'Win rate';
  @override
  String get leaderboard_mode_streak => 'Win streak';
  @override
  String get settings_title => 'Settings';
  @override
  String get settings_theme => 'Theme';
  @override
  String get settings_theme_system => 'System';
  @override
  String get settings_theme_light => 'Light';
  @override
  String get settings_theme_dark => 'Dark';
  @override
  String get settings_language => 'Language';
  @override
  String get settings_logout => 'Logout';
  @override
  String get settings_ai_recommendations => 'AI recommendations';
  @override
  String get settings_push_notifications => 'Push notifications';
}
