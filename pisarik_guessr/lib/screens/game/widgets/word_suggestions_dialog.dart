import 'package:flutter/material.dart';
import 'package:pisarik_guessr/utils/russian_word_loader.dart';

class WordSuggestionsDialog extends StatefulWidget {
  const WordSuggestionsDialog({super.key, required this.letter});

  final String letter;

  @override
  State<WordSuggestionsDialog> createState() => _WordSuggestionsDialogState();
}

class _WordSuggestionsDialogState extends State<WordSuggestionsDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _closeController;
  late Animation<double> _closeAnimation;
  int _displayLimit = 50;
  late ScrollController _scrollController;
  static final Map<String, double> _scrollOffsets = {};
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    _closeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _closeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _closeController, curve: Curves.easeIn),
    );
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final key = 'words_${widget.letter}';
      if (_scrollController.hasClients) {
        _scrollOffsets[key] = _scrollController.offset;
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _closeController.dispose();
    super.dispose();
  }

  Future<void> _closeDialog() async {
    await _closeController.forward();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: RussianWordLoader.getWordsStartingWith(widget.letter),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final error = RussianWordLoader.lastError;
        if (error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Не удалось загрузить словарь',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          );
        }

        final words = snapshot.data ?? [];
        final displayWords = words.take(_displayLimit).toList();
        final hasMore = words.length > _displayLimit;

        if (words.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info, size: 48, color: Colors.white54),
                const SizedBox(height: 16),
                Text(
                  'Нет слов на букву "${widget.letter.toUpperCase()}"',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Закрыть'),
                ),
              ],
            ),
          );
        }

        if (!_restored && snapshot.connectionState == ConnectionState.done) {
          _restored = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final key = 'words_${widget.letter}';
            if (_scrollOffsets.containsKey(key) && _scrollController.hasClients) {
              Future.delayed(const Duration(milliseconds: 50), () {
                if (_scrollController.hasClients) {
                  final maxExtent = _scrollController.position.maxScrollExtent;
                  final target = _scrollOffsets[key]!.clamp(0.0, maxExtent);
                  _scrollController.jumpTo(target);
                }
              });
            }
          });
        }

        return AnimatedBuilder(
          animation: _closeAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _closeAnimation.value,
              child: child,
            );
          },
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Слова на букву "${widget.letter.toUpperCase()}" (${words.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: displayWords.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == displayWords.length) {
                          return TextButton(
                            onPressed: () {
                              setState(() {
                                _displayLimit += 50;
                              });
                            },
                            child: const Text('Показать ещё...'),
                          );
                        }
                        return Card(
                          child: ListTile(
                            title: Text(displayWords[index]),
                          ),
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
      },
    );
  }
}