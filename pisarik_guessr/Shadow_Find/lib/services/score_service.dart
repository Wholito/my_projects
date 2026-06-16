import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

class ScoreService {
  static const int maxScore = 5000;

  static int calculate(LatLng real, LatLng guessed) {
    final distanceMeters = distanceBetween(real, guessed);
    final distanceKm = distanceMeters / 1000;

    if (distanceKm <= 0.1) return maxScore;

    final double decay = 1;
    final score = maxScore * math.exp(-distanceKm / decay);
    return score.round().clamp(0, maxScore);
  }

  static double distanceBetween(LatLng a, LatLng b) {
    const r = 6371000.0;
    final lat1 = _rad(a.latitude);
    final lat2 = _rad(b.latitude);
    final dLat = _rad(b.latitude - a.latitude);
    final dLng = _rad(b.longitude - a.longitude);

    final h = math.pow(math.sin(dLat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dLng / 2), 2);

    return 2 * r * math.asin(math.sqrt(h.toDouble()));
  }

  static double _rad(double deg) => deg * math.pi / 180;

  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} м';
    return '${(meters / 1000).toStringAsFixed(1)} км';
  }

  static String scoreLabel(int score) {
    if (score >= 4500) return 'Идеально!';
    if (score >= 3500) return 'Отлично!';
    if (score >= 2000) return 'Неплохо';
    if (score >= 500) return 'Далековато';
    return 'Мимо';
  }
}
