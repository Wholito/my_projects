import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/data/character_repository.dart';
import 'package:pisarik_guessr/data/item_repository.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/models/game_theme.dart';
import 'package:pisarik_guessr/providers/app_state.dart';
import 'package:pisarik_guessr/utils/item_helper.dart';
import 'package:pisarik_guessr/utils/item_filter.dart';

class AllItemsDialog extends StatefulWidget {
  const AllItemsDialog({
    super.key,
    required this.theme,
    required this.gameMode,
    required this.gameId,
    required this.guesserId,
    required this.initialGuessedItems,
  });

  final GameTheme theme;
  final GameMode gameMode;
  final String gameId;
  final String guesserId;
  final List<String> initialGuessedItems;

  @override
  State<AllItemsDialog> createState() => _AllItemsDialogState();
}

class _AllItemsDialogState extends State<AllItemsDialog> with SingleTickerProviderStateMixin {
  late Set<String> _usedItems;
  late AnimationController _closeController;
  late Animation<double> _closeAnimation;
  int? _pressedIndex;
  late ScrollController _scrollController;
  static final Map<String, double> _scrollOffsets = {};

  @override
  void initState() {
    super.initState();
    _usedItems = Set.from(widget.initialGuessedItems);
    _closeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _closeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _closeController, curve: Curves.easeIn),
    );
    _scrollController = ScrollController();
    final key = '${widget.theme.id}_${widget.gameMode.id}';
    if (_scrollOffsets.containsKey(key)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollOffsets[key]!);
        }
      });
    }
  }

  @override
  void dispose() {
    final key = '${widget.theme.id}_${widget.gameMode.id}';
    if (_scrollController.hasClients) {
      _scrollOffsets[key] = _scrollController.offset;
    }
    _scrollController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  Future<void> _closeDialog() async {
    await _closeController.forward();
    if (mounted) Navigator.pop(context);
  }

  void _onItemTap(Object item, int index) async {
    final name = ItemHelper.getName(item);
    final normalized = ItemFilter.normalize(name);
    if (_usedItems.contains(normalized)) return;

    setState(() => _pressedIndex = index);
    await Future.delayed(const Duration(milliseconds: 150));

    try {
      final gameService = context.read<AppState>().game;
      final isCorrect = await gameService.submitGuess(
        gameId: widget.gameId,
        senderId: widget.guesserId,
        guess: name,
      );
      setState(() {
        _usedItems.add(normalized);
        _pressedIndex = null;
      });
      if (isCorrect && mounted) {
        await _closeDialog();
      }
    } catch (e) {
      setState(() => _pressedIndex = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Object> items = widget.gameMode == GameMode.characters
        ? CharacterRepository.forTheme(widget.theme)
        : ItemRepository.forTheme(widget.theme);

    return AnimatedBuilder(
      animation: _closeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _closeAnimation.value,
          child: child,
        );
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                '${widget.gameMode == GameMode.characters ? 'Персонажи' : 'Предметы'} (${items.length})',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: GridView.builder(
                  controller: _scrollController,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final name = ItemHelper.getName(item);
                    final normalized = ItemFilter.normalize(name);
                    final isUsed = _usedItems.contains(normalized);
                    final isPressed = _pressedIndex == index;
                    final imagePath = ItemHelper.getImagePath(item);

                    return _GridItem(
                      imagePath: imagePath,
                      isUsed: isUsed,
                      isPressed: isPressed,
                      onTap: isUsed ? null : () => _onItemTap(item, index),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _closeDialog,
                child: const Text('Закрыть'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridItem extends StatelessWidget {
  const _GridItem({
    required this.imagePath,
    required this.isUsed,
    required this.isPressed,
    required this.onTap,
  });

  final String imagePath;
  final bool isUsed;
  final bool isPressed;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(isPressed ? 0.9 : 1.0),
      child: Card(
        color: isUsed ? Colors.grey.shade800 : null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: isUsed ? 0.4 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Image.asset(
                  imagePath,
                  height: 60,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.image,
                    color: isUsed ? Colors.grey.shade800 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}