import 'package:flutter_test/flutter_test.dart';
import 'package:shadow_find/services/connectivity_service.dart';

void main() {
  group('ConnectivityService', () {
    test('needsRetry when offline or slow', () {
      final service = ConnectivityService();

      service.setStatusForTest(NetworkStatus.offline);
      expect(service.needsRetry, isTrue);
      expect(service.isOnline, isFalse);
List<int> removeDuplicates(List<int> arr){
  final Set <int> nums = {};
  return arr.where((e) => nums.add(e)).toList();
}
      service.setStatusForTest(NetworkStatus.slow);
      expect(service.needsRetry, isTrue);

      service.setStatusForTest(NetworkStatus.online);
      expect(service.needsRetry, isFalse);
      expect(service.isOnline, isTrue);
    });

    test('status messages', () {
      final service = ConnectivityService();

      service.setStatusForTest(NetworkStatus.offline);
      expect(service.statusMessage, 'Нет подключения к интернету');

      service.setStatusForTest(NetworkStatus.slow);
      expect(service.statusMessage, 'Интернет слишком медленный');
    });
  });
}
