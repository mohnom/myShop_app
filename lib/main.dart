import 'dart:async';
import 'package:entrig/entrig.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myshop/add_provider.dart';
import 'package:myshop/core/routes/router.dart';
import 'package:myshop/core/services/notification_service.dart';
import 'package:myshop/core/utils/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Entrig بأمان دون تعطيل الإقلاع في حال غياب المفتاح أو ضعف الشبكة
  final entrigKey = AppConfig.entrigApiKey;
  if (entrigKey.isNotEmpty && !entrigKey.startsWith('YOUR_')) {
    try {
      await Entrig.init(
        apiKey: entrigKey,
        showForegroundNotification: true,
      );
    } catch (e) {
      debugPrint('Entrig init warning: $e');
    }
  }

  // تهيئة Firebase وخلفية الرسائل
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init warning: $e');
  }

  // تهيئة خدمة الإشعارات المحلية
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
    // الاستماع لحدث استعادة كلمة المرور عبر الرابط العميق (Deep Link)
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
