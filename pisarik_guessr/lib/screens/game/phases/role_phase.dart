import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/providers/app_state.dart';

class RolePhase extends StatefulWidget {
  const RolePhase({super.key, required this.game, required this.gameId});

  final GameSession game;
  final String gameId;

  @override
  State<RolePhase> createState() => _RolePhaseState();
}

class _RolePhaseState extends State<RolePhase> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _swapRoles() async {
    await _rotationController.forward(from: 0.0);
    await context.read<AppState>().game.swapRoles(widget.gameId);
    await Future.delayed(const Duration(milliseconds: 300));
    _rotationController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AppState>().user!.id;
    final role = widget.game.playerRoleFor(userId);
    final isHost = userId == widget.game.hostId;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    role == PlayerRole.describer ? Icons.record_voice_over : Icons.psychology,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    role == PlayerRole.describer ? 'Вы — загадывающий' : 'Вы — угадывающий',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    role == PlayerRole.describer
                        ? 'Выберите персонажа и описывайте его словами на заданную букву'
                        : 'Задавайте букву и угадывайте персонажа',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          if (isHost) ...[
            OutlinedButton.icon(
              onPressed: _swapRoles,
              icon: RotationTransition(
                turns: _rotationController,
                child: const Icon(Icons.swap_horiz),
              ),
              label: const Text('Поменяться ролями'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.read<AppState>().game.confirmRoles(widget.gameId),
              child: const Text('Начать раунд'),
            ),
          ] else ...[
            Text(
              'Ждём, пока хост начнёт раунд',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 12),
            Text(
              'Или вернитесь на главную — появится кнопка «Вернуться в игру»',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}