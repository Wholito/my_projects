import 'package:flutter/material.dart';
import 'package:pisarik_guessr/utils/russian_alphabet.dart';

class LetterPicker extends StatefulWidget {
  const LetterPicker({super.key, required this.onLetterSelected});

  final ValueChanged<String> onLetterSelected;

  @override
  State<LetterPicker> createState() => _LetterPickerState();
}

class _LetterPickerState extends State<LetterPicker> with SingleTickerProviderStateMixin {
  late AnimationController _shuffleController;
  late Animation<double> _shuffleRotation;

  @override
  void initState() {
    super.initState();
    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _shuffleRotation = Tween<double>(begin: 0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _shuffleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _shuffleController.dispose();
    super.dispose();
  }

  void _onRandomPressed() {
    _shuffleController.forward(from: 0.0);
    final randomLetter = allowedRussianLetters[DateTime.now().millisecondsSinceEpoch % allowedRussianLetters.length];
    widget.onLetterSelected(randomLetter);
    Future.delayed(const Duration(milliseconds: 600), () {
      _shuffleController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Выберите букву', style: Theme.of(context).textTheme.titleSmall),
                IconButton(
                  icon: AnimatedBuilder(
                    animation: _shuffleRotation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _shuffleRotation.value,
                        child: const Icon(Icons.shuffle),
                      );
                    },
                  ),
                  onPressed: _onRandomPressed,
                  tooltip: 'Случайная буква',
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: allowedRussianLetters.map((letter) {
                return ActionChip(
                  label: Text(letter.toUpperCase()),
                  onPressed: () => widget.onLetterSelected(letter),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}