import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/custom_details_appbar_widget.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/footer_details_widget.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/header_section_widget.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/list_of_product_widget.dart';
import 'package:myshop/Features/Customer/presentation/bloc/show_customer_purchases/show_customer_purchases_cubit.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';
import 'package:myshop/core/services/customer_notification_listener.dart';

class DetailsItemsView extends StatefulWidget {
  const DetailsItemsView({
    super.key,
    required this.conectId,
    required this.merchantName,
  });

  final int conectId;
  final String merchantName;

  static const Color primaryGreen = Color(0xFF13ec13);
  static const Color bgLight = Color(0xFFf6f8f6);

  @override
  State<DetailsItemsView> createState() => _DetailsItemsViewState();
}

class _DetailsItemsViewState extends State<DetailsItemsView> {
  StreamSubscription<NewSaleEvent>? _saleSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStatement();
    });

    _saleSub = CustomerNotificationListener.instance.onNewSaleReceived.listen((
      event,
    ) {
      if (event.connectId == widget.conectId && mounted) {
        _loadStatement();
      }
    });
  }

  Future<void> _loadStatement() async {
    if (!mounted) return;
    await context
        .read<ShowCustomerPurchasesCubit>()
        .fetchPurchasesForMerchant(widget.conectId);
  }

  @override
  void dispose() {
    _saleSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: DetailsItemsView.bgLight,
        appBar: CustomDetailAppbarWidget(
          conectId: widget.conectId,
          merchantName: widget.merchantName,
        ),
        body: BlocBuilder<ShowCustomerPurchasesCubit, ShowCustomerPurchasesState>(
          builder: (context, state) {
            if (state is ShowCustomerPurchasesLoading) {
              return const Center(child: CustomLoadingWidget());
            }

            if (state is ShowCustomerPurchasesFailed) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        state.error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadStatement,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }

            List<DebtItemModel> purchases = const [];
            List<PaymentModel> payments = const [];
            double grossPurchases = 0.0;
            double totalPaid = 0.0;
            double totalDebt = 0.0;

            if (state is ShowCustomerPurchasesSuccess) {
              purchases = state.purchases;
              payments = state.payments;
              grossPurchases = state.grossPurchases;
              totalPaid = state.totalPaid;
              totalDebt = state.totalDebt;
            }

            final DateTime? latestDate = purchases.isNotEmpty
                ? purchases.first.date
                : (payments.isNotEmpty ? payments.first.date : null);

            return Stack(
              children: [
                RefreshIndicator(
                  color: DetailsItemsView.primaryGreen,
                  onRefresh: _loadStatement,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        HeaderSectionWidget(
                          merchantName: widget.merchantName,
                          lastUpdated: latestDate,
                        ),
                        const SizedBox(height: 16),
                        ListOfProductWidget(
                          purchases: purchases,
                          payments: payments,
                        ),
                        const SizedBox(height: 180),
                      ],
                    ),
                  ),
                ),
                FooterDetailsWidget(
                  totalAmount: totalDebt,
                  grossPurchases: grossPurchases,
                  totalPaid: totalPaid,
                  merchantName: widget.merchantName,
                  purchases: purchases,
                  payments: payments,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
