import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';

import '../models/tip_model.dart';

class CopiedTicketEditScreen extends StatefulWidget {
  final String copyId;
  final List<TipModel> tips;

  const CopiedTicketEditScreen({
    super.key,
    required this.copyId,
    required this.tips,
  });

  @override
  State<CopiedTicketEditScreen> createState() => _CopiedTicketEditScreenState();
}

class _CopiedTicketEditScreenState extends State<CopiedTicketEditScreen> {
  late List<TipModel> _tips;
  bool _wasModified = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tips = List<TipModel>.from(widget.tips);
  }

  void _addTip() {
    setState(() {
      if (widget.tips.isNotEmpty) {
        _tips.add(widget.tips.first);
      }
      _wasModified = true;
    });
  }

  Future<void> _submit() async {
    final loc = AppLocalizations.of(context)!;
    if (!_wasModified) {
      setState(() => _error = loc.copy_invalid_state);
      return;
    }
    setState(() => _isLoading = true);
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _error = 'User not logged in';
        _isLoading = false;
      });
      return;
    }
    await FirebaseFirestore.instance
        .collection('copied_bets/$userId')
        .doc(widget.copyId)
        .update({
          'tips': _tips.map((e) => e.toJson()).toList(),
          'wasModified': true,
        });
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.copy_edit_title)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTip,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _tips.length,
                itemBuilder: (context, index) {
                  final tip = _tips[index];
                  return ListTile(
                    title: Text(tip.eventName),
                    subtitle: Text(tip.outcome),
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : (_wasModified ? _submit : null),
                child: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(loc.copy_submit_button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
