import 'dart:async';
import 'dart:convert';
import 'package:entrig/entrig.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myshop/add_provider.dart';
import 'package:myshop/core/routes/router.dart';
import 'package:myshop/core/services/notification_service.dart';
import 'package:myshop/core/utils/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// معالج رسائل الخلفية عند إغلاق التطبيق بالكامل (Terminated / Background)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // إذا كانت الرسالة تحتوي على حقل notification، يعرضها نظام أندرويد تلقائياً عبر قناة myshop_sales_channel.
  // أما إذا كانت الرسالة Data-only، نقوم بعرضها محلياً هنا لضمان ظهورها دائماً في الخلفية:
  if (message.notification == null && message.data.isNotEmpty) {
    String? title = message.data['title']?.toString();
    String? body = message.data['body']?.toString();

    if (title == null && message.data['payload'] != null) {
      try {
        final decoded =
            jsonDecode(message.data['payload'].toString())
                as Map<String, dynamic>;
        title = decoded['title']?.toString();
        body = decoded['body']?.toString();
      } catch (_) {}
    }

    if (title != null && title.isNotEmpty) {
      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings(
        '@drawable/ic_stat_notify',
      );
      await plugin.initialize(
        settings: const InitializationSettings(android: androidInit),
      );

      const channel = AndroidNotificationChannel(
        'myshop_sales_channel',
        'إشعارات المبيعات والدفعات',
        description: 'إشعارات عمليات البيع والتسديد الجديدة',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );
      await plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(channel);

      await plugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: title,
        body: body ?? '',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'myshop_sales_channel',
            'إشعارات المبيعات والدفعات',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: '@drawable/ic_stat_notify',
          ),
        ),
      );
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase وتسجيل معالج الخلفية أولاً
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init warning: $e');
  }

  // تهيئة Entrig لإشعارات الخلفية
  final entrigKey = AppConfig.entrigApiKey;
  if (entrigKey.isNotEmpty && !entrigKey.startsWith('YOUR_')) {
    try {
      await Entrig.init(
        apiKey: entrigKey,
        handlePermission: false,
        showForegroundNotification: true,
      );
    } catch (e) {
      debugPrint('Entrig init warning: $e');
    }
  }

  // تهيئة خدمة الإشعارات المحلية وقناة الأندرويد عالية الأولوية
  await NotificationService.instance.initialize();

  // تهيئة Supabase
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(
    MultiBlocProvider(
      providers: AddProvider.allProviders,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    try {
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange
          .listen((data) {
            if (data.event == AuthChangeEvent.passwordRecovery) {
              router.go('/updatePasswordView');
            }
          });
    } catch (_) {}
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'بقالتي',
      locale: const Locale('ar'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF19e619),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAF8),
      ),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
