// Firebase removed – minimal Supabase/no-op implementation
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

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
        endTime: () {
          final v = json['endTime'];
          if (v is String) {
            return DateTime.tryParse(v) ?? DateTime.fromMillisecondsSinceEpoch(0);
          }
          if (v is DateTime) return v;
          return DateTime.fromMillisecondsSinceEpoch(0);
        }(),
      );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    if (username != null) 'username': username,
    'endTime': endTime.toIso8601String(),
  };

  bool get isActive => endTime.isAfter(DateTime.now());
}

/// Service responsible for fetching active challenges for a user.
class ChallengeService {
  ChallengeService();

  /// Fetch active challenges of the given user.
  Future<List<ChallengeModel>> fetchActiveChallenges(String userId) async {
    try {
      final rows = await sb.Supabase.instance.client
          .from('challenges')
          .select('*')
          .eq('user_id', userId);
      final list = List<Map<String, dynamic>>.from(rows as List);
      return list
          .map((d) => ChallengeModel.fromJson(d['id'] as String, d))
          .where((c) => c.isActive)
          .toList();
    } catch (_) {
      return const <ChallengeModel>[];
    }
  }
}
