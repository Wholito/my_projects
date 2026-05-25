import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:shadow_find/models/round.dart';
import 'package:shadow_find/services/cache_codec.dart';

void main() {
  final sampleRound = PhotoRound(
    id: 'round-1',
    authorUid: 'author',
    authorName: 'Аня',
    photoUrl: 'https://example.com/p.jpg',
    realLocation: const LatLng(53.9, 27.56),
    invitedUids: const ['u1', 'u2'],
    guesses: [
      Guess(
        uid: 'u1',
        displayName: 'Боб',
        guessedLocation: const LatLng(53.91, 27.57),
        distanceMeters: 1200,
        score: 3200,
        submittedAt: DateTime(2026, 1, 15, 12),
      ),
    ],
    createdAt: DateTime(2026, 1, 15, 10),
  );

  test('round json round-trip preserves data', () {
    final json = CacheCodec.roundToJson(sampleRound);
    final restored = CacheCodec.roundFromJson(json);

    expect(restored.id, sampleRound.id);
    expect(restored.authorName, 'Аня');
    expect(restored.invitedUids, ['u1', 'u2']);
    expect(restored.guesses.length, 1);
    expect(restored.guesses.first.uid, 'u1');
    expect(restored.guesses.first.score, 3200);
    expect(restored.realLocation.latitude, closeTo(53.9, 0.001));
  });

  test('guess without avatar omits null field', () {
    final json = CacheCodec.roundToJson(sampleRound);
    final guessJson = (json['guesses'] as List).first as Map<String, dynamic>;
    expect(guessJson.containsKey('avatarUrl'), isFalse);
  });
}
