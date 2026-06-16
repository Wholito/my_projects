import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/game_navigation.dart';
import '../providers/app_state.dart';


class ActiveGameShell extends StatefulWidget {
  const ActiveGameShell({
    super.key,
    required this.userId,
    required this.child,
  });

  final String userId;
  final Widget child;

  @override
  State<ActiveGameShell> createState() => _ActiveGameShellState();
}

class _ActiveGameShellState extends State<ActiveGameShell> {
  StreamSubscription<String?>? _subscription;
  Timer? _retryTimer;
  String? _pendingGameId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _subscription ??= context
        .read<AppState>()
        .game
        .watchActiveGameId(widget.userId)
        .listen(_onActiveGameChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _retryTimer?.cancel();
    super.dispose();
  }

  void _onActiveGameChanged(String? gameId) {
    _pendingGameId = gameId;
    if (gameId == null) {
      _retryTimer?.cancel();
      return;
    }
    _tryOpenGame(gameId);
    _startRetryTimer(gameId);
  }

  void _startRetryTimer(String gameId) {
    _retryTimer?.cancel();
    _retryTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_pendingGameId != gameId) return;
      if (!GameNavigation.isGameOpen(gameId)) {
        _tryOpenGame(gameId);
      }
    });
  }

  void _tryOpenGame(String gameId) {
    if (GameNavigation.isGameOpen(gameId)) {
      _retryTimer?.cancel();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      GameNavigation.openGame(gameId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
