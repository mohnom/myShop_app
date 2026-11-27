import 'dart:async';
import 'package:entrig/entrig.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

StreamSubscription<String>? _fcmTokenRefreshSubscription;

/// حفظ FCM Token وتسجيل العميل في Entrig و Supabase لضمان وصول إشعارات الخلفية
Future<void> saveCustomerDeviceToken() async {
  if (kIsWeb) return;
  try {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    // 1. طلب صلاحية الإشعارات أولاً مرة واحدة بشكل منظم
    try {
      await Permission.notification.request();
    } catch (_) {}

    final messaging = FirebaseMessaging.instance;
    final NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. تسجيل الجهاز في Entrig بعد التأكد من جاهزية Activity الأندرويد
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Entrig.register(userId: userId);
      } catch (e) {
        debugPrint('Entrig register warning: $e');
      }
    });

    // 3. حفظ وتحديث FCM Token في جدول user_devices لاستخدامه من الدالة السحابية
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
