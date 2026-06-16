enum GameMode {
  characters,
  items;

  String get displayName => this == characters ? 'Герои' : 'Предметы';

  String get id => this == characters ? 'characters' : 'items';

  static GameMode? fromId(String? id) {
    if (id == null) return null;
    for (final mode in GameMode.values) {
      if (mode.id == id) return mode;
    }
    return null;
  }
}