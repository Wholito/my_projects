import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../models/friend_request.dart';
import '../../providers/app_providers.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final friends = context.watch<FriendsProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Друзья'),
        actions: [
          if (auth.user != null)
            TextButton.icon(
              onPressed: () => _showMyCode(context, auth.user!.friendCode),
              icon: const Icon(Icons.badge_outlined),
              label: Text(auth.user!.friendCode),
            ),
        ],
      ),
      body: Column(
        children: [
          if (friends.incomingRequests.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.mail_outline,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Приглашения (${friends.incomingRequests.length})',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ...friends.incomingRequests.map(
              (r) => _IncomingRequestCard(request: r),
            ),
            const Divider(height: 24),
          ],
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Код друга (SF-XXXX)',
                      hintText: 'SF-AB12',
                      prefixIcon: Icon(Icons.search),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _search(context),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: friends.loading ? null : () => _search(context),
                  child: friends.loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Найти'),
                ),
              ],
            ),
          ),
          if (friends.foundUser != null)
            _FoundUserCard(
              user: friends.foundUser!,
              currentFriends: friends.friends,
              requestPending: friends.hasOutgoingRequest(friends.foundUser!.uid),
              onInvite: () async {
                final err = await context
                    .read<FriendsProvider>()
                    .sendFriendRequest(friends.foundUser!.uid);
                if (!context.mounted) return;
                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Приглашение отправлено')),
                  );
                  _codeCtrl.clear();
                }
              },
            ),
          if (friends.searchResult != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                friends.searchResult!,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          const Divider(),
          Expanded(
            child: friends.friends.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Пока нет друзей\nНайди по коду и отправь приглашение',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: friends.friends.length,
                    itemBuilder: (ctx, i) {
                      final friend = friends.friends[i];
                      return _FriendTile(friend: friend);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _search(BuildContext context) {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    context.read<FriendsProvider>().searchByCode(code);
  }

  void _showMyCode(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Мой код'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              code,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Отправь этот код друзьям,\nчтобы они тебя нашли',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Код скопирован!')),
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text('Скопировать'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ок'),
          ),
        ],
      ),
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  final FriendRequest request;

  const _IncomingRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final friends = context.read<FriendsProvider>();
    final hasAvatar = request.fromAvatarUrl != null &&
        request.fromAvatarUrl!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage:
              hasAvatar ? CachedNetworkImageProvider(request.fromAvatarUrl!) : null,
          child: hasAvatar
              ? null
              : Text(request.fromName[0].toUpperCase()),
        ),
        title: Text(request.fromName),
        subtitle: const Text('Хочет добавить тебя в друзья'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => friends.rejectFriendRequest(request.fromUid),
            ),
            FilledButton(
              onPressed: () => friends.acceptFriendRequest(request.fromUid),
              child: const Text('Принять'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FoundUserCard extends StatelessWidget {
  final AppUser user;
  final List<AppUser> currentFriends;
  final bool requestPending;
  final VoidCallback onInvite;

  const _FoundUserCard({
    required this.user,
    required this.currentFriends,
    required this.requestPending,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final alreadyFriend = currentFriends.any((f) => f.uid == user.uid);
    final isSelf =
        context.read<AuthProvider>().user?.uid == user.uid;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
              ? CachedNetworkImageProvider(user.avatarUrl!)
              : null,
          child: user.avatarUrl == null || user.avatarUrl!.isEmpty
              ? Text(user.displayName[0].toUpperCase())
              : null,
        ),
        title: Text(user.displayName),
        subtitle: Text(user.friendCode),
        trailing: isSelf
            ? const Chip(label: Text('Это вы'))
            : alreadyFriend
                ? const Chip(label: Text('Уже друг'))
                : requestPending
                    ? const Chip(label: Text('Приглашение отправлено'))
                    : FilledButton(
                        onPressed: onInvite,
                        child: const Text('Пригласить'),
                      ),
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final AppUser friend;

  const _FriendTile({required this.friend});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundImage: friend.avatarUrl != null && friend.avatarUrl!.isNotEmpty
            ? CachedNetworkImageProvider(friend.avatarUrl!)
            : null,
        child: friend.avatarUrl == null || friend.avatarUrl!.isEmpty
            ? Text(friend.displayName[0].toUpperCase())
            : null,
      ),
      title: Text(friend.displayName),
      subtitle: Text(
        '${friend.totalScore} очков · ${friend.roundsPlayed} раундов',
      ),
      trailing: PopupMenuButton(
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'remove',
            child: Text('Удалить из друзей'),
          ),
        ],
        onSelected: (v) {
          if (v == 'remove') {
            context.read<FriendsProvider>().removeFriend(friend.uid);
          }
        },
      ),
    );
  }
}
