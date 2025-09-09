import 'package:flutter/material.dart';
import 'package:tipsterino/features/forum/domain/post.dart';

/// Small card displaying a quoted post snippet.
class QuotedPostCard extends StatelessWidget {
  const QuotedPostCard({super.key, required this.post, this.onTap});

  final Post post;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.only(bottom: 4),
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Text(post.content),
      ),
    );
  }
}
