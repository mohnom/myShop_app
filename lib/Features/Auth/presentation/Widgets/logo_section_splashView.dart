import 'package:flutter/material.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({
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
    return Column(
      children: [
        Container(
          width: 128,
          height: 128,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.shopping_bag, size: 64, color: primaryColor),
              Positioned(
                bottom: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? bgColor : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.menu_book,
                    size: 20,
                    color: isDark ? primaryColor : forestGreen,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'بقالتي',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 44,
            fontWeight: FontWeight.w800,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'دفتر الحسابات الرقمي الموثوق',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
