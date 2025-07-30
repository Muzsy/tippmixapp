import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/social_service.dart';
import '../models/friend_request.dart';

final socialServiceProvider = Provider<SocialService>((ref) {
  return SocialService();
});

final followersProvider = StreamProvider.family<List<String>, String>((
  ref,
  uid,
) {
  final service = ref.watch(socialServiceProvider);
  return service.followersStream(uid);
});

final friendRequestsProvider =
    StreamProvider.family<List<FriendRequest>, String>((ref, uid) {
      final service = ref.watch(socialServiceProvider);
      return service.friendRequestsStream(uid);
    });
