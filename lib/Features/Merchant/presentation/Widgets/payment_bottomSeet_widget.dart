import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/make_payment/make_payment_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_purchases/show_purchases_cubit.dart';
import 'package:myshop/core/Widgets/Custom_snakbar_widget.dart';

class PaymentBottomSheet extends StatefulWidget {
  const PaymentBottomSheet({
    super.key,
    required this.conectId,
    required this.totalDebt,
  });

  final int conectId;
  final double totalDebt;

  @override
  State<PaymentBottomSheet> createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _addAmount(double amount) {
    final double current = double.tryParse(_amountController.text) ?? 0;
    double newAmount = current + amount;
    if (widget.totalDebt > 0 && newAmount > widget.totalDebt) {
      newAmount = widget.totalDebt;
    }

    setState(() {
      _amountController.text = newAmount.toStringAsFixed(2);
    });
  }

  void _payAll() {
    if (widget.totalDebt <= 0) return;
    setState(() {
      _amountController.text = widget.totalDebt.toStringAsFixed(2);
    });
  }

  void _processPayment() {
    if (widget.totalDebt <= 0) {
      showSnackBar(
        context,
        'تنبيه',
        'حساب العميل خالص حالياً ولا توجد مديونية للتسديد',
        ContentType.warning,
      );
      return;
    }

    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      showSnackBar(
        context,
        'تنبيه',
        'يرجى إدخال مبلغ صحيح أكبر من صفر',
        ContentType.warning,
      );
      return;
    }

    if (amount > widget.totalDebt + 0.01) {
      showSnackBar(
        context,
        'تنبيه',
        'المبلغ المدخل أكبر من المديونية المتبقية (${widget.totalDebt.toStringAsFixed(2)} ر.ي)',
        ContentType.warning,
      );
      return;
    }

    context.read<MakePaymentCubit>().processPayment(
      conectId: widget.conectId,
      amount: amount,
      currentDebt: widget.totalDebt,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: BlocListener<MakePaymentCubit, MakePaymentState>(
          listener: (context, state) {
            if (state is MakePaymentLoading) {
              setState(() => _isLoading = true);
            } else if (state is MakePaymentSuccess) {
              setState(() => _isLoading = false);
              context.read<ShowPurchasesCubit>().fetchPurchases(
                widget.conectId,
              );
              Navigator.of(context).pop();
              showSnackBar(
                context,
                'تم التسديد بنجاح',
                'تم تسجيل دفعة التسديد وتحديث رصيد العميل فوراً',
                ContentType.success,
              );
            } else if (state is MakePaymentFailed) {
              setState(() => _isLoading = false);
              showSnackBar(
                context,
                'حدث خطأ',
                state.error,
                ContentType.failure,
              );
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF19e619,
                              ).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.payments_outlined,
                              color: Color(0xFF0fa30f),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'تسديد دفعة من الحساب',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1A1C1C),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Color(0xFF3B4A3D)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildAmountField(),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildQuickAddButton(100),
                              const SizedBox(width: 8),
                              _buildQuickAddButton(500),
                              const SizedBox(width: 8),
                              _buildQuickAddButton(1000),
                              const SizedBox(width: 8),
                              _buildQuickAddButton(5000),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText:
                                'ملاحظة التسديد (اختياري، مثل: نقداً / حوالة)...',
                            hintStyle: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 13,
                              fontFamily: 'Cairo',
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF19e619),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            onPressed: _isLoading ? null : _processPayment,
                            icon: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline),
                            label: Text(
                              _isLoading ? 'جاري المعالجة...' : 'تأكيد التسديد',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Tajawal',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'سيتم خصم المبلغ من مديونية العميل وإشعاره فوراً.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 4, bottom: 8),
          child: Text(
            'المبلغ المسدد (ر.ي)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B4A3D),
              fontFamily: 'Cairo',
            ),
          ),
        ),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0fa30f),
            fontFamily: 'Tajawal',
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: const TextStyle(color: Color(0xFFDADADA)),
            filled: true,
            fillColor: const Color(0xFFF3F3F3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF19e619), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'المتبقي حالياً: ${widget.totalDebt.toStringAsFixed(2)} ر.ي',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF3B4A3D),
                fontFamily: 'Cairo',
              ),
            ),
            if (widget.totalDebt > 0)
              TextButton(
                onPressed: _payAll,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'تسديد الكل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0fa30f),
                    decoration: TextDecoration.underline,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(int amount) {
    return InkWell(
      onTap: () => _addAmount(amount.toDouble()),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          '+$amount',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3B4A3D),
          ),
        ),
      ),
    );
  }
}
