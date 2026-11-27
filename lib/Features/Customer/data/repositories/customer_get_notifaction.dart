import 'dart:async';
import 'package:entrig/entrig.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

StreamSubscription<String>? _fcmTokenRefreshSubscription;

/// حفظ FCM Token وتسجيل العميل في Entrig و Supabase
Future<void> saveCustomerDeviceToken() async {
  if (kIsWeb) return;
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await Entrig.register(userId: userId);
    } catch (e) {
      debugPrint('Entrig register warning: $e');
    }

    try {
      await Permission.notification.request();
    } catch (_) {}

    final messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // ignore: deprecated_member_use
      final String? token = await messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await supabase.from('user_devices').upsert(
          {
            'user_id': userId,
            'fcm_token': token,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id',
        );
      }

      await _fcmTokenRefreshSubscription?.cancel();
      // ignore: deprecated_member_use
      _fcmTokenRefreshSubscription = messaging.onTokenRefresh.listen((
        newToken,
      ) async {
        final currentUserId = supabase.auth.currentUser?.id;
        if (currentUserId != null) {
          await supabase.from('user_devices').upsert(
            {
              'user_id': currentUserId,
              'fcm_token': newToken,
              'updated_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'user_id',
          );
        }
      });
    }
  } catch (e) {
    debugPrint('saveCustomerDeviceToken warning: $e');
  }
}
