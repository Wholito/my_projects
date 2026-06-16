import 'package:latlong2/latlong.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_find/services/score_service.dart';

void main() {
  const minsk = LatLng(53.9, 27.5667);

  group('ScoreService.calculate', () {
    test('same point gives max score', () {
      expect(ScoreService.calculate(minsk, minsk), 5000);
    });

    test('far guess gives low score', () {
      const far = LatLng(55.75, 37.62);
      expect(ScoreService.calculate(minsk, far), lessThan(500));
    });

    test('score never exceeds max', () {
      expect(ScoreService.calculate(minsk, const LatLng(0, 0)), lessThanOrEqualTo(5000));
    });
  });

  group('ScoreService.distanceBetween', () {
    test('zero for identical coordinates', () {
      expect(ScoreService.distanceBetween(minsk, minsk), 0);
    });

    test('positive for different coordinates', () {
      expect(
        ScoreService.distanceBetween(minsk, const LatLng(53.95, 27.6)),
        greaterThan(0),
      );
    });
  });

  group('ScoreService.formatDistance', () {
    test('meters below 1 km', () {
      expect(ScoreService.formatDistance(450), '450 м');
    });

    test('kilometers at 1 km and above', () {
      expect(ScoreService.formatDistance(1500), '1.5 км');
    });
  });

  group('ScoreService.scoreLabel', () {
    test('labels by score bands', () {
      expect(ScoreService.scoreLabel(4800), 'Идеально!');
      expect(ScoreService.scoreLabel(3600), 'Отлично!');
      expect(ScoreService.scoreLabel(2500), 'Неплохо');
      expect(ScoreService.scoreLabel(800), 'Далековато');
      expect(ScoreService.scoreLabel(100), 'Мимо');
    });
  });
}
