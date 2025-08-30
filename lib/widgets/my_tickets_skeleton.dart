import 'package:flutter/material.dart';

class MyTicketsSkeleton extends StatelessWidget {
  const MyTicketsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceVariant;
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 16, width: 120, color: baseColor),
              const SizedBox(height: 8),
              Container(height: 12, width: 200, color: baseColor),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

