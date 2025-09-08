import 'package:flutter_test/flutter_test.dart';
import 'package:tipsterino/features/forum/data/thread_query_builder.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';
import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';

void main() {
  test('buildThreadQueryParams returns correct fields', () {
    final paramsAllLatest =
        buildThreadQueryParams(ForumFilter.all, ForumSort.latest);
    expect(paramsAllLatest.whereField, isNull);
    expect(paramsAllLatest.orderByField, 'lastActivityAt');

    final paramsPinnedNewest =
        buildThreadQueryParams(ForumFilter.pinned, ForumSort.newest);
    expect(paramsPinnedNewest.whereField, 'pinned');
    expect(paramsPinnedNewest.whereValue, true);
    expect(paramsPinnedNewest.orderByField, 'createdAt');

    final paramsMatchesLatest =
        buildThreadQueryParams(ForumFilter.matches, ForumSort.latest);
    expect(paramsMatchesLatest.whereField, 'type');
    expect(paramsMatchesLatest.whereValue, ThreadType.match.toJson());
    expect(paramsMatchesLatest.orderByField, 'lastActivityAt');

    final paramsGeneralNewest =
        buildThreadQueryParams(ForumFilter.general, ForumSort.newest);
    expect(paramsGeneralNewest.whereField, 'type');
    expect(paramsGeneralNewest.whereValue, ThreadType.general.toJson());
    expect(paramsGeneralNewest.orderByField, 'createdAt');
  });
}
