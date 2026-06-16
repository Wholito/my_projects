import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pisarik_guessr/data/character_repository.dart';
import 'package:pisarik_guessr/data/item_repository.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/providers/app_state.dart';
import 'package:pisarik_guessr/utils/item_helper.dart';
import '../../../utils/item_filter.dart';
import 'letter_picker.dart';

class InputArea extends StatefulWidget {
  const InputArea({
    super.key,
    required this.game,
    required this.gameId,
    required this.isDescriber,
    required this.isGuesser,
    required this.textController,
  });

  final GameSession game;
  final String gameId;
  final bool isDescriber;
  final bool isGuesser;
  final TextEditingController textController;

  @override
  State<InputArea> createState() => _InputAreaState();
}

class _InputAreaState extends State<InputArea> {
  final TextEditingController _guessController = TextEditingController();
  final FocusNode _guessFocusNode = FocusNode();
  late List<Object> _allOptions;
  OverlayEntry? _overlayEntry;
  List<Object> _filteredOptions = [];
  final GlobalKey _textFieldKey = GlobalKey();
  BuildContext? _scaffoldContext;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    final theme = game.theme!;
    final isItemMode = game.gameMode == GameMode.items;
    _allOptions = (isItemMode ? ItemRepository.forTheme(theme) : CharacterRepository.forTheme(theme)) as List<Object>;
    _guessController.addListener(_onTextChanged);
    _guessFocusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _guessController.removeListener(_onTextChanged);
    _guessFocusNode.removeListener(_onFocusChanged);
    _guessController.dispose();
    _guessFocusNode.dispose();
    _hideOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    final query = _guessController.text;
    if (query.isEmpty) {
      _filteredOptions = [];
      _hideOverlay();
      return;
    }
    _filteredOptions = ItemFilter.filter(_allOptions, query).take(20).toList();
    if (_filteredOptions.isNotEmpty) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _onFocusChanged() {
    if (!_guessFocusNode.hasFocus) {
      _hideOverlay();
    } else if (_filteredOptions.isNotEmpty) {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _hideOverlay();
    if (!mounted) return;
    final RenderBox? renderBox = _textFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    const itemHeight = 56.0;
    final maxListHeight = itemHeight * 4;
    final listHeight = (_filteredOptions.length * itemHeight).clamp(0, maxListHeight).toDouble();

    final spaceAbove = offset.dy;
    final showAbove = spaceAbove >= listHeight + 10;
    final topPosition = showAbove ? offset.dy - listHeight - 5 : offset.dy + size.height + 5;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: topPosition,
        left: offset.dx,
        width: size.width,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: listHeight),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredOptions.length,
              itemBuilder: (context, index) {
                final option = _filteredOptions[index];
                final imagePath = ItemHelper.getImagePath(option);
                final name = ItemHelper.getName(option);
                return InkWell(
                  onTap: () async {
                    _guessController.text = name;
                    _hideOverlay();
                    await _submitGuess(name);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage(imagePath) as ImageProvider,
                          onBackgroundImageError: (_, __) {},
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(name)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _submitGuess(String guess) async {
    if (guess.trim().isEmpty) return;
    print('_submitGuess вызван с guess="$guess"');
    _guessController.clear();

    try {
      final correct = await context.read<AppState>().game.submitGuess(
        gameId: widget.gameId,
        senderId: context.read<AppState>().user!.id,
        guess: guess,
      );
      if (!correct && mounted) {
      //  ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
      //    const SnackBar(content: Text('Неверно, попробуйте ещё')),
      //  );
      }
    } catch (e, stack) {
      print('Ошибка в submitGuess: $e');
      print(stack);
      if (mounted) {
        ScaffoldMessenger.of(_scaffoldContext!).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _sendDescription(BuildContext context) async {
    final text = widget.textController.text;
    if (text.trim().isEmpty) return;
    try {
      await context.read<AppState>().game.sendDescription(
        gameId: widget.gameId,
        senderId: context.read<AppState>().user!.id,
        text: text,
      );
      widget.textController.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _scaffoldContext = context;
    final game = widget.game;
    final isDescriber = widget.isDescriber;
    final isGuesser = widget.isGuesser;

    if (isGuesser && game.currentLetter == null) {
      return LetterPicker(
        onLetterSelected: (letter) async {
          try {
            await context.read<AppState>().game.requestLetter(gameId: widget.gameId, letter: letter);
          } catch (e) {
            if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isDescriber && game.currentLetter != null)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: widget.textController,
                      decoration: InputDecoration(hintText: 'Слова на «${game.currentLetter!.toUpperCase()}»...'),
                      onSubmitted: (_) => _sendDescription(context),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: () => _sendDescription(context)),
                ],
              ),
            if (isGuesser)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: _textFieldKey,
                      controller: _guessController,
                      focusNode: _guessFocusNode,
                      decoration: InputDecoration(
                        hintText: game.gameMode == GameMode.items ? 'Угадайте предмет...' : 'Угадайте персонажа...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {
                            final text = _guessController.text;
                            if (text.isNotEmpty) _submitGuess(text);
                          },
                        ),
                      ),
                      onSubmitted: (value) => _submitGuess(value),
                    ),
                  ),
                ],
              ),
            if (isDescriber && game.currentLetter == null)
              Text('Ждём, пока угадывающий выберет букву', style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}