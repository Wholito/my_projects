import 'package:flutter/material.dart';
import 'package:pisarik_guessr/models/game_session.dart';

class WaitingPhase extends StatelessWidget {
  const WaitingPhase({super.key, required this.game});

  final GameSession game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            game.isFull ? 'Готовимся...' : 'Дождитесь друга',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              game.isFull ? '' : 'Игра начнётся, когда друг присоединится',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}