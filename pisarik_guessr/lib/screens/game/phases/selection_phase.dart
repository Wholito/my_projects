import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/data/character_repository.dart';
import 'package:pisarik_guessr/data/item_repository.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/providers/app_state.dart';
import 'package:pisarik_guessr/utils/item_helper.dart';
import 'package:pisarik_guessr/utils/item_filter.dart';

class SelectionPhase extends StatefulWidget {
  const SelectionPhase({super.key, required this.game, required this.gameId});

  final GameSession game;
  final String gameId;

  @override
  State<SelectionPhase> createState() => _SelectionPhaseState();
}

class _SelectionPhaseState extends State<SelectionPhase> with SingleTickerProviderStateMixin {
  int? _animatedIndex;
  final Random _random = Random();
  final TextEditingController _searchController = TextEditingController();
  List<Object> _allItems = [];
  List<Object> _filteredItems = [];
  bool _isItemMode = false;
  Timer? _debounceTimer;

  late AnimationController _shuffleController;
  late Animation<double> _shuffleRotation;

  @override
  void initState() {
    super.initState();
    final theme = widget.game.theme!;
    _isItemMode = widget.game.gameMode == GameMode.items;
    _allItems = (_isItemMode
        ? ItemRepository.forTheme(theme)
        : CharacterRepository.forTheme(theme)) as List<Object>;
    _filteredItems = List.from(_allItems);
    _searchController.addListener(_onSearchChanged);

    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shuffleRotation = Tween<double>(begin: 0, end: 2 * pi).animate(
      CurvedAnimation(parent: _shuffleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _shuffleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final query = _searchController.text;
      setState(() {
        _filteredItems = ItemFilter.filter(_allItems, query);
      });
    });
  }

  Future<void> _selectItem(Object item) async {
    final id = ItemHelper.getId(item);
    if (_isItemMode) {
      await context.read<AppState>().game.selectItem(gameId: widget.gameId, itemId: id);
    } else {
      await context.read<AppState>().game.selectCharacter(gameId: widget.gameId, characterId: id);
    }
  }

  void _selectRandom() async {
    final userId = context.read<AppState>().user!.id;
    final isDescriber = widget.game.describerId == userId;
    if (!isDescriber) return;
    if (_filteredItems.isEmpty) return;

    await _shuffleController.forward(from: 0.0);

    final randomIndex = _random.nextInt(_filteredItems.length);
    final item = _filteredItems[randomIndex];
    setState(() => _animatedIndex = randomIndex);

    await Future.delayed(const Duration(milliseconds: 400));
    await _selectItem(item);
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() => _animatedIndex = null);
    _shuffleController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AppState>().user!.id;
    final isDescriber = widget.game.describerId == userId;

    if (!isDescriber) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.visibility_off, size: 64, color: Colors.white.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              _isItemMode ? 'Загадывающий выбирает предмет...' : 'Загадывающий выбирает персонажа...',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: _SearchField(controller: _searchController),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: ListView.builder(
                  key: ValueKey(_filteredItems.length),
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    return _ListItem(
                      item: item,
                      isSelected: _animatedIndex == index,
                      onTap: () async {
                        setState(() => _animatedIndex = index);
                        await Future.delayed(const Duration(milliseconds: 150));
                        await _selectItem(item);
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _selectRandom,
            child: AnimatedBuilder(
              animation: _shuffleRotation,
              builder: (context, child) => Transform.rotate(
                angle: _shuffleRotation.value,
                child: child,
              ),
              child: const Icon(Icons.shuffle),
            ),
            tooltip: 'Случайный выбор',
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).inputDecorationTheme.fillColor,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Поиск...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              controller.clear();
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final Object item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = ItemHelper.getName(item);
    final imagePath = ItemHelper.getImagePath(item);

    return AnimatedScale(
      scale: isSelected ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: AssetImage(imagePath) as ImageProvider,
            onBackgroundImageError: (_, __) {},
          ),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
            ),
            child: Text(name),
          ),
          trailing: AnimatedRotation(
            turns: isSelected ? 0.1 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Icon(Icons.chevron_right),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}