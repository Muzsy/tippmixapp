import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/feed_service.dart';
import '../models/feed_model.dart';

/// Provides a single [FeedService] instance.
final feedServiceProvider = Provider<FeedService>((ref) => FeedService());

/// Streams public feed items ordered by timestamp descending.
final feedStreamProvider = StreamProvider<List<FeedModel>>((ref) {
  final service = ref.watch(feedServiceProvider);
  return service.streamFeed();
});
