import '../../models/game_item.dart';
import '../../models/game_theme.dart';

final List<GameItem> brawlStarsItems = [
  const GameItem(
    id: 'energy_drink',
    name: 'Энергетик',
    theme: GameTheme.brawlStars,
    imageAsset: 'assets/items/energy_drink.png',
    description: 'Увеличивает урон и скорость на короткое время',
    aliases: ['Energy Drink', 'Напиток'],
  ),
  const GameItem(
    id: 'power_cubes',
    name: 'Куб силы',
    theme: GameTheme.brawlStars,
    imageAsset: 'assets/items/power_cube.png',
    description: 'Увеличивает здоровье и урон бойца',
    aliases: ['Power Cube', 'Кубик'],
  ),
];