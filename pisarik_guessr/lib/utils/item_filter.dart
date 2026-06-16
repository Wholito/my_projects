import 'item_helper.dart';

class ItemFilter {
  static String normalize(String s) {
    return s.trim().toLowerCase().replaceAll('ё', 'е');
  }

  static bool matches(Object item, String query) {
    final normalizedQuery = normalize(query);
    if (normalizedQuery.isEmpty) return true;
    final name = normalize(ItemHelper.getName(item));
    if (name.contains(normalizedQuery)) return true;
    final aliases = ItemHelper.getAliases(item).map(normalize);
    return aliases.any((alias) => alias.contains(normalizedQuery));
  }

  static List<Object> filter(List<Object> items, String query) {
    if (query.isEmpty) return List.from(items);
    return items.where((item) => matches(item, query)).toList();
  }
}