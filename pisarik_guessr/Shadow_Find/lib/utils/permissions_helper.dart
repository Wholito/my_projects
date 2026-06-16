import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import 'platform_utils.dart';

class PermissionsHelper {
  static Future<bool> ensureLocation() async {
    if (isGuessOnlyPlatform) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  static Future<bool> ensureNotifications() async {
    if (isGuessOnlyPlatform) return false;

    var status = await Permission.notification.status;
    if (status.isGranted) return true;
    status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> ensureCamera() async {
    if (isGuessOnlyPlatform) return false;

    var status = await Permission.camera.status;
    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await Permission.camera.request();
      return status.isGranted;
    }
    return false;
  }
}
