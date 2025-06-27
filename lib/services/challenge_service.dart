import 'package:cloud_firestore/cloud_firestore.dart';

/// Type of challenge the user can receive.
enum ChallengeType { daily, weekly, friend }

/// Simple data model representing a challenge document.
class ChallengeModel {
  final String id;
  final ChallengeType type;
  final String? username;
  final DateTime endTime;

  ChallengeModel({
    required this.id,
    required this.type,
    required this.endTime,
    this.username,
  });

  factory ChallengeModel.fromJson(String id, Map<String, dynamic> json) =>
      ChallengeModel(
        id: id,
        type: ChallengeType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => ChallengeType.daily,
        ),
        username: json['username'] as String?,
        endTime: (json['endTime'] as Timestamp?)?.toDate() ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (username != null) 'username': username,
        'endTime': Timestamp.fromDate(endTime),
      };

  bool get isActive => endTime.isAfter(DateTime.now());
}

/// Service responsible for fetching active challenges for a user.
class ChallengeService {
  final FirebaseFirestore _firestore;
  ChallengeService([FirebaseFirestore? firestore])
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _ref(String userId) {
    return _firestore.collection('users/$userId/challenges');
  }

  /// Fetch active challenges of the given user.
  Future<List<ChallengeModel>> fetchActiveChallenges(String userId) async {
    final query = await _ref(userId)
        .where('endTime', isGreaterThan: Timestamp.now())
        .get();
    return query.docs
        .map((d) => ChallengeModel.fromJson(d.id, d.data()))
        .toList();
  }
}
