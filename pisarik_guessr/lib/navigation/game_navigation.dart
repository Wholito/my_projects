import 'package:flutter/material.dart';

import '../screens/game/game_flow_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

class GameNavigation {
  static String? _openGameId;

  static bool isGameOpen(String gameId) => _openGameId == gameId;

  static Future<void> openGame(String gameId) async {
    if (isGameOpen(gameId)) return;

    final navigator = rootNavigatorKey.currentState;
    if (navigator == null) return;

    _openGameId = gameId;
    try {
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => GameFlowScreen(gameId: gameId),
          settings: RouteSettings(name: '/game/$gameId'),
        ),
      );
    } finally {
      if (_openGameId == gameId) {
        _openGameId = null;
      }
    }
  }
  static void reset(String gameId) {
    if (_openGameId == gameId) {
      _openGameId = null;
    }
  }
}
