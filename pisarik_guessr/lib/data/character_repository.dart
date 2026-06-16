import '../models/character.dart';
import '../models/game_theme.dart';
import 'characters/brawl_stars.dart';
import 'characters/dota2.dart';

class CharacterRepository {
  static List<GameCharacter> forTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.brawlStars:
        return brawlStarsCharacters;
      case GameTheme.dota2:
        return dota2Characters;
    }
  }

  static GameCharacter? findById(String? id) {
    if (id == null) return null;
    for (final c in [...brawlStarsCharacters, ...dota2Characters]) {
      if (c.id == id) return c;
    }
    return null;
  }
}