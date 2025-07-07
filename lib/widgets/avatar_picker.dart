import 'package:flutter/material.dart';
import '../constants.dart';
import 'avatar_gallery.dart';

class AvatarPicker extends StatefulWidget {
  final String? initial;
  final ValueChanged<String> onChanged;
  const AvatarPicker({super.key, this.initial, required this.onChanged});

  @override
  State<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<AvatarPicker> {
  String? _avatar;

  @override
  void initState() {
    super.initState();
    _avatar = widget.initial;
  }

  Future<void> _showPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: AvatarGallery(onAvatarSelected: (p) => Navigator.pop(context, p)),
      ),
    );
    if (selected != null) {
      setState(() => _avatar = selected);
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: CircleAvatar(
        radius: 40,
        backgroundImage: _avatar != null
            ? (_avatar!.startsWith('http')
                ? NetworkImage(_avatar!) as ImageProvider
                : AssetImage(_avatar!))
            : const AssetImage(kDefaultAvatarPath),
        child: _avatar == null ? const Icon(Icons.person) : null,
      ),
    );
  }
}
