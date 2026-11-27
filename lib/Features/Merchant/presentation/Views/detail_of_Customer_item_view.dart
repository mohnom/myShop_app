import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/Custom_BottomActionBar_OF_DetialView_Widet.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/Debt_Summary_Widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/Product_Item_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_detailAppbar_Widget.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/make_payment/make_payment_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_purchases/show_purchases_cubit.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';
import 'package:myshop/core/utils/share_helper.dart';

class DetailOfCustomerItemView extends StatefulWidget {
  const DetailOfCustomerItemView({
    super.key,
    required this.conectId,
    required this.name,
  });

  final String name;
  final int conectId;

  static const Color primaryGreen = Color(0xFF19e619);

  @override
  State<DetailOfCustomerItemView> createState() =>
      _DetailOfCustomerItemViewState();
}

class _DetailOfCustomerItemViewState extends State<DetailOfCustomerItemView> {
  int _selectedTab = 0; // 0: المشتريات | 1: الدفعات المسددة

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    await context.read<ShowPurchasesCubit>().fetchPurchases(widget.conectId);
  }

  void _confirmDeletePayment(BuildContext context, PaymentModel payment) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'حذف دفعة تسديد',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          content: Text(
            'هل تريد حذف دفعة التسديد البالغة ${payment.amount.toStringAsFixed(2)} ر.ي؟ سيعود المبلغ إلى مديونية العميل.',
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final makePaymentCubit = context.read<MakePaymentCubit>();
                final showPurchasesCubit = context.read<ShowPurchasesCubit>();
                Navigator.of(ctx).pop();
                await makePaymentCubit.deletePayment(payment.id);
                if (mounted) {
                  showPurchasesCubit.fetchPurchases(widget.conectId);
                }
              },
              child: const Text('حذف الدفعة'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFf8faf8),
        body: Stack(
          children: [
            BlocBuilder<ShowPurchasesCubit, ShowPurchasesState>(
              builder: (context, state) {
                List<DebtItemModel> purchases = const [];
                List<PaymentModel> payments = const [];
                double grossTotal = 0.0;
                double totalPaid = 0.0;
                double remainingDebt = 0.0;

                if (state is ShowPurchasesSuccess) {
                  purchases = state.purchases;
                  payments = state.payments;
                  grossTotal = state.grossTotal;
                  totalPaid = state.totalPaid;
                  remainingDebt = state.remainingDebt;
                }

                return RefreshIndicator(
                  color: DetailOfCustomerItemView.primaryGreen,
                  onRefresh: _loadData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      CustomDetailAppBarWidget(
                        primaryGreen: DetailOfCustomerItemView.primaryGreen,
                        name: widget.name,
                        onShare: () {
                          ShareHelper.shareStatement(
                            context: context,
                            title: 'العميل ${widget.name}',
                            totalDebt: remainingDebt,
                            purchases: purchases,
                            payments: payments,
                            grossPurchases: grossTotal,
                            totalPaid: totalPaid,
                          );
                        },
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            DebtSummaryWidget(
                              primaryGreen:
                                  DetailOfCustomerItemView.primaryGreen,
                              totalDebt: remainingDebt,
                              grossPurchases: grossTotal,
                              totalPaid: totalPaid,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                20,
                                24,
                                20,
                                16,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildTabButton(
                                      title:
                                          'سجل المشتريات (${purchases.length})',
                                      selected: _selectedTab == 0,
                                      onTap: () =>
                                          setState(() => _selectedTab = 0),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildTabButton(
                                      title: 'الدفعات (${payments.length})',
                                      selected: _selectedTab == 1,
                                      onTap: () =>
                                          setState(() => _selectedTab = 1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedTab == 0)
                              _buildPurchasesList(context, state)
                            else
                              _buildPaymentsList(context, state, payments),
                            const SizedBox(height: 150),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            BlocBuilder<ShowPurchasesCubit, ShowPurchasesState>(
              builder: (context, state) {
                final remainingDebt = state is ShowPurchasesSuccess
                    ? state.remainingDebt
                    : 0.0;
                return CustomBottomActionBarOFDetialViewWidet(
                  primaryGreen: DetailOfCustomerItemView.primaryGreen,
                  conectId: widget.conectId,
                  totalDebt: remainingDebt,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0fa30f) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFF0fa30f) : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPurchasesList(BuildContext context, ShowPurchasesState state) {
    if (state is ShowPurchasesLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: CustomLoadingWidget(),
      );
    }

    if (state is ShowPurchasesFailed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          state.error,
          style: const TextStyle(color: Colors.red, fontFamily: 'Cairo'),
        ),
      );
    }

    if (state is ShowPurchasesSuccess) {
      if (state.purchases.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: Column(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد مشتريات مسجلة بعد',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: state.purchases
              .map(
                (item) =>
                    ProductItemWidget(item: item, conectId: widget.conectId),
              )
              .toList(),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPaymentsList(
    BuildContext context,
    ShowPurchasesState state,
    List<PaymentModel> payments,
  ) {
    if (state is ShowPurchasesLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: CustomLoadingWidget(),
      );
    }

    if (payments.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.payments_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد دفعات تسديد مسجلة بعد',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 15,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: payments.map((p) {
          final dateStr = '${p.date.day}/${p.date.month}/${p.date.year}';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF19e619).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF19e619).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF0fa30f),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'دفعة تسديد',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      if (p.note != null && p.note!.isNotEmpty)
                        Text(
                          p.note!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '-${p.amount.toStringAsFixed(2)} ر.ي',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0fa30f),
                        fontFamily: 'Tajawal',
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _confirmDeletePayment(context, p),
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
