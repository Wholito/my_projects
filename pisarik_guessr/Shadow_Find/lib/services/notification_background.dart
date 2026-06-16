import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const android = AndroidInitializationSettings('@mipmap/ic_launcher');
  await plugin.initialize(const InitializationSettings(android: android));

  final androidPlugin =
      plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
  await androidPlugin?.createNotificationChannel(
    const AndroidNotificationChannel(
      'shadow_find_default',
      'Shadow Find',
      description: 'Приглашения в друзья и новые фото',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    ),
  );

  final notification = message.notification;
  if (notification == null) return;

  await plugin.show(
    message.hashCode,
    notification.title,
    notification.body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'shadow_find_default',
        'Shadow Find',
        channelDescription: 'Приглашения в друзья и новые фото',
        importance: Importance.high,
        priority: Priority.high,
        visibility: NotificationVisibility.public,
        icon: 'ic_notification',
      ),
    ),
  );
}
