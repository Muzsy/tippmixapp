import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tipsterino/features/forum/data/forum_repository.dart';
import 'package:tipsterino/features/forum/domain/post.dart' as dom;
import 'package:tipsterino/features/forum/domain/thread.dart' as dom;
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/domain/report.dart' as domrep;

class SupabaseForumRepository implements ForumRepository {
  SupabaseForumRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Stream<List<dom.Thread>> getThreadsByFixture(
    String fixtureId, {
    int limit = 20,
    DateTime? startAfter,
  }) async* {
    // Simple polling stream for now; can be upgraded with Realtime on table
    // changes if needed.
    final rows = await _client
        .from('forum_threads')
        .select('*')
        .eq('fixture_id', fixtureId)
        .order('created_at', ascending: false)
        .limit(limit);
    final list = (rows as List).cast<Map<String, dynamic>>();
    yield list.map(_mapThread).toList();
  }

  @override
  Stream<List<dom.Thread>> queryThreads({
    required ForumFilter filter,
    required ForumSort sort,
    int limit = 20,
    DateTime? startAfter,
  }) async* {
    var query = _client.from('forum_threads').select('*');
    switch (filter) {
      case ForumFilter.general:
        query = query.eq('type', 'general');
        break;
      case ForumFilter.matches:
        query = query.eq('type', 'match');
        break;
      case ForumFilter.pinned:
        query = query.eq('pinned', true);
        break;
      case ForumFilter.all:
        break;
    }
    final orderCol = sort == ForumSort.latest ? 'last_activity_at' : 'created_at';
    final rows = await query.order(orderCol, ascending: false).limit(limit);
    final list = (rows as List).cast<Map<String, dynamic>>();
    yield list.map(_mapThread).toList();
  }

  @override
  Stream<List<dom.Post>> getPostsByThread(
    String threadId, {
    int limit = 20,
    DateTime? startAfter,
  }) async* {
    final rows = await _client
        .from('forum_posts')
        .select('*')
        .eq('thread_id', threadId)
        .order('created_at', ascending: false)
        .limit(limit);
    final list = (rows as List).cast<Map<String, dynamic>>();
    yield list.map(_mapPost).toList();
  }

  @override
  Stream<dom.Thread> watchThread(String threadId) async* {
    final row = await _client
        .from('forum_threads')
        .select('*')
        .eq('id', threadId)
        .single();
    yield _mapThread((row as Map).cast<String, dynamic>());
  }

  @override
  Future<void> addThread(dom.Thread thread) async {
    await _client.from('forum_threads').insert({
      'id': thread.id,
      'title': thread.title,
      'author': thread.createdBy,
      'created_at': thread.createdAt.toIso8601String(),
      'pinned': thread.pinned,
      'locked': thread.locked,
      'last_activity_at': thread.lastActivityAt.toIso8601String(),
      'type': thread.type.name,
      if (thread.fixtureId != null) 'fixture_id': thread.fixtureId,
    });
  }

  @override
  Future<void> updateThread(String threadId, Map<String, dynamic> data) async {
    final patch = <String, dynamic>{};
    if (data.containsKey('pinned')) patch['pinned'] = data['pinned'];
    if (data.containsKey('locked')) patch['locked'] = data['locked'];
    if (data.containsKey('title')) patch['title'] = data['title'];
    await _client.from('forum_threads').update(patch).eq('id', threadId);
  }

  @override
  Future<void> deleteThread(String threadId) async {
    await _client.from('forum_threads').delete().eq('id', threadId);
  }

  @override
  Future<void> setThreadPinned(String threadId, bool pinned) async {
    await _client.from('forum_threads').update({'pinned': pinned}).eq('id', threadId);
  }

  @override
  Future<void> setThreadLocked(String threadId, bool locked) async {
    await _client.from('forum_threads').update({'locked': locked}).eq('id', threadId);
  }

  @override
  Future<void> addPost(dom.Post post) async {
    await _client.from('forum_posts').insert({
      'id': post.id,
      'thread_id': post.threadId,
      'author': post.userId,
      'body': post.content,
      'created_at': post.createdAt.toIso8601String(),
      'type': post.type.name,
      if (post.quotedPostId != null) 'quoted_post_id': post.quotedPostId,
    });
    // The votes_count aggregation happens server-side via trigger
  }

  @override
  Future<void> updatePost({
    required String threadId,
    required String postId,
    required String content,
  }) async {
    await _client
        .from('forum_posts')
        .update({'body': content, 'edited_at': DateTime.now().toIso8601String()})
        .eq('id', postId)
        .eq('thread_id', threadId);
  }

  @override
  Future<void> deletePost({required String threadId, required String postId}) async {
    await _client.from('forum_posts').delete().eq('id', postId).eq('thread_id', threadId);
  }

  @override
  Future<void> voteOnPost({required String postId, required String userId}) async {
    await _client.from('votes').insert({
      'post_id': postId,
      'user_id': userId,
    });
  }

  @override
  Future<void> unvoteOnPost({required String postId, required String userId}) async {
    await _client.from('votes').delete().eq('post_id', postId).eq('user_id', userId);
  }

  @override
  Future<bool> hasVoted({required String postId, required String userId}) async {
    final rows = await _client
        .from('votes')
        .select('post_id')
        .eq('post_id', postId)
        .eq('user_id', userId)
        .limit(1);
    return (rows as List).isNotEmpty;
  }

  @override
  Future<void> reportPost(domrep.Report report) async {
    // Save to `reports` with owner RLS; schema currently supports post reports.
    await _client.from('reports').insert({
      'post_id': report.entityId,
      'reporter_id': report.reporterId,
      'reason': report.reason,
      'created_at': report.createdAt.toIso8601String(),
    });
  }

  dom.Thread _mapThread(Map<String, dynamic> r) {
    return dom.Thread(
      id: r['id'] as String,
      title: r['title'] as String,
      type: dom.ThreadTypeX.fromJson((r['type'] as String?) ?? 'general'),
      fixtureId: r['fixture_id'] as String?,
      createdBy: r['author'] as String,
      createdAt: DateTime.parse(r['created_at'] as String),
      locked: (r['locked'] as bool?) ?? false,
      pinned: (r['pinned'] as bool?) ?? false,
      lastActivityAt: DateTime.tryParse((r['last_activity_at'] as String?) ?? '') ??
          DateTime.parse(r['created_at'] as String),
      postsCount: (r['posts_count'] as int?) ?? 0,
      votesCount: (r['votes_count'] as int?) ?? 0,
    );
  }

  dom.Post _mapPost(Map<String, dynamic> r) {
    return dom.Post(
      id: r['id'] as String,
      threadId: r['thread_id'] as String,
      userId: r['author'] as String,
      type: dom.PostTypeX.fromJson((r['type'] as String?) ?? 'comment'),
      content: r['body'] as String,
      quotedPostId: r['quoted_post_id'] as String?,
      createdAt: DateTime.parse(r['created_at'] as String),
      editedAt: (r['edited_at'] as String?) != null ? DateTime.parse(r['edited_at'] as String) : null,
      votesCount: (r['votes_count'] as int?) ?? 0,
      isHidden: (r['is_hidden'] as bool?) ?? false,
    );
  }
}
