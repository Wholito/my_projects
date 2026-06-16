import 'package:flutter/material.dart';
import 'package:pisarik_guessr/data/character_repository.dart';
import 'package:pisarik_guessr/data/item_repository.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:provider/provider.dart';
import '../../../models/character.dart';
import '../../../models/game_item.dart';
import '../../../providers/app_state.dart';

class ResultsPhase extends StatefulWidget {
  const ResultsPhase({super.key, required this.game, required this.gameId});

  final GameSession game;
  final String gameId;

  @override
  State<ResultsPhase> createState() => _ResultsPhaseState();
}

class _ResultsPhaseState extends State<ResultsPhase> with SingleTickerProviderStateMixin {
  late AnimationController _trophyController;
  late Animation<double> _trophyScale;

  @override
  void initState() {
    super.initState();
    _trophyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _trophyScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _trophyController, curve: Curves.elasticOut),
    );
    _trophyController.forward();
  }

  @override
  void dispose() {
    _trophyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final won = widget.game.winnerId == context.read<AppState>().user!.id;

    final isItemMode = widget.game.gameMode == GameMode.items;
    final selectedItem = isItemMode ? ItemRepository.findById(widget.game.characterId) : null;
    final selectedCharacter = !isItemMode ? CharacterRepository.findById(widget.game.characterId) : null;

    final displayName = isItemMode
        ? (selectedItem as GameItem?)?.name ?? 'Не выбран'
        : (selectedCharacter as GameCharacter?)?.name ?? 'Не выбран';

    final imageAsset = isItemMode
        ? (selectedItem as GameItem?)?.imageAsset
        : (selectedCharacter as GameCharacter?)?.imageAsset;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedBuilder(
              animation: _trophyScale,
              builder: (context, child) {
                return Transform.scale(
                  scale: _trophyScale.value,
                  child: child,
                );
              },
              child: Icon(
                Icons.emoji_events,
                size: 72,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              won ? 'Победа!' : 'Раунд завершён',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (imageAsset != null)
                      Image.asset(
                        imageAsset,
                        height: 100,
                        errorBuilder: (_, __, ___) => Image.asset('assets/icon/icon.png', scale: 3),
                      )
                    else
                      Image.asset('assets/icon/icon.png', height: 100),
                    const SizedBox(height: 12),
                    Text(
                      '${isItemMode ? 'Предмет' : 'Персонаж'}: $displayName',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Слов загадывающего: '),
                            TweenAnimationBuilder<int>(
                              duration: const Duration(milliseconds: 800),
                              tween: IntTween(begin: 0, end: widget.game.wordCount),
                              builder: (_, value, __) => Text(
                                '$value',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Попыток угадывающего: '),
                            TweenAnimationBuilder<int>(
                              duration: const Duration(milliseconds: 800),
                              tween: IntTween(begin: 0, end: widget.game.guessCount),
                              builder: (_, value, __) => Text(
                                '$value',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}