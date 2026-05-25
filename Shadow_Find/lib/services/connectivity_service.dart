import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum NetworkStatus { checking, online, offline, slow }

final connectivityService = ConnectivityService();

class ConnectivityService extends ChangeNotifier {
  NetworkStatus _status = NetworkStatus.checking;
  Timer? _timer;
  bool _refreshing = false;

  static const _probeUrl = 'https://www.google.com/generate_204';
  static const _timeout = Duration(seconds: 5);
  static const _slowThresholdMs = 2800;

  NetworkStatus get status => _status;
  bool get isChecking => _status == NetworkStatus.checking || _refreshing;
  bool get isOnline => _status == NetworkStatus.online;
  bool get needsRetry =>
      _status == NetworkStatus.offline || _status == NetworkStatus.slow;

  String get statusMessage {
    switch (_status) {
      case NetworkStatus.checking:
        return 'Проверяем интернет…';
      case NetworkStatus.online:
        return '';
      case NetworkStatus.offline:
        return 'Нет подключения к интернету';
      case NetworkStatus.slow:
        return 'Интернет слишком медленный';
    }
  }

  void start() {
    _timer?.cancel();
    refresh();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => refresh(silent: true));
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refresh({bool silent = false}) async {
    if (_refreshing) return;
    _refreshing = true;
    if (!silent) {
      _status = NetworkStatus.checking;
      notifyListeners();
    }

    final next = await _probeStatus();
    _status = next;
    _refreshing = false;
    notifyListeners();
  }

  @visibleForTesting
  void setStatusForTest(NetworkStatus status) {
    _status = status;
    _refreshing = false;
    notifyListeners();
  }

  Future<NetworkStatus> _probeStatus() async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await http
          .get(Uri.parse(_probeUrl))
          .timeout(_timeout);
      stopwatch.stop();
      if (response.statusCode != 204) return NetworkStatus.offline;
      if (stopwatch.elapsedMilliseconds > _slowThresholdMs) {
        return NetworkStatus.slow;
      }
      return NetworkStatus.online;
    } catch (_) {
      return NetworkStatus.offline;
    }
  }
}
