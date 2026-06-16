import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_user.dart';
import '../../providers/app_providers.dart';
import '../../services/firebase_service.dart';
import '../../services/local_db_service.dart';
import '../../utils/russian_text.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<AppUser> _leaders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final cached = await localDbService.loadLeaderboard();
      if (cached.isNotEmpty && mounted) {
        setState(() {
          _leaders = cached;
          _loading = false;
        });
      }
      _leaders = await firebaseService.getLeaderboard();
    } catch (_) {
      final cached = await localDbService.loadLeaderboard();
      if (cached.isNotEmpty) {
        _leaders = cached;
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<AuthProvider>().user;

    return RefreshIndicator(
      onRefresh: _load,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: _leaders.length,
              itemBuilder: (ctx, i) {
                final user = _leaders[i];
                final isMe = user.uid == me?.uid;
                final rank = i + 1;

                return ListTile(
                  tileColor: isMe
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08)
                      : null,
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Center(child: _RankBadge(rank: rank)),
                      ),
                      const SizedBox(width: 10),
                      _LeaderAvatar(user: user),
                    ],
                  ),
                  title: Text(
                    user.displayName + (isMe ? ' (ты)' : ''),
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    '${user.roundsPlayed} раундов · '
                    'среднее ${scoreLabel(user.averageScore.round())}',
                  ),
                  trailing: Text(
                    '${user.totalScore}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _LeaderAvatar extends StatelessWidget {
  final AppUser user;

  const _LeaderAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasAvatar =
        user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;

    return CircleAvatar(
      radius: 22,
      backgroundColor: scheme.primaryContainer,
      backgroundImage:
          hasAvatar ? CachedNetworkImageProvider(user.avatarUrl!) : null,
      child: hasAvatar
          ? null
          : Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: scheme.onPrimaryContainer,
              ),
            ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank == 1) {
      return const Icon(Icons.emoji_events, color: Colors.amber, size: 26);
    }
    if (rank == 2) {
      return Icon(Icons.emoji_events, color: Colors.grey[400], size: 26);
    }
    if (rank == 3) {
      return const Icon(Icons.emoji_events, color: Colors.brown, size: 26);
    }
    return Text(
      '$rank',
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
