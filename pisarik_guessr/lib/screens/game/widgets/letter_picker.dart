import 'package:flutter/material.dart';
import 'package:pisarik_guessr/utils/russian_alphabet.dart';

class LetterPicker extends StatelessWidget {
  const LetterPicker({super.key, required this.onLetterSelected});

  final ValueChanged<String> onLetterSelected;

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
                  icon: const Icon(Icons.shuffle),
                  onPressed: () {
                    final randomLetter = allowedRussianLetters[DateTime.now().millisecondsSinceEpoch % allowedRussianLetters.length];
                    onLetterSelected(randomLetter);
                  },
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
                  onPressed: () => onLetterSelected(letter),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}