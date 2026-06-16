import 'package:flutter/material.dart';
import 'package:pisarik_guessr/utils/russian_word_loader.dart';

class WordSuggestionsDialog extends StatefulWidget {
  const WordSuggestionsDialog({super.key, required this.letter});

  final String letter;

  @override
  State<WordSuggestionsDialog> createState() => _WordSuggestionsDialogState();
}

class _WordSuggestionsDialogState extends State<WordSuggestionsDialog> with SingleTickerProviderStateMixin {
  late AnimationController _closeController;
  late Animation<double> _closeAnimation;

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
  }

  @override
  void dispose() {
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
        final words = snapshot.data ?? [];
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
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Слова на букву "${widget.letter.toUpperCase()}"',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: words.isEmpty
                        ? const Center(child: Text('Нет слов в словаре'))
                        : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2,
                      ),
                      itemCount: words.length,
                      itemBuilder: (context, index) => Card(
                        child: Center(
                          child: Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(3),
                              child: Text(words[index], textAlign: TextAlign.center),
                            ),
                          ),
                        ),
                      ),
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