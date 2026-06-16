import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum NetworkStatus {
  connected,
  disconnected,
}

class NetworkService extends ChangeNotifier {
  NetworkService() {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  Timer? _pingTimer;
  NetworkStatus _status = NetworkStatus.connected;
  NetworkStatus get status => _status;

  final _statusController = StreamController<NetworkStatus>.broadcast();
  Stream<NetworkStatus> get onStatusChange => _statusController.stream;

  void _init() {
    Future.delayed(const Duration(seconds: 1), () {
      _checkConnectivityAndPing();
    });
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((_) {
      _checkConnectivityAndPing();
    });
    _pingTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnectivityAndPing();
    });
  }

  Future<void> _checkConnectivityAndPing() async {
    final results = await _connectivity.checkConnectivity();
    final hasInterface = results.any((r) => r != ConnectivityResult.none);

    if (!hasInterface) {
      _setStatus(NetworkStatus.disconnected);
      return;
    }

    final hasInternet = await _hasRealInternet();
    _setStatus(hasInternet ? NetworkStatus.connected : NetworkStatus.disconnected);
  }

  Future<bool> _hasRealInternet() async {
    try {
      final response = await http.head(
        Uri.parse('https://www.google.com'),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  void _setStatus(NetworkStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
      _statusController.add(newStatus);
      debugPrint('Network status changed to: ${newStatus.name}');
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _pingTimer?.cancel();
    _statusController.close();
    super.dispose();
  }
}