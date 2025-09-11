import 'package:flutter_riverpod/flutter_riverpod.dart';
// Firebase social service removed
import '../services/social_service_supabase.dart';
import '../models/friend_request.dart';

final socialServiceProvider = Provider<dynamic>((ref) => SocialServiceSupabase());

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
