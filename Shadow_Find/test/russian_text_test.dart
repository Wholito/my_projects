import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_find/utils/russian_text.dart';

void main() {
  group('friendsCount', () {
    test('singular', () => expect(friendsCount(1), '1 друг'));
    test('few', () => expect(friendsCount(3), '3 друга'));
    test('many', () => expect(friendsCount(5), '5 друзей'));
    test('11-14 use many form', () => expect(friendsCount(12), '12 друзей'));
  });

  group('sentToFriendsMessage', () {
    test('zero', () => expect(sentToFriendsMessage(0), 'Никому не отправлено'));
    test('one friend', () => expect(sentToFriendsMessage(1), 'Отправлено 1 друг'));
  });

  group('scoreLabel', () {
    test('one point', () => expect(scoreLabel(1), '1 очко'));
    test('few points', () => expect(scoreLabel(3), '3 очка'));
    test('many points', () => expect(scoreLabel(10), '10 очков'));
  });
}
