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
            game.isFull ? 'Готовимся...' : 'Ждём второго игрока...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Отправьте приглашение другу или дождитесь его',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}