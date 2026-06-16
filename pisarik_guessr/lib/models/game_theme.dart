enum GameTheme {
  brawlStars('Brawl Stars', 'brawl_stars'),
  dota2('Dota 2', 'dota2');

  const GameTheme(this.displayName, this.id);
  final String displayName;
  final String id;

  static GameTheme? fromId(String? id) {
    if (id == null) return null;
    for (final theme in GameTheme.values) {
      if (theme.id == id) return theme;
    }
    return null;
  }
}