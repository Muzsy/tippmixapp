import "../constants.dart";

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String nickname;
  final String avatarUrl;
  final bool isPrivate;
  final Map<String, bool> fieldVisibility;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.nickname,
    required this.avatarUrl,
    required this.isPrivate,
    required this.fieldVisibility,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        nickname: json['nickname'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? kDefaultAvatarPath,
        isPrivate: json['isPrivate'] as bool? ?? false,
        fieldVisibility:
            (json['fieldVisibility'] as Map<String, dynamic>? ?? {})
                .map((k, v) => MapEntry(k, v as bool)),
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'isPrivate': isPrivate,
        'fieldVisibility': fieldVisibility,
      };
}
