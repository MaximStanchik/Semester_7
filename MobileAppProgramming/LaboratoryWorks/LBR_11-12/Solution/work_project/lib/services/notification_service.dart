import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';

  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  StreamSubscription<RemoteMessage>? _onMessageSub;

  Future<void> init() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(initSettings);

    final android = _local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
        ),
      );
      await android.requestNotificationsPermission();
    }

    await FirebaseMessaging.instance.requestPermission();

    _onMessageSub?.cancel();
    _onMessageSub = FirebaseMessaging.onMessage.listen((message) async {
      await showLocalNotification(message);
    });

    _initialized = true;
  }

  Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  static Future<void> showLocalNotificationFromBackground(RemoteMessage message) async {
    if (kIsWeb) return;

    final local = FlutterLocalNotificationsPlugin();
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await local.initialize(initSettings);

    final android = local.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.high,
        ),
      );
    }

    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if ((title == null || title.isEmpty) && (body == null || body.isEmpty)) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showLocalNotificationFromBackground(message);
}
