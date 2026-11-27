import 'dart:convert';
import 'package:entrig/entrig.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:myshop/core/routes/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الإشعارات المحلية + FCM + Entrig في الواجهة والخلفية
class NotificationService {
  NotificationService._();
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  static const String notificationsPrefKey = 'notifications_enabled';

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'myshop_sales_channel',
    'إشعارات المبيعات والدفعات',
    description: 'إشعارات عمليات البيع والتسديد الجديدة',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;

    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_notify',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      await androidImplementation?.createNotificationChannel(_channel);
      await androidImplementation?.requestNotificationsPermission();
    }

    // الاستماع لرسائل FCM أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // عند النقر على إشعار FCM والتطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // عند النقر على إشعار FCM والتطبيق مغلق تماماً (Terminated Cold Start)
    FirebaseMessaging.instance.getInitialMessage().then((initialMessage) {
      if (initialMessage != null) {
        Future.delayed(const Duration(milliseconds: 800), () {
          _handleMessageOpenedApp(initialMessage);
        });
      }
    });

    // عند النقر على إشعار قادم من Entrig في الخلفية
    try {
      Entrig.onNotificationOpened.listen((event) {
        final rawId =
            event.data?['ID_Conect'] ??
            event.data?['conect_id'] ??
            event.data?['connect_id'];
        final conectId = int.tryParse(rawId?.toString() ?? '');
        if (conectId != null && conectId > 0) {
          router.push(
            '/detailsItemsView',
            extra: {'conectId': conectId, 'merchantName': 'تفاصيل الحساب'},
          );
        }
      });
    } catch (_) {}

    _isInitialized = true;
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationsPrefKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationsPrefKey, enabled);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      final payloadMap = {
        'conectId': int.tryParse(message.data['conect_id']?.toString() ?? ''),
        'merchantName': message.data['merchant_name']?.toString() ?? 'المتجر',
      };
      showLocalNotification(
        title: notification.title ?? '🛒 عملية جديدة',
        body: notification.body ?? '',
        payload: jsonEncode(payloadMap),
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    final conectId = int.tryParse(message.data['conect_id']?.toString() ?? '');
    final merchantName = message.data['merchant_name']?.toString() ?? 'المتجر';
    if (conectId != null && conectId > 0) {
      router.push(
        '/detailsItemsView',
        extra: {'conectId': conectId, 'merchantName': merchantName},
      );
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    final raw = response.payload;
    if (raw == null || raw.isEmpty) return;

    try {
      if (raw.startsWith('{')) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final conectId = (decoded['conectId'] as num?)?.toInt();
        final merchantName =
            (decoded['merchantName'] as String?) ?? 'تفاصيل الحساب';
        if (conectId != null && conectId > 0) {
          router.push(
            '/detailsItemsView',
            extra: {'conectId': conectId, 'merchantName': merchantName},
          );
        }
      } else {
        final conectId = int.tryParse(raw);
        if (conectId != null && conectId > 0) {
          router.push(
            '/detailsItemsView',
            extra: {'conectId': conectId, 'merchantName': 'تفاصيل الحساب'},
          );
        }
      }
    } catch (e) {
      debugPrint('Notification tap parse warning: $e');
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    if (!await isNotificationsEnabled()) return;

    const androidDetails = AndroidNotificationDetails(
      'myshop_sales_channel',
      'إشعارات المبيعات والدفعات',
      channelDescription: 'إشعارات عمليات البيع والتسديد الجديدة',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/ic_stat_notify',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }
}
