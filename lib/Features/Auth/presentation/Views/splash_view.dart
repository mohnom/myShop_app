import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/mainContent_splashView_widget.dart';
import 'package:myshop/Features/Customer/data/repositories/customer_get_notifaction.dart';
import 'package:myshop/core/services/customer_notification_listener.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  Timer? _timer;

  Future<void> _navigate() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      if (mounted) context.go('/loginView');
      return;
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? role =
        prefs.getString('role') ??
        (session.user.userMetadata?['role'] as String?);

    if (role == 'customer') {
      saveCustomerDeviceToken();
      CustomerNotificationListener.instance.startListening(
        authUserId: session.user.id,
      );
      if (mounted) context.go('/homeCustomerView');
    } else if (role == 'merchant') {
      if (mounted) context.go('/homeMerchontView');
    } else {
      if (mounted) context.go('/loginView');
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), _navigate);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const Color primaryColor = Color(0xFF11D421);
    const Color forestGreen = Color(0xFF0D1B0F);
    final Color bgColor = isDark
        ? const Color(0xFF102212)
        : const Color(0xFFF8FCF8);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildBlurBlob(primaryColor.withValues(alpha: 0.08), 200),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: -40,
            child: _buildBlurBlob(forestGreen.withValues(alpha: 0.05), 150),
          ),
          MainContentSplashView(
            isDark: isDark,
            primaryColor: primaryColor,
            bgColor: bgColor,
            forestGreen: forestGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBlurBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
