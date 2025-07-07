import "../constants.dart";
import 'two_factor_type.dart';

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
  final bool twoFactorEnabled;
  final TwoFactorType? twoFactorType;
  final DateTime? verifiedAt;
  final String? totpSecret;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.nickname,
    required this.avatarUrl,
    required this.isPrivate,
    required this.fieldVisibility,
    this.twoFactorEnabled = false,
    this.twoFactorType,
    this.verifiedAt,
    this.totpSecret,
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
        twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
        twoFactorType: json['twoFactorType'] != null
            ? TwoFactorType.values.firstWhere(
                (e) => e.name == json['twoFactorType'],
                orElse: () => TwoFactorType.sms,
              )
            : null,
        verifiedAt: json['verifiedAt'] != null
            ? DateTime.tryParse(json['verifiedAt'] as String)
            : null,
        totpSecret: json['totpSecret'] as String?,
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
        'twoFactorEnabled': twoFactorEnabled,
        if (twoFactorType != null) 'twoFactorType': twoFactorType!.name,
        if (verifiedAt != null) 'verifiedAt': verifiedAt!.toIso8601String(),
        if (totpSecret != null) 'totpSecret': totpSecret,
        if (bio != null) 'bio': bio,
        if (favouriteTeam != null) 'favouriteTeam': favouriteTeam,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth!.toIso8601String(),
      };
}
