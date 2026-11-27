import 'package:flutter/material.dart';

class DebtSummaryWidget extends StatelessWidget {
  const DebtSummaryWidget({
    super.key,
    required this.primaryGreen,
    required this.totalDebt,
    this.grossPurchases = 0.0,
    this.totalPaid = 0.0,
  });

  final Color primaryGreen;
  final double totalDebt;
  final double grossPurchases;
  final double totalPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: primaryGreen.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'صافي المديونية المتبقية',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                totalDebt.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Tajawal',
                  color: totalDebt > 0
                      ? const Color(0xFF0f172a)
                      : const Color(0xFF0fa30f),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'ر.ي',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAF8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'إجمالي المشتريات',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${grossPurchases.toStringAsFixed(2)} ر.ي',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 28, color: Colors.grey.shade300),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'إجمالي المسدد',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${totalPaid.toStringAsFixed(2)} ر.ي',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF0fa30f),
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
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
