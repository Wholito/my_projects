import 'package:pisarik_guessr/models/character.dart';
import 'package:pisarik_guessr/models/game_item.dart';
import 'package:pisarik_guessr/models/game_session.dart';
import 'package:pisarik_guessr/models/game_mode.dart';
import 'package:pisarik_guessr/data/character_repository.dart';
import 'package:pisarik_guessr/data/item_repository.dart';

class ItemHelper {
  static String getName(Object item) {
    if (item is GameCharacter) return item.name;
    if (item is GameItem) return item.name;
    return '';
  }

  static List<String> getAliases(Object item) {
    if (item is GameCharacter) return item.aliases;
    if (item is GameItem) return item.aliases;
    return [];
  }

  static String getImagePath(Object item) {
    if (item is GameCharacter) return item.imageAsset;
    if (item is GameItem) return item.imageAsset;
    return '';
  }

  static String getId(Object item) {
    if (item is GameCharacter) return item.id;
    if (item is GameItem) return item.id;
    return '';
  }

  static dynamic getSelectedObject(GameSession game) {
    if (game.characterId == null) return null;
    return game.gameMode == GameMode.items
        ? ItemRepository.findById(game.characterId)
        : CharacterRepository.findById(game.characterId);
  }
}