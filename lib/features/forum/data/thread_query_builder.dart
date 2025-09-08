import 'package:tipsterino/features/forum/providers/forum_filter_state.dart';
import 'package:tipsterino/features/forum/domain/thread.dart';

/// Parameters used to build a Firestore thread query.
class ThreadQueryParams {
  const ThreadQueryParams({
    this.whereField,
    this.whereValue,
    required this.orderByField,
    this.descending = true,
  });

  final String? whereField;
  final Object? whereValue;
  final String orderByField;
  final bool descending;
}

/// Builds query parameters for the given [filter] and [sort].
ThreadQueryParams buildThreadQueryParams(ForumFilter filter, ForumSort sort) {
  String? whereField;
  Object? whereValue;
  switch (filter) {
    case ForumFilter.matches:
      whereField = 'type';
      whereValue = ThreadType.match.toJson();
      break;
    case ForumFilter.general:
      whereField = 'type';
      whereValue = ThreadType.general.toJson();
      break;
    case ForumFilter.pinned:
      whereField = 'pinned';
      whereValue = true;
      break;
    case ForumFilter.all:
      break;
  }

  String orderByField;
  switch (sort) {
    case ForumSort.latest:
      orderByField = 'lastActivityAt';
      break;
    case ForumSort.newest:
      orderByField = 'createdAt';
      break;
  }

  return ThreadQueryParams(
    whereField: whereField,
    whereValue: whereValue,
    orderByField: orderByField,
  );
}
