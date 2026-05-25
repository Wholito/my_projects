import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../models/round.dart';
import '../../providers/app_providers.dart';
import '../../services/firebase_service.dart';
import '../../services/score_service.dart';
import '../../utils/russian_text.dart';
import '../../widgets/fade_slide_in.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final PhotoRound round;

  const GameScreen({super.key, required this.round});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  LatLng? _pin;
  bool _mapExpanded = false;
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PhotoRound>(
      stream: firebaseService.watchRound(widget.round.id),
      initialData: widget.round,
      builder: (context, snapshot) {
        final round = snapshot.data ?? widget.round;
        return _GameBody(
          round: round,
          pin: _pin,
          mapExpanded: _mapExpanded,
          mapController: _mapController,
          onPinSet: (point) => setState(() => _pin = point),
          onToggleMap: () => setState(() => _mapExpanded = !_mapExpanded),
        );
      },
    );
  }
}

class _GameBody extends StatelessWidget {
  final PhotoRound round;
  final LatLng? pin;
  final bool mapExpanded;
  final MapController mapController;
  final ValueChanged<LatLng> onPinSet;
  final VoidCallback onToggleMap;

  const _GameBody({
    required this.round,
    required this.pin,
    required this.mapExpanded,
    required this.mapController,
    required this.onPinSet,
    required this.onToggleMap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final game = context.watch<GameProvider>();
    final uid = auth.user?.uid ?? '';
    final alreadyGuessed = round.hasGuessedBy(uid);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: mapExpanded ? 0 : 5,
            child: mapExpanded
                ? const SizedBox.shrink()
                : Stack(
                    children: [
                      Positioned.fill(
                        child: Image.network(
                          round.photoUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (_, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Не удалось загрузить фото',
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        left: 12,
                        child: IconButton.filled(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 8,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            roundFromAuthor(round.authorName),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          Expanded(
            flex: mapExpanded ? 10 : 4,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: const LatLng(53.9, 27.5667),
                    initialZoom: 11,
                    onTap: alreadyGuessed
                        ? null
                        : (_, point) => onPinSet(point),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.wholito.shadow_find',
                    ),
                    if (pin != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: pin!,
                            width: 40,
                            height: 40,
                            child: _PinDrop(
                              key: ValueKey(
                                '${pin!.latitude}_${pin!.longitude}',
                              ),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filled(
                    onPressed: onToggleMap,
                    icon: Icon(
                      mapExpanded ? Icons.fullscreen_exit : Icons.fullscreen,
                    ),
                    style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                ),
                if (pin == null && !alreadyGuessed)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: AnimatedOpacity(
                      opacity: pin == null ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Center(child: _MapHint()),
                    ),
                  ),
              ],
            ),
          ),
          if (!alreadyGuessed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (pin == null || game.submitting)
                      ? null
                      : () => _submit(context, round, pin!),
                  icon: game.submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  label: const Text('Подтвердить'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: FilledButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  fadeSlideRoute(ResultScreen(round: round)),
                ),
                icon: const Icon(Icons.leaderboard),
                label: const Text('Смотреть результаты'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    PhotoRound round,
    LatLng pin,
  ) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final game = context.read<GameProvider>();
    final ok = await game.submitGuess(
      roundId: round.id,
      lat: pin.latitude,
      lng: pin.longitude,
      displayName: auth.user!.displayName,
      avatarUrl: auth.user!.avatarUrl,
    );

    if (!context.mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(game.error ?? 'Не удалось отправить ответ')),
      );
      return;
    }

    final fresh = await firebaseService.fetchRound(round.id);
    if (context.mounted && fresh != null) {
      context.read<FeedProvider>().upsertRound(fresh);
    }

    final resultRound = fresh ?? round;

    final distance = ScoreService.distanceBetween(resultRound.realLocation, pin);
    final score = ScoreService.calculate(resultRound.realLocation, pin);

    if (!context.mounted) return;

    Navigator.pushReplacement(
      context,
      fadeSlideRoute(
        ResultScreen(
          round: resultRound,
          myGuessLocation: pin,
          myDistance: distance,
          myScore: score,
        ),
      ),
    );
  }
}

class _MapHint extends StatelessWidget {
  const _MapHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Нажми на карту и поставь метку',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class _PinDrop extends StatefulWidget {
  final Color color;

  const _PinDrop({super.key, required this.color});

  @override
  State<_PinDrop> createState() => _PinDropState();
}

class _PinDropState extends State<_PinDrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _scale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Icon(Icons.location_pin, color: widget.color, size: 40),
    );
  }
}
