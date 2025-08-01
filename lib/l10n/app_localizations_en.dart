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
  String get home_tile_daily_bonus_title => 'Daily Bonus';

  @override
  String get home_tile_daily_bonus_collect => 'Collect';

  @override
  String get home_tile_daily_bonus_claimed => 'Collected';

  @override
  String get home_tile_new_badge_title => 'New Badge';

  @override
  String get home_tile_badge_earned_title => 'Badge Earned';

  @override
  String get home_tile_badge_earned_cta => 'View all';

  @override
  String get home_tile_ai_tip_title => 'AI Recommendation';

  @override
  String home_tile_ai_tip_description(Object percent, Object team) {
    return 'According to AI, $team is most likely to win today ($percent%).';
  }

  @override
  String get home_tile_ai_tip_cta => 'View details';

  @override
  String get home_tile_top_tipster_title => 'Player of the Day';

  @override
  String home_tile_top_tipster_description(Object username) {
    return '$username hit all tips in your club today.';
  }

  @override
  String get home_tile_top_tipster_cta => 'View tips';

  @override
  String get home_tile_challenge_title => 'Challenge awaits!';

  @override
  String get home_tile_challenge_daily_description =>
      'Daily challenge: win 3 bets today.';

  @override
  String home_tile_challenge_friend_description(Object username) {
    return '$username challenged you to a betting duel!';
  }

  @override
  String get home_tile_challenge_cta_accept => 'Accept';

  @override
  String get home_tile_educational_tip_title => 'Betting tip';

  @override
  String get home_tile_educational_tip_1 =>
      'Did you know? Combining bets can increase your odds.';

  @override
  String get home_tile_educational_tip_2 =>
      'Single bets carry less risk than accumulators.';

  @override
  String get home_tile_educational_tip_3 =>
      'Track your betting history to learn from past results.';

  @override
  String get home_tile_educational_tip_cta => 'More tips';

  @override
  String get home_tile_feed_activity_title => 'Latest activity';

  @override
  String home_tile_feed_activity_text_template(Object username) {
    return '$username shared a winning tip!';
  }

  @override
  String get home_tile_feed_activity_cta => 'View';

  @override
  String get login_welcome => 'Welcome to Tippmix!';

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
  String get register_link => 'Create account';

  @override
  String get forgot_password => 'Forgot password?';

  @override
  String get verification_email_sent => 'Verification email sent';

  @override
  String get password_reset_title => 'Reset Password';

  @override
  String get password_reset_email_sent => 'Password reset email sent';

  @override
  String get google_login => 'Continue with Google';

  @override
  String get apple_login => 'Continue with Apple';

  @override
  String get facebook_login => 'Continue with Facebook';

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
  String get bets_title => 'Bets';

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
  String get not_logged_in => 'Not logged in';

  @override
  String get errorNotLoggedIn => 'You are not logged in.';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_name => 'Name';

  @override
  String get profile_nickname => 'Nickname';

  @override
  String get profile_is_private => 'Private profile';

  @override
  String get profile_city => 'City';

  @override
  String get profile_country => 'Country';

  @override
  String get profile_friends => 'Friends';

  @override
  String get profile_favorite_sports => 'Favorite sports';

  @override
  String get profile_favorite_teams => 'Favorite teams';

  @override
  String get profile_public => 'Public';

  @override
  String get profile_private => 'Private';

  @override
  String get profile_toggle_visibility => 'Toggle visibility';

  @override
  String get profile_global_privacy => 'Global privacy switch';

  @override
  String get drawer_title => 'Drawer';

  @override
  String get errorUserNotFound => 'User not found. Please log in again.';

  @override
  String get go_to_create_ticket => 'Submit Ticket';

  @override
  String get insufficient_permissions => 'You do not have permission.';

  @override
  String get invalid_transaction_type => 'Invalid transaction type.';

  @override
  String get missing_transaction_id => 'Transaction ID is required.';

  @override
  String get amount_must_be_integer => 'Amount must be an integer.';

  @override
  String get admin_only_field => 'Only admin may modify this field.';

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
  String get feed_screen_title => 'Feed';

  @override
  String get menuLeaderboard => 'Leaderboard';

  @override
  String get menuProfile => 'Profile';

  @override
  String get myTickets => 'My Tickets';

  @override
  String get menuSettings => 'Settings';

  @override
  String get drawer_feed => 'Feed';

  @override
  String get bottom_nav_feed => 'Feed';

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
  String get settings_dark_mode => 'Dark mode';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_logout => 'Logout';

  @override
  String get settings_ai_recommendations => 'AI recommendations';

  @override
  String get settings_push_notifications => 'Push notifications';

  @override
  String get settings_skin => 'Skin';

  @override
  String get skin_dell_genoa_name => 'Tippmix Green';

  @override
  String get skin_dell_genoa_description => 'Default Tippmix green theme';

  @override
  String get skin_pink_m3_name => 'Pink Party';

  @override
  String get skin_pink_m3_description => 'Fun and vibrant pink skin';

  @override
  String get badge_rookie_title => 'Rookie';

  @override
  String get badge_rookie_description => 'First win completed.';

  @override
  String get badge_hot_streak_title => 'Hot Streak';

  @override
  String get badge_hot_streak_description => 'Three wins in a row.';

  @override
  String get badge_parlay_pro_title => 'Parlay Pro';

  @override
  String get badge_parlay_pro_description => 'Winning a 5+ event parlay.';

  @override
  String get badge_night_owl_title => 'Night Owl';

  @override
  String get badge_night_owl_description => 'Ticket won after midnight.';

  @override
  String get badge_comeback_kid_title => 'Comeback Kid';

  @override
  String get badge_comeback_kid_description => 'Win after three losses.';

  @override
  String get profile_badges_empty => 'No badges yet';

  @override
  String get bonus_daily_received => 'Daily bonus: +50 TippCoin!';

  @override
  String get bonus_daily_received_description => 'Thanks for being active!';

  @override
  String get feed_event_bet_placed => 'Bet placed';

  @override
  String get feed_event_ticket_won => 'Ticket won';

  @override
  String get feed_event_comment => 'Comment';

  @override
  String get feed_event_like => 'Like';

  @override
  String get feed_report_success => 'The post has been reported.';

  @override
  String get feed_empty_state => 'No posts yet';

  @override
  String get feed_like => 'Like';

  @override
  String get feed_comment => 'Comment';

  @override
  String get feed_report => 'Report';

  @override
  String get copy_success => 'Ticket copied!';

  @override
  String get copy_edit_title => 'Edit copied ticket';

  @override
  String get copy_submit_button => 'Submit ticket';

  @override
  String get copy_invalid_state => 'Ticket unmodified, cannot submit.';

  @override
  String get auth_error_user_not_found => 'User not found';

  @override
  String get auth_error_wrong_password => 'Wrong password';

  @override
  String get auth_error_email_already_in_use => 'Email already in use';

  @override
  String get auth_error_invalid_email => 'Invalid email address';

  @override
  String get auth_error_weak_password => 'Weak password';

  @override
  String get auth_error_unknown => 'Unknown authentication error';

  @override
  String get menuBadges => 'Badges';

  @override
  String get badgeScreenTitle => 'Available Badges';

  @override
  String get badgeFilterAll => 'All';

  @override
  String get badgeFilterOwned => 'Owned';

  @override
  String get badgeFilterMissing => 'Missing';

  @override
  String get menuRewards => 'Rewards';

  @override
  String get rewardTitle => 'Available rewards';

  @override
  String get rewardClaim => 'Claim';

  @override
  String get rewardClaimed => 'Claimed';

  @override
  String get rewardEmpty => 'No rewards available';

  @override
  String reward_balance(Object coins) {
    return 'Coins: $coins';
  }

  @override
  String reward_streak(Object days) {
    return 'Streak: $days/7';
  }

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get notificationTitle => 'Events';

  @override
  String get notificationEmpty => 'No new notifications';

  @override
  String get notificationMarkRead => 'Mark read';

  @override
  String get notificationFilterAll => 'All';

  @override
  String get notificationFilterUnread => 'Unread';

  @override
  String get notificationArchive => 'Archive';

  @override
  String get notificationUndo => 'Undo';

  @override
  String get notificationType_reward => 'Reward';

  @override
  String get notificationType_badge => 'Badge';

  @override
  String get notificationType_friend => 'Friend request';

  @override
  String get notificationType_message => 'Message';

  @override
  String get notificationType_challenge => 'Challenge';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get dialog_send => 'Send';

  @override
  String get dialog_reason_hint => 'Reason';

  @override
  String get dialog_comment_title => 'Comment';

  @override
  String get dialog_add_comment_hint => 'Add a comment';

  @override
  String get profile_stats => 'Stats';

  @override
  String get profile_badges => 'Badges';

  @override
  String get profile_level => 'Level';

  @override
  String get profile_coins => 'TippCoin';

  @override
  String get profileAvatarGallery => 'Avatar gallery';

  @override
  String get profileUploadPhoto => 'Upload your own photo';

  @override
  String get profileResetAvatar => 'Reset to default avatar';

  @override
  String get profileChooseAvatar => 'Choose avatar';

  @override
  String get profile_avatar_error => 'Error updating avatar';

  @override
  String get profile_avatar_updated => 'Avatar updated';

  @override
  String get profile_avatar_cancelled => 'Avatar upload cancelled';

  @override
  String get notif_tips => 'Tips';

  @override
  String get notif_friend_activity => 'Friend activity';

  @override
  String get notif_badge => 'Badges';

  @override
  String get notif_rewards => 'Rewards';

  @override
  String get notif_system => 'System';

  @override
  String get edit_title => 'Edit Profile';

  @override
  String get name_hint => 'Display name';

  @override
  String get name_error_short => 'Name too short';

  @override
  String get name_error_long => 'Name too long';

  @override
  String get bio_hint => 'Bio';

  @override
  String get team_hint => 'Favourite team';

  @override
  String get dob_hint => 'Date of birth';

  @override
  String get dob_error_underage => 'You must be 18+';

  @override
  String get dob_error_future => 'Date cannot be in the future';

  @override
  String get profile_updated => 'Profile updated';

  @override
  String get security_title => 'Security';

  @override
  String get enable_two_factor => 'Enable two-factor authentication';

  @override
  String get disable_two_factor => 'Disable two-factor authentication';

  @override
  String get otp_prompt_title => 'Enter OTP';

  @override
  String get otp_enter_code => 'Code';

  @override
  String get otp_error_invalid => 'Invalid code';

  @override
  String get backup_codes_title => 'Backup codes';

  @override
  String get verified_badge_label => 'Verified';

  @override
  String get follow => 'Follow';

  @override
  String get unfollow => 'Unfollow';

  @override
  String get addFriend => 'Add Friend';

  @override
  String get requestSent => 'Request sent';

  @override
  String get friends => 'Friends';

  @override
  String get followers => 'Followers';

  @override
  String get pending => 'Pending';

  @override
  String get accept => 'Accept';

  @override
  String get login_variant_b_promo_title => 'Trusted by 50 000+';

  @override
  String get login_variant_b_promo_subtitle => 'Join our community and win!';

  @override
  String get onboarding_place_bet => 'Place bets easily';

  @override
  String get onboarding_track_rewards => 'Track your rewards';

  @override
  String get onboarding_follow_tipsters => 'Follow top tipsters';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_done => 'Done';

  @override
  String get continue_button => 'Continue';

  @override
  String get password_strength_weak => 'Weak';

  @override
  String get password_strength_medium => 'Medium';

  @override
  String get password_strength_strong => 'Strong';

  @override
  String get errorInvalidEmail => 'Invalid email address';

  @override
  String get errorWeakPassword => 'Weak password';

  @override
  String get errorEmailExists => 'This e-mail is already registered';

  @override
  String get loaderCheckingEmail => 'Checking e-mail...';

  @override
  String get passwordStrengthVeryWeak => 'Very weak';

  @override
  String get passwordStrengthStrong => 'Strong';

  @override
  String get btnContinue => 'Continue';

  @override
  String get gdpr_consent => 'I agree to the privacy policy';

  @override
  String get gdpr_required_error => 'GDPR consent required';

  @override
  String get auth_error_invalid_nickname => 'Nickname must be 3-20 characters';

  @override
  String get auth_error_invalid_date => 'Invalid date';

  @override
  String get auth_error_nickname_taken => 'Nickname already taken';

  @override
  String get register_take_photo => 'Take photo';

  @override
  String get register_choose_file => 'Choose file';

  @override
  String get register_finish => 'Finish';

  @override
  String get register_skip => 'Skip';

  @override
  String get register_avatar_too_large => 'Avatar image must be 2 MB or less';

  @override
  String get back_button => 'Back';

  @override
  String get login_required_title => 'Login required';

  @override
  String get login_required_message => 'Please log in to continue';

  @override
  String get emailVerify_title => 'Verify your email!';

  @override
  String get emailVerify_description =>
      'Click the link in the verification email then return to the app.';

  @override
  String get emailVerify_resend => 'Resend';

  @override
  String get emailVerify_sent => 'Verification email sent';

  @override
  String get emailVerify_exit => 'Exit';

  @override
  String get password_pwned_error =>
      'This password has appeared in a data breach';

  @override
  String get recaptcha_failed_error => 'reCAPTCHA verification failed';

  @override
  String get unknown_network_error => 'Network error occurred';

  @override
  String get unknown_error_try_again => 'Unknown error, please try again';
}
