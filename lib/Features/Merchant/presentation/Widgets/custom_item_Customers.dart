import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:myshop/Features/Merchant/presentation/Views/detail_of_Customer_item_view.dart';

class CustomerCard extends StatelessWidget {
  final String name;
  final int conectId;
  final double netDebt;
  final VoidCallback? onReturn;

  const CustomerCard({
    super.key,
    required this.name,
    required this.conectId,
    this.netDebt = 0.0,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasDebt = netDebt > 0.009;

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                DetailOfCustomerItemView(conectId: conectId, name: name),
          ),
        );
        onReturn?.call();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF19e619).withValues(alpha: 0.18),
          ),
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
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF19e619).withValues(alpha: 0.12),
              child: const FaIcon(
                FontAwesomeIcons.user,
                color: Color(0xFF19e619),
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'رقم الحساب: #$conectId',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: hasDebt
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFF19e619).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasDebt ? '${netDebt.toStringAsFixed(2)} ر.ي' : 'خالص ✓',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: hasDebt
                          ? const Color(0xFFE11D48)
                          : const Color(0xFF0fa30f),
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'التفاصيل',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
