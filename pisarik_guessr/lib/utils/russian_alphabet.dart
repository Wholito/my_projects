const allowedRussianLetters = [
  'а', 'б', 'в', 'г', 'д', 'е', 'ё', 'ж', 'з', 'и', 'й',
  'к', 'л', 'м', 'н', 'о', 'п', 'р', 'с', 'т', 'у', 'ф',
  'х', 'ц', 'ч', 'ш', 'щ', 'э', 'ю', 'я'
];

bool isAllowedLetter(String letter) {
  return allowedRussianLetters.contains(letter.trim().toLowerCase());
}

bool textStartsWithLetter(String text, String letter) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return false;
  final normalizedLetter = letter.trim().toLowerCase().replaceAll('ё', 'е');
  return words.every((word) {
    if (word.isEmpty) return false;
    final firstChar = word[0].toLowerCase().replaceAll('ё', 'е');
    return firstChar == normalizedLetter;
  });
}

int countWords(String text) {
  return text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
}