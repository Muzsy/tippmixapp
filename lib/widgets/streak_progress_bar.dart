import 'package:flutter/material.dart';

class StreakProgressBar extends StatelessWidget {
  final int streakDays;
  const StreakProgressBar({super.key, required this.streakDays});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Streak: $streakDays/7'),
        LinearProgressIndicator(value: streakDays / 7.0),
      ],
    );
  }
}
