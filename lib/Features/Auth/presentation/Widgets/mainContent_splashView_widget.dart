import 'package:flutter/material.dart';
import 'package:myshop/Features/Auth/presentation/Widgets/logo_section_splashView.dart';

class MainContentSplashView extends StatelessWidget {
  const MainContentSplashView({
    super.key,
    required this.isDark,
    required this.primaryColor,
    required this.bgColor,
    required this.forestGreen,
  });

  final bool isDark;
  final Color primaryColor;
  final Color bgColor;
  final Color forestGreen;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(flex: 2),
          LogoSection(
            isDark: isDark,
            primaryColor: primaryColor,
            bgColor: bgColor,
            forestGreen: forestGreen,
          ),
          const Spacer(flex: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
            child: Column(
              children: [
                Text(
                  'بساطة التعامل بين الجار وجاره',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    color: isDark ? Colors.grey[300] : forestGreen,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'جاري التحميل...',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'VER 1.0.0',
                  style: TextStyle(
                    letterSpacing: 2,
                    fontSize: 10,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
