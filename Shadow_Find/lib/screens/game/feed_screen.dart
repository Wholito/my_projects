import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/round.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../../utils/platform_utils.dart';
import '../../utils/russian_text.dart';
import 'game_screen.dart';
import 'result_screen.dart';
import '../../widgets/fade_slide_in.dart';

class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<FeedProvider>();
    final auth = context.watch<AuthProvider>();
    final uid = auth.user?.uid ?? '';

    if (feed.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (feed.rounds.isEmpty) {
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      return Center(
        child: FadeSlideIn(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_camera_outlined, size: 64, color: muted),
              const SizedBox(height: 16),
              Text(
                'Пока нет фото для угадывания',
                style: TextStyle(color: muted, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                isGuessOnlyPlatform
                    ? 'Попроси друзей прислать снимок с телефона'
                    : 'Попроси друзей прислать снимок!',
                style: TextStyle(color: muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final pending = feed.pendingGuessFor(uid);
    final guessed = feed.guessedBy(uid);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        if (pending.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Угадай, где',
            icon: Icons.location_on,
            subtitle: 'Еще не угадал',
          ),
          ...pending.asMap().entries.map(
                (e) => FadeSlideIn(
                  delay: Duration(milliseconds: 60 * e.key),
                  child: _RoundCard(round: e.value, guessed: false),
                ),
              ),
        ],
        if (guessed.isNotEmpty) ...[
          const _SectionHeader(
            title: 'Уже угадали',
            icon: Icons.check_circle_outline,
          ),
          ...guessed.asMap().entries.map(
                (e) => FadeSlideIn(
                  delay: Duration(milliseconds: 60 * e.key),
                  child: _RoundCard(round: e.value, guessed: true),
                ),
              ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;

  const _SectionHeader({required this.title, required this.icon, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoundCard extends StatelessWidget {
  final PhotoRound round;
  final bool guessed;

  const _RoundCard({required this.round, required this.guessed});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final myGuess = guessed
        ? round.guesses.where((g) => g.uid == auth.user?.uid).firstOrNull
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          fadeSlideRoute(
            guessed ? ResultScreen(round: round) : GameScreen(round: round),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: round.photoUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 48),
                  ),
                  if (guessed)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const Center(
                          child: Icon(Icons.check_circle,
                              color: Colors.white, size: 48),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundImage: round.authorAvatarUrl != null
                                  ? CachedNetworkImageProvider(round.authorAvatarUrl!)
                                  : null,
                              child: round.authorAvatarUrl == null
                                  ? Text(round.authorName[0].toUpperCase(), style: const TextStyle(fontSize: 12))
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              photoFromAuthor(round.authorName),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _timeAgo(round.createdAt),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (myGuess != null)
                    Chip(
                      label: Text(
                        scoreLabel(myGuess.score),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor:
                          _scoreColor(myGuess.score).withValues(alpha: 0.15),
                    )
                  else
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        fadeSlideRoute(GameScreen(round: round)),
                      ),
                      child: const Text('Угадать'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inHours < 1) return '${diff.inMinutes} мин назад';
    if (diff.inDays < 1) return '${diff.inHours} ч назад';
    return '${diff.inDays} д назад';
  }

  Color _scoreColor(int s) => AppTheme.scoreColor(s);
}
