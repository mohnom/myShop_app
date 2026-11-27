import 'package:flutter/material.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/card_product_widget.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';

class ListOfProductWidget extends StatelessWidget {
  const ListOfProductWidget({
    super.key,
    required this.purchases,
    this.payments = const [],
  });

  final List<DebtItemModel> purchases;
  final List<PaymentModel> payments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'المنتجات المشتراة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13ec13).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${purchases.length} عنصر',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF053a05),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              if (purchases.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'لا توجد مشتريات مسجلة بعد',
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontFamily: 'Cairo',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...purchases.map((item) {
                  final dateStr =
                      '${item.date.day}/${item.date.month}/${item.date.year}';
                  final notePart = (item.note != null && item.note!.isNotEmpty)
                      ? ' • ${item.note}'
                      : '';
                  return CardBroductWidget(
                    title: item.nameProduct,
                    sub:
                        '${item.price.toStringAsFixed(2)} × ${item.quantity} • $dateStr$notePart',
                    price: item.totalPrice.toStringAsFixed(2),
                    icon: Icons.shopping_bag_outlined,
                    iconBg: const Color(0xFF13ec13),
                  );
                }),
            ],
          ),
        ),
        if (payments.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF13ec13).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الدفعات المسددة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0fa30f),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        '${payments.length} دفعة',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0fa30f),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...payments.map((p) {
                  final dateStr = '${p.date.day}/${p.date.month}/${p.date.year}';
                  final notePart = (p.note != null && p.note!.isNotEmpty)
                      ? ' • ${p.note}'
                      : '';
                  return CardBroductWidget(
                    title: 'دفعة تسديد',
                    sub: '$dateStr$notePart',
                    price: '-${p.amount.toStringAsFixed(2)}',
                    icon: Icons.check_circle_outline,
                    iconBg: const Color(0xFF0fa30f),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
