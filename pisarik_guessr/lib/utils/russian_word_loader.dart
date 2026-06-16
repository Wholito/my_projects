import 'package:flutter/services.dart';

class RussianWordLoader {
  static List<String>? _words;
  static final Map<String, List<String>> _wordsByLetter = {};

  static Future<List<String>> getWords() async {
    if (_words != null) return _words!;
    final data = await rootBundle.loadString('assets/russian_words.txt');
    _words = data.split('\n').where((w) => w.trim().isNotEmpty).toList();
    return _words!;
  }

  static Future<List<String>> getWordsStartingWith(String letter) async {
    final normalized = letter.trim().toLowerCase().replaceAll('ё', 'е');
    if (_wordsByLetter.containsKey(normalized)) {
      return _wordsByLetter[normalized]!;
    }
    final all = await getWords();
    final filtered = all.where((w) => w.startsWith(normalized)).toList();
    _wordsByLetter[normalized] = filtered;
    return filtered;
  }
}