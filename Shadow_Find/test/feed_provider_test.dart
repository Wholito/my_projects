import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shadow_find/models/round.dart';
import 'package:shadow_find/providers/app_providers.dart';

PhotoRound _round(String id, {List<Guess> guesses = const []}) {
  return PhotoRound(
    id: id,
    authorUid: 'a',
    authorName: 'Author',
    photoUrl: 'url',
    realLocation: const LatLng(1, 1),
    invitedUids: const ['me'],
    guesses: guesses,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('FeedProvider', () {
    test('splits pending and guessed rounds', () {
      final provider = FeedProvider();
      provider.setRounds([
        _round('r1'),
        _round('r2', guesses: [
          Guess(
            uid: 'me',
            displayName: 'Me',
            guessedLocation: const LatLng(2, 2),
            distanceMeters: 100,
            score: 4000,
            submittedAt: DateTime(2026, 1, 2),
          ),
        ]),
      ]);

      expect(provider.pendingGuessFor('me').map((r) => r.id), ['r1']);
      expect(provider.guessedBy('me').map((r) => r.id), ['r2']);
    });

    test('upsertRound updates existing entry', () {
      final provider = FeedProvider();
      provider.setRounds([_round('r1')]);

      final updated = _round('r1', guesses: [
        Guess(
          uid: 'me',
          displayName: 'Me',
          guessedLocation: const LatLng(2, 2),
          distanceMeters: 50,
          score: 4900,
          submittedAt: DateTime(2026, 1, 3),
        ),
      ]);
      provider.upsertRound(updated);

      expect(provider.rounds.single.guesses.length, 1);
      expect(provider.guessedBy('me').length, 1);
      expect(provider.pendingGuessFor('me'), isEmpty);
    });
  });
}
