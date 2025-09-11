import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../providers/auth_provider.dart';
import 'package:tipsterino/l10n/app_localizations.dart';
import '../constants.dart';
import '../widgets/avatar_gallery.dart';
import '../widgets/coin_badge.dart';
import '../models/user.dart' as app_user;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// Firebase storage removed
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';
import '../models/user_model.dart';
import '../providers/coin_provider.dart';
// Firestore removed
import '../services/profile_service.dart';
import 'profile/partials/notification_prefs_section.dart';
import '../services/user_service.dart';

@visibleForTesting
Widget buildAvatar(BuildContext context, String? photoUrl, String displayName) {
  const size = 80.0;
  final placeholder = Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
    alignment: Alignment.center,
    child: Text(
      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
      style: Theme.of(context).textTheme.titleLarge,
    ),
  );

  if (photoUrl == null || photoUrl.isEmpty) {
    return placeholder;
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Image(
      image: photoUrl.startsWith('http')
          ? NetworkImage(photoUrl)
          : AssetImage(photoUrl) as ImageProvider,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => placeholder,
    ),
  );
}

class ProfileScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ProfileScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<ProfileScreen> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isPrivate = false;
  ImagePicker imagePicker = ImagePicker();
  final Map<String, bool> _fieldVisibility = {
    "city": true,
    "country": true,
    "friends": true,
    "favoriteSports": true,
    "favoriteTeams": true,
  };
  bool _loggingOut = false;
  String? _error;
  String? _avatarUrl;

  Future<void> _showAvatarGallery(app_user.User user) async {
    final loc = AppLocalizations.of(context)!;
    final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
    final uid = user.id;
    await showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: AvatarGallery(
          onAvatarSelected: (path) async {
            Navigator.pop(context);
            setState(() => _avatarUrl = path);
            try {
              if (useSupabase) {
                await ProfileService.updateProfile(
                  uid: uid,
                  data: {'avatarUrl': path},
                );
              }
            } catch (_) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(loc.profile_avatar_error)));
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickPhoto(app_user.User user) async {
    final loc = AppLocalizations.of(context)!;
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final lower = picked.name.toLowerCase();
    if (!(lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(loc.profile_avatar_error)));
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final uid = user.id;
      final url = await ProfileService.uploadAvatar(
        uid: uid,
        file: File(picked.path),
      );
      if (!mounted) return;
      setState(() => _avatarUrl = url);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.profile_avatar_updated)),
      );
      await WidgetsBinding.instance.endOfFrame;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(loc.profile_avatar_error)));
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @visibleForTesting
  Future<void> pickPhoto(
    app_user.User user, {
    ImagePicker? picker,
    Object? storage,
    Object? firestore,
  }) {
    if (picker != null) imagePicker = picker;
    return _pickPhoto(user);
  }

  Future<bool> _defaultExists() async {
    try {
      await rootBundle.load(kDefaultAvatarPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Minimal cache/connectivity stubs removed

  String _labelForKey(AppLocalizations loc, String key) {
    switch (key) {
      case 'city':
        return loc.profile_city;
      case 'country':
        return loc.profile_country;
      case 'friends':
        return loc.profile_friends;
      case 'favoriteSports':
        return loc.profile_favorite_sports;
      case 'favoriteTeams':
        return loc.profile_favorite_teams;
    }
    return key;
  }

  Future<void> _logout() async {
    setState(() {
      _loggingOut = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).logout();
      // Siker esetén a GoRouter authProvider state miatt visszairányít
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loggingOut = false;
      });
    }
  }

  @override
  void initState() { super.initState(); }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final useSupabase = dotenv.env['USE_SUPABASE']?.toLowerCase() == 'true';
    final user = ref.watch(authProvider).user;

    if (user == null) {
      if (!widget.showAppBar || Scaffold.maybeOf(context) != null) {
        return Center(child: Text(loc.not_logged_in));
      }
      return Scaffold(
        appBar: AppBar(title: Text(loc.profile_title)),
        body: Center(child: Text(loc.not_logged_in)),
      );
    }

    final uid = user.id;
    final displayName = user.displayName;
    final email = user.email;

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showAvatarGallery(user),
                child: buildAvatar(context, _avatarUrl, displayName),
              ),
              const Spacer(),
              ref.watch(coinBalanceProvider).maybeWhen(
                      data: (v) => CoinBadge(balance: v),
                      orElse: () => const CoinBadge(balance: null),
                    ),
            ],
          ),
          TextButton(
            onPressed: () => pickPhoto(user),
            child: Text(loc.profileUploadPhoto),
          ),
          FutureBuilder<bool>(
            future: _defaultExists(),
            builder: (context, snapshot) {
              if (snapshot.data != true) {
                return const SizedBox.shrink();
              }
              return TextButton(
                onPressed: () async {
                  setState(() => _avatarUrl = kDefaultAvatarPath);
                  if (useSupabase) {
                    await ProfileService.updateProfile(
                      uid: uid,
                      data: {'avatarUrl': kDefaultAvatarPath},
                    );
                  }
                },
                child: Text(loc.profileResetAvatar),
              );
            },
          ),
          const SizedBox(height: 8),
          // Név + Becenév megjelenítése Supabase forrásból
          StreamBuilder<UserModel?>(
              stream: ProfileService.streamUserProfile(uid),
              builder: (context, snapshot) {
                final model = snapshot.data;
                final name = (model?.displayName ?? '').trim();
                final nickname = (model?.nickname ?? displayName).trim();
                final same = name.isEmpty ||
                    name.trim().toLowerCase() == nickname.trim().toLowerCase();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!same && name.isNotEmpty) ...[
                      Text('${loc.profile_name}: $name', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                    ],
                    Text('${loc.profile_nickname}: $nickname', style: const TextStyle(fontSize: 16)),
                  ],
                );
              },
            ),
          const SizedBox(height: 8),
          Text(
            '${loc.profile_email}: $email',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            dense: true,
            title: Text(loc.profile_global_privacy),
            value: _isPrivate,
            onChanged: (v) async {
              setState(() => _isPrivate = v);
              if (useSupabase) {
                await ProfileService.updateProfile(
                  uid: uid,
                  data: {'isPrivate': v},
                );
              }
            },
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () {
              context.goNamed(AppRoute.badges.name);
            },
            child: Text(loc.menuBadges),
          ),
          ..._fieldVisibility.keys.map((key) {
            return SwitchListTile(
              dense: true,
              title: Text(_labelForKey(loc, key)),
              value: _fieldVisibility[key]!,
              onChanged: (v) async {
                setState(() => _fieldVisibility[key] = v);
                if (useSupabase) {
                  await ProfileService.updateProfile(
                    uid: uid,
                    data: {
                      'fieldVisibility': {key: v},
                    },
                  );
                }
              },
            );
          }),
          const Divider(),
          if (useSupabase)
            NotificationPrefsSection(uid: uid, service: UserService()),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          _loggingOut
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
                  onPressed: _loggingOut ? null : _logout,
                  child: Text(loc.profile_logout),
                ),
          const SizedBox(height: 8),
        ],
      ),
    );

    if (!widget.showAppBar) {
      if (Scaffold.maybeOf(context) != null) {
        return content;
      }
      return Scaffold(body: content);
    }
    if (Scaffold.maybeOf(context) != null) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_title)),
      body: content,
    );
  }
}

// Stub classes removed
