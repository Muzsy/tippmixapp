import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/auth_provider.dart';
import '../l10n/app_localizations.dart';
import '../constants.dart';
import '../widgets/avatar_gallery.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/profile_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool showAppBar;

  const ProfileScreen({super.key, this.showAppBar = true});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isPrivate = false;
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

  Future<void> _showAvatarGallery(User user) async {
    final loc = AppLocalizations.of(context)!;
    await showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 400,
        child: AvatarGallery(
          onAvatarSelected: (path) async {
            Navigator.pop(context);
            setState(() => _avatarUrl = path);
              try {
                if (Firebase.apps.isNotEmpty) {
                  await ProfileService.updateProfile(
                    uid: user.uid,
                    data: {'avatarUrl': path},
                    firestore: FirebaseFirestore.instance,
                    cache: _dummyCache,
                    connectivity: _dummyConnectivity,
                  );
                }
              } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.profile_avatar_error)),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _pickPhoto(User user) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.profile_avatar_error,
        ),
      ),
    );
  }

  Future<bool> _defaultExists() async {
    try {
      await rootBundle.load(kDefaultAvatarPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  // Minimal cache/connectivity for ProfileService calls
  static final _dummyCache = _NoCache();
  static final _dummyConnectivity = _AlwaysOnline();

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
  void initState() {
    super.initState();
    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && _avatarUrl == null) {
        _avatarUrl = user.photoURL;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final firebaseUser =
        Firebase.apps.isNotEmpty ? FirebaseAuth.instance.currentUser : null;
    final user = ref.watch(authProvider).user;

    if (firebaseUser == null && user == null) {
      if (!widget.showAppBar || Scaffold.maybeOf(context) != null) {
        return Center(child: Text(loc.not_logged_in));
      }
      return Scaffold(
        appBar: AppBar(title: Text(loc.profile_title)),
        body: Center(child: Text(loc.not_logged_in)),
      );
    }

    final uid = firebaseUser?.uid ?? user!.id;
    final displayName = user?.displayName ?? firebaseUser?.displayName ?? '';
    final email = user?.email ?? firebaseUser?.email ?? '';

    final content = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: firebaseUser != null
                ? () => _showAvatarGallery(firebaseUser)
                : null,
            child: CircleAvatar(
              radius: 40,
              backgroundImage: _avatarUrl != null && _avatarUrl!.startsWith('http')
                  ? NetworkImage(_avatarUrl!) as ImageProvider
                  : _avatarUrl != null
                      ? AssetImage(_avatarUrl!)
                      : null,
              child: _avatarUrl == null ? const Icon(Icons.person) : null,
            ),
          ),
          TextButton(
            onPressed:
                firebaseUser != null ? () => _pickPhoto(firebaseUser) : null,
            child: Text(loc.profileUploadPhoto),
          ),
            FutureBuilder<bool>(
              future: _defaultExists(),
              builder: (context, snapshot) {
                if (snapshot.data != true || firebaseUser == null) {
                  return const SizedBox.shrink();
                }
                  return TextButton(
                    onPressed: () async {
                      setState(() => _avatarUrl = kDefaultAvatarPath);
                      if (Firebase.apps.isNotEmpty) {
                        await ProfileService.updateProfile(
                          uid: uid,
                          data: {'avatarUrl': kDefaultAvatarPath},
                          firestore: FirebaseFirestore.instance,
                          cache: _dummyCache,
                          connectivity: _dummyConnectivity,
                        );
                      }
                  },
                child: Text(loc.profileResetAvatar),
              );
            },
          ),
          const SizedBox(height: 12),
            Text('${loc.profile_nickname}: $displayName',
                style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
            Text('${loc.profile_email}: $email',
                style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 32),
          SwitchListTile(
            title: Text(loc.profile_global_privacy),
            value: _isPrivate,
              onChanged: (v) async {
                setState(() => _isPrivate = v);
                if (Firebase.apps.isNotEmpty) {
                  await ProfileService.updateProfile(
                    uid: uid,
                    data: {'isPrivate': v},
                    firestore: FirebaseFirestore.instance,
                    cache: _dummyCache,
                    connectivity: _dummyConnectivity,
                  );
                }
              },
          ),
          const Divider(),
          ..._fieldVisibility.keys.map((key) {
            return SwitchListTile(
              title: Text(_labelForKey(loc, key)),
              value: _fieldVisibility[key]!,
              onChanged: (v) async {
                setState(() => _fieldVisibility[key] = v);
                if (Firebase.apps.isNotEmpty) {
                  await ProfileService.updateProfile(
                    uid: uid,
                    data: {
                      'fieldVisibility': {key: v}
                    },
                    firestore: FirebaseFirestore.instance,
                    cache: _dummyCache,
                    connectivity: _dummyConnectivity,
                  );
                }
              },
            );
          }),
          const SizedBox(height: 32),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            _loggingOut
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _loggingOut ? null : _logout,
                    child: Text(loc.profile_logout),
                  ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                context.goNamed(AppRoute.badges.name);
              },
              child: Text(loc.menuBadges),
            ),
          ],
        ),
      );

    if (!widget.showAppBar) return content;
    if (Scaffold.maybeOf(context) != null) {
      return content;
    }
    return Scaffold(
      appBar: AppBar(title: Text(loc.profile_title)),
      body: content,
    );
  }
}

class _NoCache {
  dynamic get(String key) => null;
  void set(String key, dynamic value, Duration ttl) {}
  void invalidate(String key) {}
}

class _AlwaysOnline {
  bool get online => true;
}
