import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';



import '../utils/permissions_helper.dart';

import '../utils/platform_utils.dart';

import 'firebase_service.dart';

import 'notification_background.dart';



final notificationService = NotificationService();



class NotificationService {

  final _messaging = FirebaseMessaging.instance;

  final _local = FlutterLocalNotificationsPlugin();



  static const _channelId = 'shadow_find_default';

  static const _channelName = 'Shadow Find';



  Future<void> init() async {

    if (isGuessOnlyPlatform) return;



    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await _local.initialize(

      const InitializationSettings(android: android),

    );



    final androidPlugin = _local.resolvePlatformSpecificImplementation<

        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(

      const AndroidNotificationChannel(

        _channelId,

        _channelName,

        description: 'Приглашения в друзья и новые фото',

        importance: Importance.high,

        playSound: true,

        enableVibration: true,

      ),

    );

    await androidPlugin?.requestNotificationsPermission();

    await PermissionsHelper.ensureNotifications();



    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);



    await _messaging.setForegroundNotificationPresentationOptions(

      alert: true,

      badge: true,

      sound: true,

    );

    await _messaging.requestPermission(

      alert: true,

      badge: true,

      sound: true,

    );



    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);



    await _syncToken();

    _messaging.onTokenRefresh.listen((token) async {

      await firebaseService.saveFcmToken(token);

    });

  }



  Future<void> _syncToken() async {

    if (firebaseService.currentUid == null) return;

    final token = await _messaging.getToken();

    if (token != null) {

      await firebaseService.saveFcmToken(token);

    }

  }



  void _onMessageOpened(RemoteMessage message) {}



  void _onForegroundMessage(RemoteMessage message) {

    final n = message.notification;

    if (n == null) return;

    _showLocal(

      title: n.title ?? 'Shadow Find',

      body: n.body ?? '',

      id: message.hashCode,

    );

  }



  Future<void> _showLocal({

    required String title,

    required String body,

    required int id,

  }) async {

    await _local.show(

      id,

      title,

      body,

      NotificationDetails(

        android: AndroidNotificationDetails(

          _channelId,

          _channelName,

          channelDescription: 'Приглашения в друзья и новые фото',

          importance: Importance.high,

          priority: Priority.high,

          visibility: NotificationVisibility.public,

          icon: 'ic_notification',

        ),

      ),

    );

  }

}


