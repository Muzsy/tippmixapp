/// Per-user fórum beállítások (mute, default filters)
class UserForumPrefs {
  final List<String> mutedLeagues; // ligaId-k
  final List<String> mutedThreads; // threadId-k
  final String defaultTab; // 'tips' | 'comments' | 'poll'

  const UserForumPrefs({
    this.mutedLeagues = const [],
    this.mutedThreads = const [],
    this.defaultTab = 'tips',
  });

  Map<String, dynamic> toMap() => {
    'mutedLeagues': mutedLeagues,
    'mutedThreads': mutedThreads,
    'defaultTab': defaultTab,
  };

  static UserForumPrefs fromMap(Map<String, dynamic>? m) {
    final d = m ?? <String, dynamic>{};
    return UserForumPrefs(
      mutedLeagues: (d['mutedLeagues'] as List?)?.cast<String>() ?? const [],
      mutedThreads: (d['mutedThreads'] as List?)?.cast<String>() ?? const [],
      defaultTab: (d['defaultTab'] ?? 'tips').toString(),
    );
  }
}
