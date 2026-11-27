import 'package:flutter/material.dart';

class CustomSuccessAnimation extends StatelessWidget {
  const CustomSuccessAnimation({
    super.key,
    required AnimationController sparkleController,
  }) : _sparkleController = sparkleController;

  final AnimationController _sparkleController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00E676).withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E676).withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              Container(
                width: 128,
                height: 128,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFA3F5B3),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00E676),
                  size: 72,
                ),
              ),
              Positioned(
                top: 0,
                left: 10,
                child: ScaleTransition(
                  scale: _sparkleController,
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF00E676),
                    size: 24,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: -5,
                child: ScaleTransition(
                  scale: _sparkleController,
                  child: const Icon(
                    Icons.local_florist,
                    color: Color(0xFF00E676),
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'تمت العملية بنجاح',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1C1C),
            fontFamily: 'Tajawal',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تم حفظ السجل وتحديث الحساب بنجاح',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3B4A3D).withValues(alpha: 0.8),
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
