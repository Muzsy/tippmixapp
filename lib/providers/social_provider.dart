import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/social_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/social_service_supabase.dart';
import '../models/friend_request.dart';

final socialServiceProvider = Provider<dynamic>((ref) {
  final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
  if (useSupabase) return SocialServiceSupabase();
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
