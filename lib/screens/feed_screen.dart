import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../widgets/home_feed.dart';

class FeedScreen extends StatelessWidget {
  final bool showAppBar;

  const FeedScreen({super.key, this.showAppBar = true});

  @override
  Widget build(BuildContext context) {
    final content = const HomeFeedWidget();

    if (!showAppBar) return content;
    if (Scaffold.maybeOf(context) != null) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.feed_screen_title),
      ),
      body: content,
    );
  }
}
