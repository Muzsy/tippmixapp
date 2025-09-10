import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/friend_request.dart';

class SocialServiceSupabase {
  SocialServiceSupabase({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  String get _uid => _client.auth.currentUser?.id ?? '';

  Future<void> followUser(String targetUid) async {
    final me = _uid;
    if (me.isEmpty) return;
    await _client.from('followers').insert({
      'user_id': targetUid,
      'follower_id': me,
    });
  }

  Future<void> unfollowUser(String targetUid) async {
    final me = _uid;
    if (me.isEmpty) return;
    await _client
        .from('followers')
        .delete()
        .eq('user_id', targetUid)
        .eq('follower_id', me);
  }

  Stream<List<String>> followersStream(String uid) async* {
    final rows = await _client
        .from('followers')
        .select('follower_id')
        .eq('user_id', uid);
    final list = (rows as List)
        .map((r) => (r['follower_id'] as String))
        .toList();
    yield list;
  }

  Future<void> sendFriendRequest(String targetUid) async {
    final me = _uid;
    if (me.isEmpty) return;
    await _client.from('friend_requests').insert({
      'to_uid': targetUid,
      'from_uid': me,
    });
  }

  Future<void> acceptFriendRequest(String requestId) async {
    await _client
        .from('friend_requests')
        .update({'accepted': true})
        .eq('id', requestId);
  }

  Stream<List<FriendRequest>> friendRequestsStream(String uid) async* {
    final rows = await _client
        .from('friend_requests')
        .select('*')
        .eq('to_uid', uid)
        .order('created_at', ascending: false);
    final list = (rows as List)
        .map((r) => FriendRequest.fromJson(r['id'] as String, (r as Map<String, dynamic>)))
        .toList();
    yield list;
  }
}

