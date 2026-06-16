import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../../models/app_user.dart';
import '../../providers/app_providers.dart';
import '../../services/firebase_service.dart';
import '../../utils/permissions_helper.dart';
import '../../utils/russian_text.dart';
import '../../widgets/fade_slide_in.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  File? _capturedPhoto;
  LatLng? _currentLocation;
  bool _locating = false;
  bool _sending = false;
  String? _error;
  bool _cameraReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _prepareCamera();
    _loadLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      controller.setFlashMode(FlashMode.off).catchError((_) {});
    }
    controller?.dispose();
    super.dispose();
  }

  Future<void> _prepareCamera() async {
    final granted = await PermissionsHelper.ensureCamera();
    if (!granted) {
      if (mounted) setState(() => _error = 'Нет доступа к камере');
      return;
    }
    _cameras = await availableCameras();
    if (_cameras.isEmpty) {
      if (mounted) setState(() => _error = 'Камера не найдена');
      return;
    }
    _controller = CameraController(
      _cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
    try {
      await _controller!.setFlashMode(FlashMode.off);
    } catch (_) {}
    if (mounted) setState(() => _cameraReady = true);
  }

  Future<void> _loadLocation() async {
    setState(() => _locating = true);
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _error = 'Нет доступа к геолокации — без неё нельзя отправить снимок';
            _locating = false;
          });
        }
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
        _locating = false;
        if (_error != null && _error!.contains('Ошибка геолокации')) {
          _error = null;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось определить местоположение';
          _locating = false;
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final file = await _controller!.takePicture();
      if (mounted) setState(() => _capturedPhoto = File(file.path));
    } catch (e) {
      if (mounted) setState(() => _error = 'Не удалось сделать снимок');
    }
  }

  Future<void> _sendToFriends() async {
    if (_capturedPhoto == null || _currentLocation == null) return;

    final friends = context.read<FriendsProvider>().friends;
    if (friends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала добавь друзей на вкладке «Друзья»'),
        ),
      );
      return;
    }

    final selected = await _showFriendPicker(friends);
    if (selected == null || selected.isEmpty) return;

    setState(() => _sending = true);
    try {
      await firebaseService.createRound(
        photoFile: _capturedPhoto!,
        location: _currentLocation!,
        invitedUids: selected.map((f) => f.uid).toList(),
      );
      if (mounted) {
        setState(() {
          _capturedPhoto = null;
          _sending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(sentToFriendsMessage(selected.length))),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Не удалось отправить снимок';
        _sending = false;
      });
    }
  }

  Future<List<AppUser>?> _showFriendPicker(List<AppUser> friends) async {
    final selected = <String>{};

    return showModalBottomSheet<List<AppUser>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Кому отправить снимок?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...friends.map((f) => CheckboxListTile(
                  value: selected.contains(f.uid),
                  onChanged: (v) => setModalState(() {
                    if (v == true) {
                      selected.add(f.uid);
                    } else {
                      selected.remove(f.uid);
                    }
                  }),
                  title: Text(f.displayName),
                  subtitle: Text(f.friendCode),
                  secondary: CircleAvatar(
                    backgroundImage: f.avatarUrl != null && f.avatarUrl!.isNotEmpty
                        ? CachedNetworkImageProvider(f.avatarUrl!)
                        : null,
                    child: f.avatarUrl == null || f.avatarUrl!.isEmpty
                        ? Text(f.displayName[0].toUpperCase())
                        : null,
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(
                            ctx,
                            friends
                                .where((f) => selected.contains(f.uid))
                                .toList(),
                          ),
                  child: Text(
                    selected.isEmpty
                        ? 'Выбери друзей'
                        : 'Отправить ${friendsCount(selected.length)}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_capturedPhoto != null) {
      return FadeSlideIn(
        child: _PhotoPreview(
          photo: _capturedPhoto!,
          location: _currentLocation,
          sending: _sending,
          onRetake: () => setState(() => _capturedPhoto = null),
          onSend: _sendToFriends,
          onRetryLocation: _loadLocation,
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_cameraReady &&
              _controller != null &&
              _controller!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: _LocationBadge(
              location: _currentLocation,
              loading: _locating,
              onRefresh: _loadLocation,
            ),
          ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePicture,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          if (_error != null)
            Positioned(
              bottom: 140,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.orange),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LocationBadge extends StatelessWidget {
  final LatLng? location;
  final bool loading;
  final VoidCallback onRefresh;

  const _LocationBadge({
    required this.location,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: loading ? null : onRefresh,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.white,
                  ),
                )
              else
                Icon(
                  location != null ? Icons.location_on : Icons.location_off,
                  color: location != null ? Colors.green : Colors.orange,
                  size: 16,
                ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  loading
                      ? 'Определяем местоположение...'
                      : location != null
                          ? '${location!.latitude.toStringAsFixed(4)}, ${location!.longitude.toStringAsFixed(4)}'
                          : 'Нажми, чтобы обновить геолокацию',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final File photo;
  final LatLng? location;
  final bool sending;
  final VoidCallback onRetake;
  final VoidCallback onSend;
  final VoidCallback onRetryLocation;

  const _PhotoPreview({
    required this.photo,
    required this.location,
    required this.sending,
    required this.onRetake,
    required this.onSend,
    required this.onRetryLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.file(photo, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Column(
              children: [
                if (location == null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        const Text(
                          'Геолокация не определена — отправить нельзя',
                          style: TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: onRetryLocation,
                          child: const Text('Обновить геолокацию'),
                        ),
                      ],
                    ),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRetake,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                        child: const Text('Переснять'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: (sending || location == null) ? null : onSend,
                        child: sending
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Отправить'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
