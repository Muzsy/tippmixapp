class RewardModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String iconName;
  bool isClaimed;
  final Future<void> Function() onClaim;

  RewardModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.iconName,
    required this.isClaimed,
    required this.onClaim,
  });
}
