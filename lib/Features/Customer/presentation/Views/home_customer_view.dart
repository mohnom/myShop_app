import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/Customer_dailog_AddMerchont.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/custom_appbar_widget.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/custom_customer_card_widget.dart';
import 'package:myshop/Features/Customer/presentation/Widgets/total_debt_Card_widget.dart';
import 'package:myshop/Features/Customer/presentation/bloc/show_merchonts/show_merchonts_cubit.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';
import 'package:myshop/core/services/customer_notification_listener.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeCustomerView extends StatefulWidget {
  const HomeCustomerView({super.key});

  @override
  State<HomeCustomerView> createState() => _HomeCustomerViewState();
}

class _HomeCustomerViewState extends State<HomeCustomerView> {
  late final String _userId;
  StreamSubscription<NewSaleEvent>? _saleSub;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_userId.isNotEmpty) {
      _refreshMerchants();
    }

    _saleSub = CustomerNotificationListener.instance.onNewSaleReceived.listen((
      _,
    ) {
      if (mounted && _userId.isNotEmpty) {
        _refreshMerchants();
      }
    });
  }

  Future<void> _refreshMerchants() async {
    if (!mounted || _userId.isEmpty) return;
    await context.read<ShowMerchontsCubit>().showMerchonts(userId: _userId);
  }

  @override
  void dispose() {
    _saleSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF13ec13),
        onPressed: () async {
          final added = await showDialog<bool>(
            context: context,
            builder: (_) => const CustomDialogAddMerchant(),
          );
          if (added == true && mounted) {
            _refreshMerchants();
          }
        },
        label: const Text(
          'إضافة متجر جديد',
          style: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              const CustomAppbarCusotmerWidget(),
              Expanded(
                child: BlocBuilder<ShowMerchontsCubit, ShowMerchontsState>(
                  builder: (context, state) {
                    if (state is ShowMerchontsLoading) {
                      return const Center(child: CustomLoadingWidget());
                    }
                    if (state is ShowMerchontsFailed) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.wifi_off_rounded,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.errMessage,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 15,
                                fontFamily: 'Cairo',
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _refreshMerchants,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is ShowMerchontsSuccess) {
                      final merchants = state.merchants;
                      return RefreshIndicator(
                        color: const Color(0xFF13ec13),
                        onRefresh: _refreshMerchants,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 90),
                          children: [
                            TotalDebtWdget(
                              totalDebt: state.totalDebtAll,
                              merchantsCount: merchants.length,
                            ),
                            if (merchants.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 60,
                                  horizontal: 24,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.store_mall_directory_outlined,
                                      size: 72,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد متاجر مضافة بعد.\nاضغط على «إضافة متجر جديد» وأدخل الرقم التعريفي لبقالتك!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 15,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Column(
                                  children: merchants.map((m) {
                                    final rawDate =
                                        m['last_purchase_date'] as String?;
                                    return CustomerCard(
                                      name:
                                          (m['Name_merchont'] as String?) ??
                                          'متجر',
                                      conectId:
                                          (m['id'] as num?)?.toInt() ?? 0,
                                      netDebt:
                                          (m['net_debt'] as num?)?.toDouble() ??
                                          0.0,
                                      lastPurchaseDate: rawDate != null
                                          ? DateTime.tryParse(rawDate)
                                          : null,
                                      onReturn: _refreshMerchants,
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
