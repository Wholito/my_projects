import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/app_user.dart';
import '../../models/game_session.dart';  // <-- ДОБАВЛЕНО
import '../../navigation/game_navigation.dart';
import '../../providers/app_state.dart';
import '../../services/game_service.dart';
import '../../widgets/network_aware.dart';
import '../profile/edit_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with NetworkAwareState {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user!;
    final friendsService = context.read<AppState>().friends;
    final gameService = context.read<AppState>().game;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pisarik Guessr'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Выход из аккаунта'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
                    FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Выйти')),
                  ],
                ),
              );
              if (confirm == true) {
                context.read<AppState>().logout();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ProfileCard(user: user),
          const SizedBox(height: 16),
          _ActiveGameCard(userId: user.id, gameService: gameService),
          _InvitesSection(userId: user.id, gameService: gameService),
          _FriendsSection(userId: user.id, friendsService: friendsService),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFriendDialog(context),
        icon: const Icon(Icons.person_add),
        label: const Text('Добавить друга'),
      ),
    );
  }

  void _openGame(BuildContext context, String gameId) {
    GameNavigation.openGame(gameId);
  }

  Future<void> _startGameWithFriend(BuildContext context, AppUser friend) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 2),
          content: Text('Поиск игры...'),
        ),
      );

      final appState = context.read<AppState>();
      final user = appState.user!;

      String? existingGameId = await appState.game.findActiveGameBetween(user.id, friend.id);
      if (existingGameId != null) {
        final gameDoc = await appState.game.getGame(existingGameId);
        if (gameDoc.exists) {
          final game = GameSession.fromMap(existingGameId, gameDoc.data() as Map<String, dynamic>);
          if (game.hostId != user.id && game.guestId != user.id) {
            await appState.game.joinGame(existingGameId, user.id);
          }
          messenger.hideCurrentSnackBar();
          _openGame(context, existingGameId);
          return;
        }
      }

      final gameId = await appState.game.createGame(user.id);
      await appState.game.inviteFriendToGame(
        gameId: gameId,
        friendId: friend.id,
        hostId: user.id,
      );

      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      _openGame(context, gameId);
    } catch (e) {
      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
    }
  }

  void _showAddFriendDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Добавить друга'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Код друга',
            hintText: 'ABC123',
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(6),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () async {
              final ok = await context.read<AppState>().addFriend(
                controller.text,
              );
              if (ctx.mounted) Navigator.pop(ctx);
              if (ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Друг добавлен!')),
                );
              } else if (context.mounted) {
                final err = context.read<AppState>().error;
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                }
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: user.photoUrl == null || user.photoUrl!.isEmpty
                        ? Text(user.displayName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Ваш код: ',
                          style: TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                        SelectableText(
                          user.friendCode,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: user.friendCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Код скопирован')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveGameCard extends StatelessWidget {
  const _ActiveGameCard({required this.userId, required this.gameService});

  final String userId;
  final dynamic gameService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>?>(
      key: ValueKey('active_game_$userId'),
      stream: gameService.watchActiveGameDetails(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              color: Colors.red.shade900.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Не удалось загрузить активную игру.',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }

        final activeData = snapshot.data;
        if (activeData == null) return const SizedBox.shrink();

        final gameId = activeData['gameId'] as String;
        final opponentName = activeData['opponentName'] as String;
        final opponentPhoto = activeData['opponentPhoto'] as String?;
        final phase = activeData['phase'] as String?;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Card(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: opponentPhoto != null ? NetworkImage(opponentPhoto) : null,
                        child: opponentPhoto == null ? Text(opponentName[0].toUpperCase()) : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phase == 'waitingForPlayer' ? 'Ожидание игрока...' : 'Игра с $opponentName',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            if (phase == 'waitingForPlayer')
                              const Text('Приглашение отправлено', style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => GameNavigation.openGame(gameId),
                    icon: const Icon(Icons.sports_esports),
                    label: const Text('Вернуться в игру'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InvitesSection extends StatelessWidget {
  const _InvitesSection({required this.userId, required this.gameService});

  final String userId;
  final dynamic gameService;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: gameService.watchInvites(userId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Не удалось загрузить приглашения.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          );
        }
        final invites = snapshot.data ?? [];
        if (invites.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Приглашения в игру', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...invites.map(
                  (invite) => _InviteCard(
                invite: invite,
                gameService: gameService,
                userId: userId,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection({required this.userId, required this.friendsService});

  final String userId;
  final dynamic friendsService;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Друзья', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        StreamBuilder<List<AppUser>>(
          stream: friendsService.watchFriends(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final friends = snapshot.data ?? [];
            if (friends.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Пока нет друзей. Добавьте друга по коду!',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              );
            }
            return Column(
              children: friends
                  .map(
                    (f) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: f.photoUrl != null && f.photoUrl!.isNotEmpty
                          ? NetworkImage(f.photoUrl!)
                          : null,
                      child: f.photoUrl == null || f.photoUrl!.isEmpty
                          ? Text(f.displayName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(f.displayName),
                    subtitle: Text('Код: ${f.friendCode}'),
                    trailing: FilledButton(
                      onPressed: () => _startGameWithFriend(context, f),
                      child: const Text('Играть'),
                    ),
                  ),
                ),
              )
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  void _startGameWithFriend(BuildContext context, AppUser friend) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    homeState?._startGameWithFriend(context, friend);
  }
}

class _InviteCard extends StatefulWidget {
  const _InviteCard({
    required this.invite,
    required this.gameService,
    required this.userId,
  });

  final Map<String, dynamic> invite;
  final dynamic gameService;
  final String userId;

  @override
  State<_InviteCard> createState() => _InviteCardState();
}

class _InviteCardState extends State<_InviteCard> with SingleTickerProviderStateMixin {
  bool _accepting = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _accept() async {
    if (_accepting) return;
    setState(() => _accepting = true);

    final messenger = ScaffoldMessenger.of(context);
    final gameId = widget.invite['gameId'] as String;

    try {
      await widget.gameService.acceptInvite(
        widget.invite['id'] as String,
        gameId,
        widget.userId,
      );
      if (!mounted) return;
      GameNavigation.openGame(gameId);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _accepting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fromUserName = widget.invite['fromUserName'] ?? 'Друг';
    final fromUserPhotoUrl = widget.invite['fromUserPhotoUrl'] as String?;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Card(
          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3 + 0.1 * _pulseController.value),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: fromUserPhotoUrl != null && fromUserPhotoUrl.isNotEmpty
                  ? NetworkImage(fromUserPhotoUrl)
                  : null,
              child: (fromUserPhotoUrl == null || fromUserPhotoUrl.isEmpty)
                  ? Text(fromUserName[0].toUpperCase())
                  : null,
            ),
            title: Text('$fromUserName'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _accepting
                      ? null
                      : () => widget.gameService.declineInvite(
                    widget.invite['id'] as String,
                  ),
                ),
                FilledButton(
                  onPressed: _accepting ? null : _accept,
                  child: _accepting
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Принять'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}