import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/models/game_theme.dart';
import 'package:pisarik_guessr/providers/app_state.dart';
import 'package:pisarik_guessr/widgets/theme_button.dart';

class ThemePhase extends StatelessWidget {
  const ThemePhase({super.key, required this.game, required this.gameId});

  final GameSession game;
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AppState>().user!.id;
    final myVote = userId == game.hostId ? game.hostThemeVote : game.guestThemeVote;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Выберите игру для раунда',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (myVote != null) ...[
            const SizedBox(height: 8),
            Text(
              game.isFull
                  ? 'Вы выбрали: ${GameTheme.fromId(myVote)?.displayName ?? myVote}. Переходим к раунду...'
                  : 'Вы выбрали: ${GameTheme.fromId(myVote)?.displayName ?? myVote}. Ждём соперника...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ] else if (!game.isFull) ...[
            const SizedBox(height: 8),
            Text(
              'Ждём, пока соперник примет приглашение',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ],
          const SizedBox(height: 32),
          ...GameTheme.values.map((theme) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ThemeButton(
              theme: theme,
              selected: myVote == theme.id,
              onTap: myVote == null
                  ? () => context
                  .read<AppState>()
                  .game
                  .voteTheme(gameId: gameId, userId: userId, theme: theme)
                  : null,
            ),
          )),
        ],
      ),
    );
  }
}