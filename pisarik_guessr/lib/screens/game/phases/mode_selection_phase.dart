import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/providers/app_state.dart';

class ModeSelectionPhase extends StatefulWidget {
  const ModeSelectionPhase({super.key, required this.game, required this.gameId});

  final GameSession game;
  final String gameId;

  @override
  State<ModeSelectionPhase> createState() => _ModeSelectionPhaseState();
}

class _ModeSelectionPhaseState extends State<ModeSelectionPhase> {
  bool _pussyMode = false;

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AppState>().user!.id;
    final isHost = userId == widget.game.hostId;
    if (!isHost) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Хост выбирает режим игры...'),
          ],
        ),
      );
    }
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Выберите режим игры',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Card(
                child: CheckboxListTile(
                  value: _pussyMode,
                  onChanged: (val) => setState(() => _pussyMode = val ?? false),
                  title: const Text('Pussy Mode'),
                  secondary: const Icon(Icons.child_care_outlined),
                ),
              ),
              const SizedBox(height: 24),
              _ModeButton(
                normalIcon: 'assets/characters/dota2/npc_dota_hero_pudge_alt1_png.png',
                pussyIcon: 'assets/characters/dota2/npc_dota_hero_pudge_persona1_png.png',
                label: 'Герои',
                baseColor: const Color(0xFFFF8C00),
                isPussyMode: _pussyMode,
                onTap: () async {
                  await context.read<AppState>().game.selectMode(widget.gameId, userId, GameMode.characters);
                  if (_pussyMode) {
                    await context.read<AppState>().game.setPussyMode(widget.gameId, true);
                  }
                },
              ),
              const SizedBox(height: 16),
              _ModeButton(
                normalIcon: 'assets/items/dota/aegis_png.png',
                pussyIcon: 'assets/items/dota/pogo_stick_png.png',
                label: 'Предметы',
                baseColor: const Color(0xFFFF4500),
                isPussyMode: _pussyMode,
                onTap: () async {
                  await context.read<AppState>().game.selectMode(widget.gameId, userId, GameMode.items);
                  if (_pussyMode) {
                    await context.read<AppState>().game.setPussyMode(widget.gameId, true);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatefulWidget {
  const _ModeButton({
    required this.normalIcon,
    required this.pussyIcon,
    required this.label,
    required this.baseColor,
    required this.isPussyMode,
    required this.onTap,
  });

  final String normalIcon;
  final String pussyIcon;
  final String label;
  final Color baseColor;
  final bool isPussyMode;
  final VoidCallback onTap;

  @override
  State<_ModeButton> createState() => _ModeButtonState();
}

class _ModeButtonState extends State<_ModeButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  Color _getButtonColor() {
    if (widget.isPussyMode) {
      return widget.baseColor;
    } else {
      return widget.baseColor.withOpacity(0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = widget.isPussyMode ? widget.pussyIcon : widget.normalIcon;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: _getButtonColor(),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(iconPath, width: 56, height: 56),
                    const SizedBox(width: 12),
                    Text(
                      widget.label,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}