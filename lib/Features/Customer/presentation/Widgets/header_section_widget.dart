import 'package:flutter/material.dart';

class HeaderSectionWidget extends StatelessWidget {
  const HeaderSectionWidget({
    super.key,
    required this.merchantName,
    this.lastUpdated,
  });

  final String merchantName;
  final DateTime? lastUpdated;

  String _formatDate(DateTime? dt) {
    final target = dt ?? DateTime.now();
    final hour = target.hour > 12
        ? target.hour - 12
        : (target.hour == 0 ? 12 : target.hour);
    final period = target.hour >= 12 ? 'مساءً' : 'صباحاً';
    final min = target.minute.toString().padLeft(2, '0');
    return '${target.day}/${target.month}/${target.year} • $hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF13ec13).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.storefront_rounded,
                size: 38,
                color: Color(0xFF0fa30f),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            merchantName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.verified_outlined, size: 15, color: Color(0xFF0fa30f)),
              SizedBox(width: 4),
              Text(
                'سجل إلكتروني موثق ومحدّث لحظياً',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  lastUpdated != null
                      ? 'آخر حركة: ${_formatDate(lastUpdated)}'
                      : 'لا توجد حركات مسجلة بعد',
                  style: const TextStyle(color: Colors.black54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
