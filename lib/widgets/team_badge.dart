import 'package:flutter/material.dart';

class TeamBadge extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double size;
  const TeamBadge({
    super.key,
    required this.initials,
    this.imageUrl,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _fallback(context),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : Center(
                        child: SizedBox(
                          width: size / 2,
                          height: size / 2,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                      ),
              )
            : _fallback(context),
      ),
    );
  }

  Widget _fallback(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Text(initials, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}
