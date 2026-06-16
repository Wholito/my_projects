import 'package:flutter_test/flutter_test.dart';

import 'package:pisarik_guessr/utils/russian_alphabet.dart';

void main() {
  test('allowed letters exclude soft hard signs and y', () {
    expect(isAllowedLetter('а'), isTrue);
    expect(isAllowedLetter('ь'), isFalse);
    expect(isAllowedLetter('ъ'), isFalse);
    expect(isAllowedLetter('ы'), isFalse);
  });

  test('text must start with letter for all words', () {
    expect(textStartsWithLetter('красный колпак', 'к'), isTrue);
    expect(textStartsWithLetter('красный шар', 'к'), isFalse);
  });
}
