import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

/// Displays selectable avatar images from assets/avatar/.
class AvatarGallery extends StatefulWidget {
  final ValueChanged<String> onAvatarSelected;
  const AvatarGallery({super.key, required this.onAvatarSelected});

  @override
  State<AvatarGallery> createState() => _AvatarGalleryState();
}

class _AvatarGalleryState extends State<AvatarGallery> {
  late Future<List<String>> _avatars;

  Future<List<String>> _loadAvatars() async {
    final manifest = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> map =
        json.decode(manifest) as Map<String, dynamic>;
    return map.keys
        .where(
          (k) =>
              k.startsWith('assets/avatar/') &&
              (k.endsWith('.png') || k.endsWith('.jpg')),
        )
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _avatars = _loadAvatars();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return FutureBuilder<List<String>>(
      future: _avatars,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final avatars = snapshot.data!;
        if (avatars.isEmpty) {
          return Center(child: Text(loc.profile_avatar_error));
        }
        return GridView.builder(
          shrinkWrap: true,
          itemCount: avatars.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
          ),
          itemBuilder: (context, index) {
            final path = avatars[index];
            return GestureDetector(
              onTap: () => widget.onAvatarSelected(path),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset(
                  path,
                  fit: BoxFit.cover,
                  semanticLabel: 'avatar',
                ),
              ),
            );
          },
        );
      },
    );
  }
}
