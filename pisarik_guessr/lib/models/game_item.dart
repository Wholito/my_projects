import 'game_theme.dart';

class GameItem {
  const GameItem({
    required this.id,
    required this.name,
    required this.theme,
    required this.imageAsset,
    required this.description,
    this.aliases = const [],
  });

  final String id;
  final String name;
  final GameTheme theme;
  final String imageAsset;
  final String description;
  final List<String> aliases;

  bool matchesGuess(String guess) {
    final normalized = _normalize(guess);
    if (_normalize(name) == normalized) return true;
    return aliases.any((a) => _normalize(a) == normalized);
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('ё', 'е');
  }
}