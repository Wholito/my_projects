import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'utils/permissions_helper.dart';

import 'firebase_options.dart';
import 'providers/app_providers.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/camera/camera_screen.dart';
import 'screens/friends/friends_screen.dart';
import 'screens/game/feed_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'services/firebase_service.dart';
import 'services/connectivity_service.dart';
import 'services/local_db_service.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/platform_utils.dart';
import 'widgets/app_brand_icon.dart';
import 'widgets/offline_banner.dart';

Future<void> _configureFirestore() async {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: 50 * 1024 * 1024,
    );
  } catch (_) {}
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await _configureFirestore();

  runApp(const ShadowFindApp());
}

class ShadowFindApp extends StatelessWidget {
  const ShadowFindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()..start()),
      ],
      child: MaterialApp(
        title: 'ShadowFind',
        theme: AppTheme.dark,
        home: const _AppRoot(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  static const _minSplash = Duration(milliseconds: 350);

  bool _bootstrapping = true;
  StreamSubscription<User?>? _authSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final current = firebaseService.currentAuthUser;

    try {
      final cached = await firebaseService.getCachedUser();
      if (cached != null &&
          current != null &&
          cached.uid == current.uid &&
          mounted) {
        auth.setUser(cached);
      }

      _authSub = firebaseService.authStream.listen(_onAuthChanged);

      await Future.wait([
        Future.delayed(_minSplash),
        _onAuthChanged(current, awaitProfile: !auth.isLoggedIn).timeout(
          const Duration(seconds: 8),
          onTimeout: () {},
        ),
      ]);

      if (mounted && auth.isLoggedIn && !isGuessOnlyPlatform) {
        unawaited(notificationService.init());
      }
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  Future<void> _onAuthChanged(
    User? user, {
    bool awaitProfile = true,
  }) async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();

    if (user == null) {
      auth.setUser(null);
      await firebaseService.clearCachedUser();
      return;
    }

    if (auth.user?.uid != user.uid) {
      final cached = await firebaseService.getCachedUser();
      if (cached != null && cached.uid == user.uid && mounted) {
        auth.setUser(cached);
      }
    }

    if (!awaitProfile && auth.isLoggedIn) {
      unawaited(_refreshProfile(user.uid));
      return;
    }

    try {
      final appUser = await firebaseService
          .getUser(user.uid)
          .timeout(const Duration(seconds: 6));
      if (appUser != null && mounted) {
        auth.setUser(appUser);
        await firebaseService.cacheUser(appUser);
      }
    } catch (_) {
      final cached = await firebaseService.getCachedUser();
      if (cached != null && cached.uid == user.uid && mounted) {
        auth.setUser(cached);
      }
    }
  }

  Future<void> _refreshProfile(String uid) async {
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    try {
      final appUser = await firebaseService.getUser(uid);
      if (appUser != null && mounted && auth.user?.uid == uid) {
        auth.setUser(appUser);
        await firebaseService.cacheUser(appUser);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_bootstrapping) return const SplashScreen();

    final auth = context.watch<AuthProvider>();
    if (!auth.isLoggedIn) return const AuthScreen();
    return const _MainShell();
  }
}

class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _tab = 0;
  StreamSubscription? _friendRequestsSub;

  bool get _isCameraTab {
    if (isGuessOnlyPlatform) return false;
    return _tab == 1;
  }

  List<Widget> _buildPages() {
    if (isGuessOnlyPlatform) {
      return const [
        FeedScreen(),
        FriendsScreen(),
        LeaderboardScreen(),
      ];
    }
    return [
      const FeedScreen(),
      _tab == 1 ? const CameraScreen() : const SizedBox.shrink(),
      const FriendsScreen(),
      const LeaderboardScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    if (!isGuessOnlyPlatform) {
      _ensureStartupPermissions();
    }
    _loadOfflineCache();
    _subscribeToData();
  }

  Future<void> _loadOfflineCache() async {
    final rounds = await localDbService.loadRounds();
    final friends = await localDbService.loadFriends();
    final requests = await localDbService.loadFriendRequests();
    if (!mounted) return;
    if (rounds.isNotEmpty) {
      context.read<FeedProvider>().setRounds(rounds);
    }
    if (friends.isNotEmpty) {
      context.read<FriendsProvider>().setFriends(friends);
    }
    if (requests.isNotEmpty) {
      context.read<FriendsProvider>().setIncomingRequests(requests);
    }
  }

  Future<void> _ensureStartupPermissions() async {
    await PermissionsHelper.ensureLocation();
    await PermissionsHelper.ensureNotifications();
  }

  @override
  void dispose() {
    _friendRequestsSub?.cancel();
    super.dispose();
  }

  void _subscribeToData() {
    firebaseService.watchFriends().listen((friends) {
      if (mounted) {
        context.read<FriendsProvider>().setFriends(friends);
        localDbService.saveFriends(friends);
      }
    });
    firebaseService.watchMyFeed().listen((rounds) {
      if (mounted) {
        context.read<FeedProvider>().setRounds(rounds);
        localDbService.saveRounds(rounds);
      }
    });
    _friendRequestsSub =
        firebaseService.watchIncomingFriendRequests().listen((requests) {
      if (mounted) {
        context.read<FriendsProvider>().setIncomingRequests(requests);
        localDbService.saveFriendRequests(requests);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: !_isCameraTab
          ? AppBar(
              titleSpacing: 16,
              title: const _AppBarBrandTitle(),
              actions: [
                if (auth.user != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      avatar: Icon(Icons.star, size: 16, color: scheme.primary),
                      label: Text('${auth.user!.totalScore}'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                PopupMenuButton<String>(
                  offset: const Offset(0, 40),
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: scheme.primaryContainer,
                    backgroundImage: auth.user?.avatarUrl != null
                        ? CachedNetworkImageProvider(auth.user!.avatarUrl!)
                        : null,
                    child: auth.user?.avatarUrl == null
                        ? Icon(Icons.person, size: 18, color: scheme.onPrimaryContainer)
                        : null,
                  ),
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'profile',
                      child: ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Профиль'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Выйти'),
                        dense: true,
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProfileScreen()),
                      );
                    } else if (value == 'logout') {
                      await context.read<AuthProvider>().signOut();
                    }
                  },
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: IndexedStack(index: _tab, children: _buildPages()),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: isGuessOnlyPlatform
            ? const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Лента',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Друзья',
                ),
                NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined),
                  selectedIcon: Icon(Icons.leaderboard),
                  label: 'Рейтинг',
                ),
              ]
            : const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Лента',
                ),
                NavigationDestination(
                  icon: Icon(Icons.camera_alt_outlined),
                  selectedIcon: Icon(Icons.camera_alt),
                  label: 'Снять',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Друзья',
                ),
                NavigationDestination(
                  icon: Icon(Icons.leaderboard_outlined),
                  selectedIcon: Icon(Icons.leaderboard),
                  label: 'Рейтинг',
                ),
              ],
      ),
    );
  }
}

class _AppBarBrandTitle extends StatelessWidget {
  const _AppBarBrandTitle();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          height: 1,
        );

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppBrandIcon(size: 36, borderRadius: 10),
        const SizedBox(width: 12),
        Text.rich(
          TextSpan(
            style: titleStyle?.copyWith(color: scheme.onSurface),
            children: [
              const TextSpan(text: 'Shadow'),
              TextSpan(
                text: ' Find',
                style: TextStyle(color: scheme.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
