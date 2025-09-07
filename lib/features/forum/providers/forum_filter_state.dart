/// Available thread filters.
enum ForumFilter { all, matches, general, pinned }

/// Sort options for thread listing.
enum ForumSort { latest, newest }

/// Holds current filter and sort settings for the forum.
class ForumFilterState {
  const ForumFilterState({
    this.filter = ForumFilter.all,
    this.sort = ForumSort.latest,
  });

  final ForumFilter filter;
  final ForumSort sort;

  ForumFilterState copyWith({ForumFilter? filter, ForumSort? sort}) {
    return ForumFilterState(
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ForumFilterState &&
        other.filter == filter &&
        other.sort == sort;
  }

  @override
  int get hashCode => Object.hash(filter, sort);
}
