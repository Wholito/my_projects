import 'package:flutter/material.dart';
import 'package:pisarik_guessr/screens/game/widgets/all_items_dialog.dart';
import 'package:pisarik_guessr/screens/game/widgets/word_suggestions_dialog.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/providers/app_state.dart';
import 'package:pisarik_guessr/screens/game/phases/waiting_phase.dart';
import 'package:pisarik_guessr/screens/game/phases/theme_phase.dart';
import 'package:pisarik_guessr/screens/game/phases/mode_selection_phase.dart';
import 'package:pisarik_guessr/screens/game/phases/role_phase.dart';
import 'package:pisarik_guessr/screens/game/phases/selection_phase.dart';
import 'package:pisarik_guessr/screens/game/phases/play_phase.dart';
import 'package:pisarik_guessr/screens/game/phases/results_phase.dart';

import '../../navigation/game_navigation.dart';
import '../../widgets/network_aware.dart';

class GameFlowScreen extends StatefulWidget {
  const GameFlowScreen({super.key, required this.gameId});
  final String gameId;

  @override
  State<GameFlowScreen> createState() => _GameFlowScreenState();
}

class _GameFlowScreenState extends State<GameFlowScreen> with NetworkAwareState{
  bool _isLeaving = false;

  @override
  Widget build(BuildContext context) {
    final gameService = context.read<AppState>().game;
    final userId = context.read<AppState>().user?.id;

    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Пользователь не авторизован')));
    }

    return StreamBuilder<GameSession?>(
      stream: gameService.watchGame(widget.gameId),
      builder: (context, snapshot) {
        if (_isLeaving) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final game = snapshot.data;
        if (game == null) {
          return const Scaffold(body: Center(child: Text('Игра не найдена')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(_getTitle(game)),
            actions: [
              if (game.phase == GamePhase.playing && game.pussyMode) ...[
                if (game.guesserId == userId)
                  IconButton(
                    icon: const Icon(Icons.list_alt),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => AllItemsDialog(
                        theme: game.theme!,
                        gameMode: game.gameMode!,
                        gameId: widget.gameId,
                        guesserId: userId,
                        initialGuessedItems: game.guessedItems,
                      ),
                    ),
                    tooltip: 'Таблица персонажей/предметов',
                  ),
                if (game.describerId == userId && game.currentLetter != null)
                  IconButton(
                    icon: const Icon(Icons.lightbulb),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => WordSuggestionsDialog(letter: game.currentLetter!),
                    ),
                    tooltip: 'Слова на букву',
                  ),
              ],
              IconButton(
                icon: const Icon(Icons.exit_to_app),
                onPressed: () => _confirmLeave(context, game, userId),
                tooltip: 'Выйти из игры',
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
            child: _buildPhaseWidget(game),
          ),
        );
      },
    );
  }

  String _getTitle(GameSession game) {
    switch (game.phase) {
      case GamePhase.waitingForPlayer:
        return 'Ожидание игрока';
      case GamePhase.themeSelection:
        return 'Выбор темы';
      case GamePhase.modeSelection:
        return 'Выбор режима';
      case GamePhase.roleAssignment:
        return 'Роли';
      case GamePhase.characterSelection:
        return 'Выбор персонажа / предмета';
      case GamePhase.playing:
        return game.theme?.displayName ?? 'Игра';
      case GamePhase.finished:
        return 'Результат';
    }
  }

  Widget _buildPhaseWidget(GameSession game) {
    switch (game.phase) {
      case GamePhase.waitingForPlayer:
        return WaitingPhase(game: game);
      case GamePhase.themeSelection:
        return ThemePhase(game: game, gameId: widget.gameId);
      case GamePhase.modeSelection:
        return ModeSelectionPhase(game: game, gameId: widget.gameId);
      case GamePhase.roleAssignment:
        return RolePhase(game: game, gameId: widget.gameId);
      case GamePhase.characterSelection:
        return SelectionPhase(game: game, gameId: widget.gameId);
      case GamePhase.playing:
        return PlayPhase(game: game, gameId: widget.gameId);
      case GamePhase.finished:
        return ResultsPhase(game: game, gameId: widget.gameId);
    }
  }

  Future<void> _confirmLeave(BuildContext context, GameSession game, String userId) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Выйти из игры'),
        content: const Text('Вы уверены? Игра будет завершена.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Отмена')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (shouldLeave != true) return;

    setState(() => _isLeaving = true);
    final gameService = context.read<AppState>().game;
    try {
      await gameService.leaveGame(game, userId);
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
        setState(() => _isLeaving = false);
      }
    }
  }
}