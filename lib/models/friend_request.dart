class FriendRequest {
  final String id;
  final String fromUid;
  final String toUid;
  final bool accepted;

  FriendRequest({
    required this.id,
    required this.fromUid,
    required this.toUid,
    this.accepted = false,
  });

  factory FriendRequest.fromJson(String id, Map<String, dynamic> json) {
    return FriendRequest(
      id: id,
      fromUid: json['fromUid'] as String? ?? '',
      toUid: json['toUid'] as String? ?? '',
      accepted: json['accepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'fromUid': fromUid,
    'toUid': toUid,
    'accepted': accepted,
  };
}
