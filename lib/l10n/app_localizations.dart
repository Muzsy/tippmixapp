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

  /// No description provided for @google_login.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get google_login;

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

  /// No description provided for @events_empty.
  ///
  /// In en, this message translates to:
  /// **'No events available'**
  String get events_empty;

  /// No description provided for @add_tip.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add_tip;
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
