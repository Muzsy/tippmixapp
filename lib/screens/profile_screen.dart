import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../providers/auth_provider.dart';
import 'package:tippmixapp/l10n/app_localizations.dart';
import '../constants.dart';
import '../widgets/avatar_gallery.dart';
import '../widgets/coin_badge.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user.dart' as app_user;
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  FirebaseStorage? storage;
  FirebaseFirestore? firestore;
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

  Future<void> _showAvatarGallery(dynamic user) async {
    final loc = AppLocalizations.of(context)!;
    final uid = user is firebase_auth.User
        ? user.uid
        : (user as app_user.User).id;
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
                  uid: uid,
                  data: {'avatarUrl': path},
                  firestore: FirebaseFirestore.instance,
                  cache: _dummyCache,
                  connectivity: _dummyConnectivity,
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

  Future<void> _pickPhoto(dynamic user) async {
    final loc = AppLocalizations.of(context)!;
    final picked = await imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final lower = picked.name.toLowerCase();
    if (!(lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(loc.profile_avatar_error)));
      return;
    }
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      if (storage != null && firestore != null) {
        final url = await ProfileService.uploadAvatar(
          uid: user is firebase_auth.User
              ? user.uid
              : (user as app_user.User).id,
          file: File(picked.path),
          storage: storage!,
          firestore: firestore!,
          cache: _dummyCache,
          connectivity: _dummyConnectivity,
        );
        if (!mounted) return;
        setState(() => _avatarUrl = url);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.profile_avatar_updated)));
        await WidgetsBinding.instance.endOfFrame;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(loc.profile_avatar_error)));
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  @visibleForTesting
  Future<void> pickPhoto(
    dynamic user, {
    ImagePicker? picker,
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
  }) {
    if (picker != null) imagePicker = picker;
    if (storage != null) this.storage = storage;
    if (firestore != null) this.firestore = firestore;
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
      storage = FirebaseStorage.instance;
      firestore = FirebaseFirestore.instance;
      final user = firebase_auth.FirebaseAuth.instance.currentUser;
      if (user != null && _avatarUrl == null) {
        _avatarUrl = user.photoURL;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final firebaseUser = Firebase.apps.isNotEmpty
        ? firebase_auth.FirebaseAuth.instance.currentUser
        : null;
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

    final content = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: firebaseUser != null
                    ? () => _showAvatarGallery(firebaseUser)
                    : null,
                child: buildAvatar(context, _avatarUrl, displayName),
              ),
              const Spacer(),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .collection('wallet')
                    .doc('main')
                    .snapshots(),
                builder: (context, snapshot) {
                  final data = snapshot.data?.data();
                  final coins = data?['coins'] as int?;
                  return CoinBadge(balance: coins);
                },
              ),
            ],
          ),
          TextButton(
            onPressed: firebaseUser != null
                ? () => pickPhoto(firebaseUser)
                : null,
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
          const SizedBox(height: 8),
          // Név + Becenév megjelenítése Firestore-ból, fallback auth displayName-re
          if (Firebase.apps.isNotEmpty)
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() ?? const <String, dynamic>{};
                final nameVal = (data['displayName'] as String?)?.trim();
                final nickVal = (data['nickname'] as String?)?.trim();
                final name = (nameVal != null && nameVal.isNotEmpty)
                    ? nameVal
                    : displayName;
                final nickname = (nickVal != null && nickVal.isNotEmpty)
                    ? nickVal
                    : displayName;
                final same =
                    name.trim().toLowerCase() == nickname.trim().toLowerCase();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!same && name.isNotEmpty) ...[
                      Text(
                        '${loc.profile_name}: $name',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      '${loc.profile_nickname}: $nickname',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                );
              },
            )
          else ...[
            // When Firestore not available, avoid duplication if both fallback are equal
            Text(
              '${loc.profile_nickname}: $displayName',
              style: const TextStyle(fontSize: 16),
            ),
          ],
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
                if (Firebase.apps.isNotEmpty) {
                  await ProfileService.updateProfile(
                    uid: uid,
                    data: {
                      'fieldVisibility': {key: v},
                    },
                    firestore: FirebaseFirestore.instance,
                    cache: _dummyCache,
                    connectivity: _dummyConnectivity,
                  );
                }
              },
            );
          }),
          const Divider(),
          if (Firebase.apps.isNotEmpty)
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

class _NoCache {
  dynamic get(String key) => null;
  void set(String key, dynamic value, Duration ttl) {}
  void invalidate(String key) {}
}

class _AlwaysOnline {
  bool get online => true;
}
