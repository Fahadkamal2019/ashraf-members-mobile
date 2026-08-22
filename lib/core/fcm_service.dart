import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers.dart';

const _androidChannel = AndroidNotificationChannel(
  'default_channel',
  'إشعارات عامة',
  description: 'إشعارات نقابة السادة الأشراف',
  importance: Importance.high,
);

final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

/// Background/terminated-state messages are delivered straight to the Android system tray by
/// FCM itself with zero app code involved - this handler only needs to exist (as a registered
/// top-level entry point) for that delivery path to work at all.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class FcmService {
  FcmService(this._dio);

  final Dio _dio;

  /// Call once at app startup, before any login state matters - sets up local notification
  /// display and the background handler. Registering the device token with the Api happens
  /// separately (see [registerToken]), only once a member is actually signed in.
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _localNotificationsPlugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await FirebaseMessaging.instance.requestPermission();

    // FCM only auto-shows a system notification while the app is backgrounded/closed; a
    // foreground message has to be displayed manually or the member would never see it.
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localNotificationsPlugin.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    });
  }

  /// Registers this device's current FCM token with the Api for the now-signed-in member, and
  /// keeps re-registering if the token ever rotates (FCM does this occasionally). Failures here
  /// (no Google Play Services on the device, Firebase not configured yet, etc.) must never break
  /// the rest of the app - push delivery is a bonus on top of the in-app notification list, not a
  /// hard requirement to use the app.
  Future<void> registerToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _sendToken(token);
      }
      FirebaseMessaging.instance.onTokenRefresh.listen(_sendToken);
    } catch (_) {
      // Best-effort, see method doc.
    }
  }

  Future<void> _sendToken(String token) async {
    try {
      await _dio.post('/api/fcm-token', data: {'token': token});
    } on DioException {
      // Best-effort: a failed token registration just means this device won't get pushes until
      // the next successful attempt (next login, or next token refresh) - not worth surfacing.
    }
  }
}

final fcmServiceProvider = Provider<FcmService>((ref) => FcmService(ref.watch(dioProvider)));
