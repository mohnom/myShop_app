import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myshop/Features/Customer/presentation/Views/details_of_items_view.dart';

class CustomerCard extends StatelessWidget {
  final String name;
  final int conectId;
  final double netDebt;
  final DateTime? lastPurchaseDate;
  final VoidCallback? onReturn;

  const CustomerCard({
    super.key,
    required this.name,
    required this.conectId,
    this.netDebt = 0.0,
    this.lastPurchaseDate,
    this.onReturn,
  });

  String _formatLastPurchase(DateTime? date) {
    if (date == null) return 'آخر شراء: لا توجد عمليات بعد';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'آخر شراء: منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'آخر شراء: منذ ${diff.inHours} ساعة';
    if (diff.inDays == 1) return 'آخر شراء: أمس';
    return 'آخر شراء: ${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = netDebt > 0.009;

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                DetailsItemsView(conectId: conectId, merchantName: name),
          ),
        );
        onReturn?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF13ec13).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.shop,
                  size: 24,
                  color: Color(0xFF0fa30f),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: hasDebt
                              ? const Color(0xFFFEF2F2)
                              : const Color(0xFF13ec13).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasDebt
                                ? const Color(0xFFFEE2E2)
                                : const Color(
                                    0xFF13ec13,
                                  ).withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          hasDebt
                              ? '${netDebt.toStringAsFixed(2)} ر.ي'
                              : 'خالص ✓',
                          style: TextStyle(
                            color: hasDebt
                                ? const Color(0xFFe11d48)
                                : const Color(0xFF0fa30f),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _formatLastPurchase(lastPurchaseDate),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
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
