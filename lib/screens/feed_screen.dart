import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../widgets/home_feed.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.feed_title)),
      body: const HomeFeedWidget(),
    );
  }
}
