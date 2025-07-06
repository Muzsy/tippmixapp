import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('hu')
  ];

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home_title;

  /// No description provided for @home_guest_message.
  ///
  /// In en, this message translates to:
  /// **'Log in or register to view your profile'**
  String get home_guest_message;

  /// No description provided for @home_coin.
  ///
  /// In en, this message translates to:
  /// **'TippCoin'**
  String get home_coin;

  /// No description provided for @home_stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get home_stats;

  /// No description provided for @home_nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get home_nav_profile;

  /// No description provided for @home_nav_stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get home_nav_stats;

  /// No description provided for @home_nav_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get home_nav_messages;

  /// No description provided for @home_nav_forum.
  ///
  /// In en, this message translates to:
  /// **'Forum'**
  String get home_nav_forum;

  /// No description provided for @home_tile_bets.
  ///
  /// In en, this message translates to:
  /// **'Bets'**
  String get home_tile_bets;

  /// No description provided for @home_tile_news.
  ///
  /// In en, this message translates to:
  /// **'News Feed'**
  String get home_tile_news;

  /// No description provided for @home_tile_my_bets.
  ///
  /// In en, this message translates to:
  /// **'My Bets'**
  String get home_tile_my_bets;

  /// No description provided for @home_tile_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get home_tile_friends;

  /// No description provided for @home_highlight_tip.
  ///
  /// In en, this message translates to:
  /// **'Daily Tip: Bayern wins'**
  String get home_highlight_tip;

  /// No description provided for @home_highlight_motivation.
  ///
  /// In en, this message translates to:
  /// **'Motivation: Try a new strategy!'**
  String get home_highlight_motivation;

  /// No description provided for @home_highlight_coin.
  ///
  /// In en, this message translates to:
  /// **'TippCoin: Earn extra coins with activity!'**
  String get home_highlight_coin;

  /// No description provided for @home_tile_daily_bonus_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Bonus'**
  String get home_tile_daily_bonus_title;

  /// No description provided for @home_tile_daily_bonus_collect.
  ///
  /// In en, this message translates to:
  /// **'Collect'**
  String get home_tile_daily_bonus_collect;

  /// No description provided for @home_tile_daily_bonus_claimed.
  ///
  /// In en, this message translates to:
  /// **'Collected'**
  String get home_tile_daily_bonus_claimed;

  /// No description provided for @home_tile_new_badge_title.
  ///
  /// In en, this message translates to:
  /// **'New Badge'**
  String get home_tile_new_badge_title;

  /// No description provided for @home_tile_badge_earned_title.
  ///
  /// In en, this message translates to:
  /// **'Badge Earned'**
  String get home_tile_badge_earned_title;

  /// No description provided for @home_tile_badge_earned_cta.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get home_tile_badge_earned_cta;

  /// No description provided for @home_tile_ai_tip_title.
  ///
  /// In en, this message translates to:
  /// **'AI Recommendation'**
  String get home_tile_ai_tip_title;

  /// No description provided for @home_tile_ai_tip_description.
  ///
  /// In en, this message translates to:
  /// **'According to AI, {team} is most likely to win today ({percent}%).'**
  String home_tile_ai_tip_description(Object percent, Object team);

  /// No description provided for @home_tile_ai_tip_cta.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get home_tile_ai_tip_cta;

  /// No description provided for @home_tile_top_tipster_title.
  ///
  /// In en, this message translates to:
  /// **'Player of the Day'**
  String get home_tile_top_tipster_title;

  /// No description provided for @home_tile_top_tipster_description.
  ///
  /// In en, this message translates to:
  /// **'{username} hit all tips in your club today.'**
  String home_tile_top_tipster_description(Object username);

  /// No description provided for @home_tile_top_tipster_cta.
  ///
  /// In en, this message translates to:
  /// **'View tips'**
  String get home_tile_top_tipster_cta;

  /// No description provided for @home_tile_challenge_title.
  ///
  /// In en, this message translates to:
  /// **'Challenge awaits!'**
  String get home_tile_challenge_title;

  /// No description provided for @home_tile_challenge_daily_description.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge: win 3 bets today.'**
  String get home_tile_challenge_daily_description;

  /// No description provided for @home_tile_challenge_friend_description.
  ///
  /// In en, this message translates to:
  /// **'{username} challenged you to a betting duel!'**
  String home_tile_challenge_friend_description(Object username);

  /// No description provided for @home_tile_challenge_cta_accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get home_tile_challenge_cta_accept;

  /// No description provided for @home_tile_educational_tip_title.
  ///
  /// In en, this message translates to:
  /// **'Betting tip'**
  String get home_tile_educational_tip_title;

  /// No description provided for @home_tile_educational_tip_1.
  ///
  /// In en, this message translates to:
  /// **'Did you know? Combining bets can increase your odds.'**
  String get home_tile_educational_tip_1;

  /// No description provided for @home_tile_educational_tip_2.
  ///
  /// In en, this message translates to:
  /// **'Single bets carry less risk than accumulators.'**
  String get home_tile_educational_tip_2;

  /// No description provided for @home_tile_educational_tip_3.
  ///
  /// In en, this message translates to:
  /// **'Track your betting history to learn from past results.'**
  String get home_tile_educational_tip_3;

  /// No description provided for @home_tile_educational_tip_cta.
  ///
  /// In en, this message translates to:
  /// **'More tips'**
  String get home_tile_educational_tip_cta;

  /// No description provided for @home_tile_feed_activity_title.
  ///
  /// In en, this message translates to:
  /// **'Latest activity'**
  String get home_tile_feed_activity_title;

  /// No description provided for @home_tile_feed_activity_text_template.
  ///
  /// In en, this message translates to:
  /// **'{username} shared a winning tip!'**
  String home_tile_feed_activity_text_template(Object username);

  /// No description provided for @home_tile_feed_activity_cta.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get home_tile_feed_activity_cta;

  /// No description provided for @login_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Tippmix!'**
  String get login_welcome;

  /// No description provided for @login_title.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get login_title;

  /// No description provided for @login_tab.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_tab;

  /// No description provided for @register_tab.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_tab;

  /// No description provided for @email_hint.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email_hint;

  /// No description provided for @password_hint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password_hint;

  /// No description provided for @confirm_password_hint.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirm_password_hint;

  /// No description provided for @login_button.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login_button;

  /// No description provided for @register_button.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register_button;

  /// No description provided for @forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgot_password;

  /// No description provided for @verification_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent'**
  String get verification_email_sent;

  /// No description provided for @password_reset_title.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get password_reset_title;

  /// No description provided for @password_reset_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get password_reset_email_sent;

  /// No description provided for @google_login.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get google_login;

  /// No description provided for @apple_login.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get apple_login;

  /// No description provided for @facebook_login.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get facebook_login;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profile_logout;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get profile_theme;

  /// No description provided for @profile_rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get profile_rank;

  /// No description provided for @profile_guest.
  ///
  /// In en, this message translates to:
  /// **'Sign in as guest'**
  String get profile_guest;

  /// No description provided for @createTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Ticket'**
  String get createTicketTitle;

  /// No description provided for @stakeHint.
  ///
  /// In en, this message translates to:
  /// **'Stake'**
  String get stakeHint;

  /// No description provided for @placeBet.
  ///
  /// In en, this message translates to:
  /// **'Place Bet'**
  String get placeBet;

  /// No description provided for @errorInvalidStake.
  ///
  /// In en, this message translates to:
  /// **'Invalid stake'**
  String get errorInvalidStake;

  /// No description provided for @errorDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate tips are not allowed'**
  String get errorDuplicate;

  /// No description provided for @errorMatchConflict.
  ///
  /// In en, this message translates to:
  /// **'Conflicting tips on the same match'**
  String get errorMatchConflict;

  /// No description provided for @my_tickets_title.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get my_tickets_title;

  /// No description provided for @ticket_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get ticket_status_pending;

  /// No description provided for @ticket_status_won.
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get ticket_status_won;

  /// No description provided for @ticket_status_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get ticket_status_lost;

  /// No description provided for @ticket_status_void.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get ticket_status_void;

  /// No description provided for @empty_ticket_message.
  ///
  /// In en, this message translates to:
  /// **'You have no tickets yet'**
  String get empty_ticket_message;

  /// No description provided for @ticket_details_title.
  ///
  /// In en, this message translates to:
  /// **'Ticket Details'**
  String get ticket_details_title;

  /// No description provided for @api_error_limit.
  ///
  /// In en, this message translates to:
  /// **'Odds API rate limit exceeded'**
  String get api_error_limit;

  /// No description provided for @api_error_key.
  ///
  /// In en, this message translates to:
  /// **'Invalid Odds API key'**
  String get api_error_key;

  /// No description provided for @api_error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error while contacting Odds API'**
  String get api_error_network;

  /// No description provided for @api_error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown error from Odds API'**
  String get api_error_unknown;

  /// No description provided for @events_title.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events_title;

  /// No description provided for @bets_title.
  ///
  /// In en, this message translates to:
  /// **'Bets'**
  String get bets_title;

  /// No description provided for @events_empty.
  ///
  /// In en, this message translates to:
  /// **'No events available'**
  String get events_empty;

  /// No description provided for @events_screen_no_events.
  ///
  /// In en, this message translates to:
  /// **'No events found'**
  String get events_screen_no_events;

  /// No description provided for @events_screen_quota_warning.
  ///
  /// In en, this message translates to:
  /// **'API quota is nearly exceeded'**
  String get events_screen_quota_warning;

  /// No description provided for @events_screen_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get events_screen_refresh;

  /// No description provided for @events_screen_no_odds.
  ///
  /// In en, this message translates to:
  /// **'No odds available'**
  String get events_screen_no_odds;

  /// No description provided for @events_screen_no_market.
  ///
  /// In en, this message translates to:
  /// **'No market data'**
  String get events_screen_no_market;

  /// No description provided for @events_screen_start_time.
  ///
  /// In en, this message translates to:
  /// **'Start time: {time}'**
  String events_screen_start_time(Object time);

  /// No description provided for @events_screen_tip_added.
  ///
  /// In en, this message translates to:
  /// **'Tip added'**
  String get events_screen_tip_added;

  /// No description provided for @events_screen_tip_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Tip already added'**
  String get events_screen_tip_duplicate;

  /// No description provided for @add_tip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_tip;

  /// No description provided for @no_tips_selected.
  ///
  /// In en, this message translates to:
  /// **'No tips selected'**
  String get no_tips_selected;

  /// No description provided for @ticket_submit_success.
  ///
  /// In en, this message translates to:
  /// **'Ticket submitted successfully'**
  String get ticket_submit_success;

  /// No description provided for @ticket_submit_error.
  ///
  /// In en, this message translates to:
  /// **'Error occurred:'**
  String get ticket_submit_error;

  /// No description provided for @odds_label.
  ///
  /// In en, this message translates to:
  /// **'Odds'**
  String get odds_label;

  /// No description provided for @total_odds_label.
  ///
  /// In en, this message translates to:
  /// **'Total odds'**
  String get total_odds_label;

  /// No description provided for @potential_win_label.
  ///
  /// In en, this message translates to:
  /// **'Potential win'**
  String get potential_win_label;

  /// No description provided for @ticket_id.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticket_id;

  /// No description provided for @tips_label.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips_label;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @not_logged_in.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get not_logged_in;

  /// No description provided for @errorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'You are not logged in.'**
  String get errorNotLoggedIn;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// No description provided for @profile_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profile_name;

  /// No description provided for @profile_nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get profile_nickname;

  /// No description provided for @profile_is_private.
  ///
  /// In en, this message translates to:
  /// **'Private profile'**
  String get profile_is_private;

  /// No description provided for @profile_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get profile_city;

  /// No description provided for @profile_country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profile_country;

  /// No description provided for @profile_friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profile_friends;

  /// No description provided for @profile_favorite_sports.
  ///
  /// In en, this message translates to:
  /// **'Favorite sports'**
  String get profile_favorite_sports;

  /// No description provided for @profile_favorite_teams.
  ///
  /// In en, this message translates to:
  /// **'Favorite teams'**
  String get profile_favorite_teams;

  /// No description provided for @profile_public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get profile_public;

  /// No description provided for @profile_private.
  ///
  /// In en, this message translates to:
  /// **'Private'**
  String get profile_private;

  /// No description provided for @profile_toggle_visibility.
  ///
  /// In en, this message translates to:
  /// **'Toggle visibility'**
  String get profile_toggle_visibility;

  /// No description provided for @profile_global_privacy.
  ///
  /// In en, this message translates to:
  /// **'Global privacy switch'**
  String get profile_global_privacy;

  /// No description provided for @drawer_title.
  ///
  /// In en, this message translates to:
  /// **'Drawer'**
  String get drawer_title;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found. Please log in again.'**
  String get errorUserNotFound;

  /// No description provided for @go_to_create_ticket.
  ///
  /// In en, this message translates to:
  /// **'Submit Ticket'**
  String get go_to_create_ticket;

  /// No description provided for @insufficient_permissions.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission.'**
  String get insufficient_permissions;

  /// No description provided for @invalid_transaction_type.
  ///
  /// In en, this message translates to:
  /// **'Invalid transaction type.'**
  String get invalid_transaction_type;

  /// No description provided for @missing_transaction_id.
  ///
  /// In en, this message translates to:
  /// **'Transaction ID is required.'**
  String get missing_transaction_id;

  /// No description provided for @amount_must_be_integer.
  ///
  /// In en, this message translates to:
  /// **'Amount must be an integer.'**
  String get amount_must_be_integer;

  /// No description provided for @admin_only_field.
  ///
  /// In en, this message translates to:
  /// **'Only admin may modify this field.'**
  String get admin_only_field;

  /// No description provided for @leaderboard_title.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard_title;

  /// No description provided for @leaderboard_you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get leaderboard_you;

  /// No description provided for @leaderboard_empty.
  ///
  /// In en, this message translates to:
  /// **'No users yet'**
  String get leaderboard_empty;

  /// No description provided for @leaderboard_mode_coin.
  ///
  /// In en, this message translates to:
  /// **'TippCoin'**
  String get leaderboard_mode_coin;

  /// No description provided for @leaderboard_mode_winrate.
  ///
  /// In en, this message translates to:
  /// **'Win rate'**
  String get leaderboard_mode_winrate;

  /// No description provided for @leaderboard_mode_streak.
  ///
  /// In en, this message translates to:
  /// **'Win streak'**
  String get leaderboard_mode_streak;

  /// No description provided for @feed_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed_screen_title;

  /// No description provided for @menuLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get menuLeaderboard;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @drawer_feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get drawer_feed;

  /// No description provided for @bottom_nav_feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get bottom_nav_feed;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// No description provided for @settings_theme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_theme_system;

  /// No description provided for @settings_theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_theme_light;

  /// No description provided for @settings_theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_theme_dark;

  /// No description provided for @settings_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get settings_dark_mode;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settings_logout;

  /// No description provided for @settings_ai_recommendations.
  ///
  /// In en, this message translates to:
  /// **'AI recommendations'**
  String get settings_ai_recommendations;

  /// No description provided for @settings_push_notifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get settings_push_notifications;

  /// No description provided for @badge_rookie_title.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get badge_rookie_title;

  /// No description provided for @badge_rookie_description.
  ///
  /// In en, this message translates to:
  /// **'First win completed.'**
  String get badge_rookie_description;

  /// No description provided for @badge_hot_streak_title.
  ///
  /// In en, this message translates to:
  /// **'Hot Streak'**
  String get badge_hot_streak_title;

  /// No description provided for @badge_hot_streak_description.
  ///
  /// In en, this message translates to:
  /// **'Three wins in a row.'**
  String get badge_hot_streak_description;

  /// No description provided for @badge_parlay_pro_title.
  ///
  /// In en, this message translates to:
  /// **'Parlay Pro'**
  String get badge_parlay_pro_title;

  /// No description provided for @badge_parlay_pro_description.
  ///
  /// In en, this message translates to:
  /// **'Winning a 5+ event parlay.'**
  String get badge_parlay_pro_description;

  /// No description provided for @badge_night_owl_title.
  ///
  /// In en, this message translates to:
  /// **'Night Owl'**
  String get badge_night_owl_title;

  /// No description provided for @badge_night_owl_description.
  ///
  /// In en, this message translates to:
  /// **'Ticket won after midnight.'**
  String get badge_night_owl_description;

  /// No description provided for @badge_comeback_kid_title.
  ///
  /// In en, this message translates to:
  /// **'Comeback Kid'**
  String get badge_comeback_kid_title;

  /// No description provided for @badge_comeback_kid_description.
  ///
  /// In en, this message translates to:
  /// **'Win after three losses.'**
  String get badge_comeback_kid_description;

  /// No description provided for @profile_badges_empty.
  ///
  /// In en, this message translates to:
  /// **'No badges yet'**
  String get profile_badges_empty;

  /// No description provided for @bonus_daily_received.
  ///
  /// In en, this message translates to:
  /// **'Daily bonus: +50 TippCoin!'**
  String get bonus_daily_received;

  /// No description provided for @bonus_daily_received_description.
  ///
  /// In en, this message translates to:
  /// **'Thanks for being active!'**
  String get bonus_daily_received_description;

  /// No description provided for @feed_event_bet_placed.
  ///
  /// In en, this message translates to:
  /// **'Bet placed'**
  String get feed_event_bet_placed;

  /// No description provided for @feed_event_ticket_won.
  ///
  /// In en, this message translates to:
  /// **'Ticket won'**
  String get feed_event_ticket_won;

  /// No description provided for @feed_event_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get feed_event_comment;

  /// No description provided for @feed_event_like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get feed_event_like;

  /// No description provided for @feed_report_success.
  ///
  /// In en, this message translates to:
  /// **'The post has been reported.'**
  String get feed_report_success;

  /// No description provided for @feed_empty_state.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get feed_empty_state;

  /// No description provided for @feed_like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get feed_like;

  /// No description provided for @feed_comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get feed_comment;

  /// No description provided for @feed_report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get feed_report;

  /// No description provided for @copy_success.
  ///
  /// In en, this message translates to:
  /// **'Ticket copied!'**
  String get copy_success;

  /// No description provided for @copy_edit_title.
  ///
  /// In en, this message translates to:
  /// **'Edit copied ticket'**
  String get copy_edit_title;

  /// No description provided for @copy_submit_button.
  ///
  /// In en, this message translates to:
  /// **'Submit ticket'**
  String get copy_submit_button;

  /// No description provided for @copy_invalid_state.
  ///
  /// In en, this message translates to:
  /// **'Ticket unmodified, cannot submit.'**
  String get copy_invalid_state;

  /// No description provided for @auth_error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get auth_error_user_not_found;

  /// No description provided for @auth_error_wrong_password.
  ///
  /// In en, this message translates to:
  /// **'Wrong password'**
  String get auth_error_wrong_password;

  /// No description provided for @auth_error_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get auth_error_email_already_in_use;

  /// No description provided for @auth_error_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get auth_error_invalid_email;

  /// No description provided for @auth_error_weak_password.
  ///
  /// In en, this message translates to:
  /// **'Weak password'**
  String get auth_error_weak_password;

  /// No description provided for @auth_error_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown authentication error'**
  String get auth_error_unknown;

  /// No description provided for @menuBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get menuBadges;

  /// No description provided for @badgeScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Available Badges'**
  String get badgeScreenTitle;

  /// No description provided for @badgeFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get badgeFilterAll;

  /// No description provided for @badgeFilterOwned.
  ///
  /// In en, this message translates to:
  /// **'Owned'**
  String get badgeFilterOwned;

  /// No description provided for @badgeFilterMissing.
  ///
  /// In en, this message translates to:
  /// **'Missing'**
  String get badgeFilterMissing;

  /// No description provided for @menuRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get menuRewards;

  /// No description provided for @rewardTitle.
  ///
  /// In en, this message translates to:
  /// **'Available rewards'**
  String get rewardTitle;

  /// No description provided for @rewardClaim.
  ///
  /// In en, this message translates to:
  /// **'Claim'**
  String get rewardClaim;

  /// No description provided for @rewardClaimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get rewardClaimed;

  /// No description provided for @rewardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No rewards available'**
  String get rewardEmpty;

  /// No description provided for @menuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// No description provided for @notificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get notificationTitle;

  /// No description provided for @notificationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get notificationEmpty;

  /// No description provided for @notificationMarkRead.
  ///
  /// In en, this message translates to:
  /// **'Mark read'**
  String get notificationMarkRead;

  /// No description provided for @notificationFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationFilterAll;

  /// No description provided for @notificationFilterUnread.
  ///
  /// In en, this message translates to:
  /// **'Unread'**
  String get notificationFilterUnread;

  /// No description provided for @notificationType_reward.
  ///
  /// In en, this message translates to:
  /// **'Reward'**
  String get notificationType_reward;

  /// No description provided for @notificationType_badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get notificationType_badge;

  /// No description provided for @notificationType_friend.
  ///
  /// In en, this message translates to:
  /// **'Friend request'**
  String get notificationType_friend;

  /// No description provided for @notificationType_message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get notificationType_message;

  /// No description provided for @notificationType_challenge.
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get notificationType_challenge;

  /// No description provided for @dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// No description provided for @dialog_send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get dialog_send;

  /// No description provided for @dialog_reason_hint.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get dialog_reason_hint;

  /// No description provided for @dialog_comment_title.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get dialog_comment_title;

  /// No description provided for @dialog_add_comment_hint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment'**
  String get dialog_add_comment_hint;

  /// No description provided for @profile_stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get profile_stats;

  /// No description provided for @profile_badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get profile_badges;

  /// No description provided for @profile_level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get profile_level;

  /// No description provided for @profile_coins.
  ///
  /// In en, this message translates to:
  /// **'TippCoin'**
  String get profile_coins;

  /// No description provided for @profileAvatarGallery.
  ///
  /// In en, this message translates to:
  /// **'Avatar gallery'**
  String get profileAvatarGallery;

  /// No description provided for @profileUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload your own photo'**
  String get profileUploadPhoto;

  /// No description provided for @profileResetAvatar.
  ///
  /// In en, this message translates to:
  /// **'Reset to default avatar'**
  String get profileResetAvatar;

  /// No description provided for @profileChooseAvatar.
  ///
  /// In en, this message translates to:
  /// **'Choose avatar'**
  String get profileChooseAvatar;

  /// No description provided for @profileCropImage.
  ///
  /// In en, this message translates to:
  /// **'Crop image'**
  String get profileCropImage;

  /// No description provided for @profile_avatar_error.
  ///
  /// In en, this message translates to:
  /// **'Error updating avatar'**
  String get profile_avatar_error;

  /// No description provided for @profile_avatar_updated.
  ///
  /// In en, this message translates to:
  /// **'Avatar updated'**
  String get profile_avatar_updated;

  /// No description provided for @profile_avatar_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Avatar upload cancelled'**
  String get profile_avatar_cancelled;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'hu': return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
