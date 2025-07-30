import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../validators/display_name_validator.dart';
import '../../widgets/avatar_picker.dart';
import '../../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel? initial;
  final UserService service;
  EditProfileScreen({super.key, this.initial, UserService? service})
    : service = service ?? UserService();

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  String? _team;
  DateTime? _dob;
  String? _avatar;
  bool _saving = false;

  final _nameValidator = DisplayNameValidator();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.initial?.displayName ?? '',
    );
    _bioController = TextEditingController(text: widget.initial?.bio ?? '');
    _team = widget.initial?.favouriteTeam;
    _dob = widget.initial?.dateOfBirth;
    _avatar = widget.initial?.avatarUrl;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final changes =
        <String, dynamic>{
          'displayName': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
          'favouriteTeam': _team,
          'dateOfBirth': _dob?.toIso8601String(),
          'avatarUrl': _avatar,
        }..removeWhere(
          (key, value) =>
              value == null || value == widget.initial?.toJson()[key],
        );
    await widget.service.updateProfile(widget.initial?.uid ?? '', changes);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.profile_updated)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(loc.edit_title)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          children: [
            AvatarPicker(
              initial: _avatar,
              onChanged: (a) => setState(() => _avatar = a),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: loc.name_hint),
              validator: (v) => _nameValidator.validate(v ?? ''),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(labelText: loc.bio_hint),
              maxLength: 160,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _team,
              decoration: InputDecoration(labelText: loc.team_hint),
              items: const [
                DropdownMenuItem(value: 'teamA', child: Text('Team A')),
                DropdownMenuItem(value: 'teamB', child: Text('Team B')),
              ],
              onChanged: (v) => setState(() => _team = v),
            ),
            const SizedBox(height: 16),
            InputDatePickerFormField(
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              initialDate: _dob ?? DateTime(2000),
              fieldLabelText: loc.dob_hint,
              onDateSubmitted: (d) => _dob = d,
              onDateSaved: (d) => _dob = d,
              errorInvalidText: loc.dob_error_future,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saving ? null : _save,
        child: _saving
            ? const CircularProgressIndicator()
            : const Icon(Icons.save),
      ),
    );
  }
}
