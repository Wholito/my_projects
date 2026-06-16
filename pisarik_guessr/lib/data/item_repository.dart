import '../models/game_item.dart';
import '../models/game_theme.dart';
import 'items/dota2_items.dart';

class ItemRepository {
  static List<GameItem> forTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.brawlStars:
        return [];
      case GameTheme.dota2:
        return dota2Items;
    }
  }

  static GameItem? findById(String? id) {
    if (id == null) return null;
    for (final item in dota2Items) {
      if (item.id == id) return item;
    }
    return null;
  }

  static GameItem? findByGuess(String guess, GameTheme theme) {
    final normalizedGuess = _normalize(guess);
    for (final item in forTheme(theme)) {
      if (_normalize(item.name) == normalizedGuess) return item;
      if (item.aliases.any((a) => _normalize(a) == normalizedGuess)) return item;
    }
    return null;
  }

  static String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll('ё', 'е');
  }
}