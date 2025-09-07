import 'package:cloud_firestore/cloud_firestore.dart';

/// Entities that can be reported.
enum ReportEntityType { post, thread }

extension ReportEntityTypeX on ReportEntityType {
  String toJson() => name;
  static ReportEntityType fromJson(String value) =>
      ReportEntityType.values.firstWhere((e) => e.name == value);
}

/// Status of a report.
enum ReportStatus { open, resolved }

extension ReportStatusX on ReportStatus {
  String toJson() => name;
  static ReportStatus fromJson(String value) =>
      ReportStatus.values.firstWhere((e) => e.name == value);
}

/// Report document for moderation.
class Report {
  final String id;
  final ReportEntityType entityType;
  final String entityId;
  final String reason;
  final String? message;
  final String reporterId;
  final DateTime createdAt;
  final ReportStatus status;

  const Report({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.reason,
    this.message,
    required this.reporterId,
    required this.createdAt,
    this.status = ReportStatus.open,
  });

  factory Report.fromJson(String id, Map<String, dynamic> json) {
    return Report(
      id: id,
      entityType: ReportEntityTypeX.fromJson(json['entityType'] as String),
      entityId: json['entityId'] as String,
      reason: json['reason'] as String,
      message: json['message'] as String?,
      reporterId: json['reporterId'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      status: ReportStatusX.fromJson(json['status'] as String? ?? 'open'),
    );
  }

  Map<String, dynamic> toJson() => {
    'entityType': entityType.toJson(),
    'entityId': entityId,
    'reason': reason,
    'message': message,
    'reporterId': reporterId,
    'createdAt': Timestamp.fromDate(createdAt),
    'status': status.toJson(),
  };
}
