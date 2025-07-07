import "../constants.dart";

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String nickname;
  final String avatarUrl;
  final bool isPrivate;
  final Map<String, bool> fieldVisibility;
  final Map<String, bool> notificationPreferences;
  final String? bio;
  final String? favouriteTeam;
  final DateTime? dateOfBirth;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.nickname,
    required this.avatarUrl,
    required this.isPrivate,
    required this.fieldVisibility,
    this.notificationPreferences = const {},
    this.bio,
    this.favouriteTeam,
    this.dateOfBirth,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String? ?? '',
        displayName: json['displayName'] as String? ?? '',
        nickname: json['nickname'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String? ?? kDefaultAvatarPath,
        isPrivate: json['isPrivate'] as bool? ?? false,
        fieldVisibility: Map<String, bool>.from(
          (json['fieldVisibility'] as Map?) ?? {},
        ),
        notificationPreferences: Map<String, bool>.from(
          (json['notificationPreferences'] as Map?) ?? {},
        ),
        bio: json['bio'] as String?,
        favouriteTeam: json['favouriteTeam'] as String?,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.tryParse(json['dateOfBirth'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'nickname': nickname,
        'avatarUrl': avatarUrl,
        'isPrivate': isPrivate,
        'fieldVisibility': fieldVisibility,
        'notificationPreferences': notificationPreferences,
        if (bio != null) 'bio': bio,
        if (favouriteTeam != null) 'favouriteTeam': favouriteTeam,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      };
}
