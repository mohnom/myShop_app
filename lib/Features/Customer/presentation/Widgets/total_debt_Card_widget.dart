import 'package:flutter/material.dart';

class TotalDebtWdget extends StatelessWidget {
  const TotalDebtWdget({
    super.key,
    this.totalDebt = 0.0,
    this.merchantsCount = 0,
  });

  final double totalDebt;
  final int merchantsCount;

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = totalDebt > 0.009;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFF13ec13).withValues(alpha: 0.22),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFffffff), Color(0xFFf0fdf0)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'صافي الديون المستحقة عليك',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF618961),
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      totalDebt.toStringAsFixed(2),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: hasDebt
                            ? const Color(0xFFe11d48)
                            : const Color(0xFF0fa30f),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ر.ي',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: hasDebt
                            ? const Color(0xFFe11d48)
                            : const Color(0xFF0fa30f),
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF13ec13).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 15,
                    color: Color(0xFF0fa30f),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$merchantsCount متجر',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0fa30f),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
