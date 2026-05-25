String friendsCount(int count) {
  final n = count.abs();
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 14) return '$n друзей';
  if (mod10 == 1) return '$n друг';
  if (mod10 >= 2 && mod10 <= 4) return '$n друга';
  return '$n друзей';
}

String sentToFriendsMessage(int count) {
  if (count <= 0) return 'Никому не отправлено';
  return 'Отправлено ${friendsCount(count)}';
}

String scoreLabel(int score) {
  final n = score.abs();
  final mod10 = n % 10;
  final mod100 = n % 100;
  if (mod100 >= 11 && mod100 <= 14) return '$n очков';
  if (mod10 == 1) return '$n очко';
  if (mod10 >= 2 && mod10 <= 4) return '$n очка';
  return '$n очков';
}

String photoFromAuthor(String name) => 'Снимок от $name';

String roundFromAuthor(String name) => 'Раунд от $name';
