import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import '../providers/register_state_notifier.dart';
import '../routes/app_route.dart';
import '../services/storage_service.dart';
import '../services/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../utils/image_resizer.dart';

class RegisterStep3Form extends ConsumerStatefulWidget {
  const RegisterStep3Form({super.key});

  @override
  ConsumerState<RegisterStep3Form> createState() => _RegisterStep3FormState();
}

class _RegisterStep3FormState extends ConsumerState<RegisterStep3Form> {
  ImagePicker _picker = ImagePicker();
  File? _image;
  Future<File> Function(File file)? _cropOverride;

  @visibleForTesting
  set testPicker(ImagePicker p) => _picker = p;

  @visibleForTesting
  set testCrop(Future<File> Function(File file) fn) => _cropOverride = fn;

  Future<File> _cropSquare(File file) async {
    if (_cropOverride != null) return _cropOverride!(file);
    final bytes = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final img = frame.image;
    final size = math.min(img.width, img.height).toDouble();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final src = Rect.fromLTWH(
      ((img.width - size) / 2).toDouble(),
      ((img.height - size) / 2).toDouble(),
      size,
      size,
    );
    final dst = Rect.fromLTWH(0, 0, size, size);
    canvas.drawImageRect(img, src, dst, Paint());
    final cropped = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final data = await cropped.toByteData(format: ui.ImageByteFormat.png);
    final bytesOut = data!.buffer.asUint8List();
    final out = await file.writeAsBytes(bytesOut, flush: true);
    return out;
  }

  Future<void> _pick(ImageSource source) async {
    final picked = await _picker.pickImage(source: source);
    if (picked == null) return;
    var file = File(picked.path);
    file = await _cropSquare(file);
    // Downscale if needed to fit under 2MB
    if (await file.length() > 2 * 1024 * 1024) {
      file = await ImageResizer.downscalePng(file, maxBytes: 2 * 1024 * 1024, initialMaxDimension: 1024);
    }
    if (await file.length() > 2 * 1024 * 1024) {
      // As a last resort, inform user but still allow smaller attempt
      if (!mounted) return;
      final loc = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.register_avatar_too_large)),
      );
      return;
    }
    setState(() => _image = file);
  }

  Future<void> _finish() async {
    final notifier = ref.read(registerStateNotifierProvider.notifier);
    await notifier.completeRegistration();
    if (_image != null) {
      try {
        final uid = sb.Supabase.instance.client.auth.currentUser?.id;
        if (uid != null) {
          final url = await ProfileService.uploadAvatar(uid: uid, file: _image!);
          notifier.saveAvatar(url);
        }
      } catch (_) {
        // Non‑fatal: user can set avatar later in profile
      }
    }
    // sikeres regisztráció után állapot törlése
    notifier.reset();
    if (mounted) context.goNamed(AppRoute.home.name);
  }

  Future<void> _skip() async {
    await ref
        .read(registerStateNotifierProvider.notifier)
        .completeRegistration();
    // sikeres regisztráció után állapot törlése
    ref.read(registerStateNotifierProvider.notifier).reset();
    if (mounted) context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: _image != null ? FileImage(_image!) : null,
            child: _image == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: Text(loc.register_take_photo),
              ),
              OutlinedButton.icon(
                onPressed: () => _pick(ImageSource.gallery),
                icon: const Icon(Icons.photo),
                label: Text(loc.register_choose_file),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(onPressed: _skip, child: Text(loc.register_skip)),
              ElevatedButton(
                key: const Key('finishButton'),
                onPressed: _finish,
                child: Text(loc.register_finish),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
