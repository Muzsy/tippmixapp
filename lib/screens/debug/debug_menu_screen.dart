import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/experiment_service.dart';

// TODO: replace RadioListTile usage with RadioGroup when migrating to Flutter's
// new API.
// ignore_for_file: deprecated_member_use

class DebugMenuScreen extends ConsumerStatefulWidget {
  const DebugMenuScreen({super.key});

  @override
  ConsumerState<DebugMenuScreen> createState() => _DebugMenuScreenState();
}

class _DebugMenuScreenState extends ConsumerState<DebugMenuScreen> {
  String? _override;

  Future<void> _setVariant(String? v) async {
    await ref.read(experimentServiceProvider).overrideVariant(v);
    setState(() => _override = v);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Menu')),
      body: Column(
        children: [
          RadioListTile<String?>(
            title: const Text('System default'),
            value: null,
            groupValue: _override,
            onChanged: _setVariant,
          ),
          RadioListTile<String?>(
            title: const Text('Variant A'),
            value: 'A',
            groupValue: _override,
            onChanged: _setVariant,
          ),
          RadioListTile<String?>(
            title: const Text('Variant B'),
            value: 'B',
            groupValue: _override,
            onChanged: _setVariant,
          ),
        ],
      ),
    );
  }
}
