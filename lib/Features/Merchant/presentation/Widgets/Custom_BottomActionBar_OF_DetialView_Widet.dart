import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/Add_product_BottomSheet_Widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/payment_bottomSeet_widget.dart';

class CustomBottomActionBarOFDetialViewWidet extends StatelessWidget {
  const CustomBottomActionBarOFDetialViewWidet({
    super.key,
    required this.primaryGreen,
    required this.conectId,
    required this.totalDebt,
  });

  final int conectId;
  final Color primaryGreen;
  final double totalDebt;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(color: primaryGreen.withValues(alpha: 0.08)),
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) =>
                                AddProductBottomSheet(connectId: conectId),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_shopping_cart,
                                color: Colors.white,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'إضافة عملية بيع',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF0fa30f).withValues(alpha: 0.4),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => PaymentBottomSheet(
                              conectId: conectId,
                              totalDebt: totalDebt,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.payments_outlined,
                                color: Color(0xFF0fa30f),
                                size: 20,
                              ),
                              Text(
                                'تسديد الحساب',
                                style: TextStyle(
                                  color: Color(0xFF0fa30f),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
