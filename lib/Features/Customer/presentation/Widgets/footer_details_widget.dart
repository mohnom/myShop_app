import 'package:flutter/material.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:myshop/core/utils/share_helper.dart';

class FooterDetailsWidget extends StatelessWidget {
  const FooterDetailsWidget({
    super.key,
    required this.totalAmount,
    this.grossPurchases = 0.0,
    this.totalPaid = 0.0,
    required this.merchantName,
    required this.purchases,
    this.payments = const [],
  });

  final double totalAmount;
  final double grossPurchases;
  final double totalPaid;
  final String merchantName;
  final List<DebtItemModel> purchases;
  final List<PaymentModel> payments;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade100)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF13ec13),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'صافي المبلغ المتبقي',
                        style: TextStyle(
                          color: Color(0xFF053a05),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Text(
                        totalPaid > 0
                            ? 'المشتريات: ${grossPurchases.toStringAsFixed(0)} | المسدد: ${totalPaid.toStringAsFixed(0)}'
                            : 'إجمالي الرصيد الحالي',
                        style: const TextStyle(
                          color: Color(0xFF053a05),
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${totalAmount.toStringAsFixed(2)} ',
                          style: const TextStyle(
                            color: Color(0xFF053a05),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const TextSpan(
                          text: 'ر.ي',
                          style: TextStyle(
                            color: Color(0xFF053a05),
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomActonButtonWidget(
                    icon: Icons.share,
                    label: 'مشاركة كشف الحساب عبر واتساب',
                    onTap: () {
                      ShareHelper.shareStatement(
                        context: context,
                        title: 'حساب متجر $merchantName',
                        totalDebt: totalAmount,
                        purchases: purchases,
                        payments: payments,
                        grossPurchases: grossPurchases,
                        totalPaid: totalPaid,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CustomActonButtonWidget extends StatelessWidget {
  const CustomActonButtonWidget({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.black87,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: const Color(0xFF0fa30f)),
      label: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
