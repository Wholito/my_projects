import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/round.dart';
import '../../services/score_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/fade_slide_in.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ResultScreen extends StatelessWidget {
  final PhotoRound round;
  final LatLng? myGuessLocation;
  final double? myDistance;
  final int? myScore;

  const ResultScreen({
    super.key,
    required this.round,
    this.myGuessLocation,
    this.myDistance,
    this.myScore,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = round.sortedGuesses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Результаты'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.home),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: round.realLocation,
                  initialZoom: _autoZoom(),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.wholito.shadow_find',
                  ),
                  PolylineLayer(
                    polylines: round.guesses.map((g) {
                      return Polyline(
                        points: [g.guessedLocation, round.realLocation],
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.55),
                        strokeWidth: 1.5,
                        isDotted: true,
                      );
                    }).toList(),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: round.realLocation,
                        width: 44,
                        height: 44,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.green,
                          size: 44,
                        ),
                      ),
                      ...round.guesses.map(
                            (g) => Marker(
                          point: g.guessedLocation,
                          width: 32,
                          height: 32,
                          child: Tooltip(
                            message: '${g.displayName}: ${g.score} очков',
                            child: Icon(
                              Icons.circle,
                              color: Theme.of(context).colorScheme.primary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (myScore != null)
              FadeSlideIn(
                child: _MyScoreCard(
                  score: myScore!,
                  distance: myDistance!,
                ),
              ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Результаты раунда',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            if (sorted.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Никто ещё не угадывал',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ...sorted.asMap().entries.map(
                    (e) => FadeSlideIn(
                      delay: Duration(milliseconds: 70 * e.key),
                      child: _LeaderboardTile(
                        rank: e.key + 1,
                        guess: e.value,
                      ),
                    ),
                  ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  double _autoZoom() {
    if (myDistance == null) return 11.0;
    final km = myDistance! / 1000;
    if (km < 0.5) return 15;
    if (km < 2) return 13;
    if (km < 10) return 11;
    return 9;
  }
}

class _MyScoreCard extends StatelessWidget {
  final int score;
  final double distance;

  const _MyScoreCard({required this.score, required this.distance});

  @override
  Widget build(BuildContext context) {
    final label = ScoreService.scoreLabel(score);
    final dist = ScoreService.formatDistance(distance);
    final color = _scoreColor(score);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'Расстояние', value: dist),
              Column(
                children: [
                  AnimatedCount(
                    value: score,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    'Очки',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(int s) => AppTheme.scoreColor(s);
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final Guess guess;

  const _LeaderboardTile({required this.rank, required this.guess});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _medalIcon(rank),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundImage: guess.avatarUrl != null && guess.avatarUrl!.isNotEmpty
                ? CachedNetworkImageProvider(guess.avatarUrl!)
                : null,
            child: guess.avatarUrl == null || guess.avatarUrl!.isEmpty
                ? Text(guess.displayName[0].toUpperCase(),
                style: const TextStyle(fontSize: 12))
                : null,
          ),
        ],
      ),
      title: Text(guess.displayName),
      subtitle: Text(guess.formattedDistance),
      trailing: Text('${guess.score}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );


  }
  Widget _medalIcon(int rank) {
    if (rank == 1) return const Icon(Icons.emoji_events, color: Colors.amber, size: 30);
    if (rank == 2) return Icon(Icons.emoji_events, color: Colors.grey[400], size: 30);
    if (rank == 3) return const Icon(Icons.emoji_events, color: Colors.brown, size: 30);
    return Text('$rank.', style: const TextStyle(fontSize: 22));
  }
}