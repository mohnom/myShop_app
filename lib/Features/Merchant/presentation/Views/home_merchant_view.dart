import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_header_widget.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_item_Customers.dart';
import 'package:myshop/Features/Merchant/presentation/Widgets/custom_search_widget.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_customers/show_customers_cubit.dart';
import 'package:myshop/Features/Merchant/presentation/bloc/show_merchant_data/show_merchantdata_cubit.dart';
import 'package:myshop/core/Widgets/custom_loading_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeMerchantView extends StatefulWidget {
  const HomeMerchantView({super.key});

  static const Color primaryGreen = Color(0xFF0ff05a);
  static const Color backgroundLight = Color(0xFFf5f8f6);
  static const Color surfaceLight = Color(0xFFffffff);
  static const Color textMain = Color(0xFF0f172a);

  @override
  State<HomeMerchantView> createState() => _HomeMerchantViewState();
}

class _HomeMerchantViewState extends State<HomeMerchantView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _debtFilter = 'all'; // 'all' | 'debt' | 'settled'
  late final String _userId;

  @override
  void initState() {
    super.initState();
    _userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (_userId.isNotEmpty) {
      _refreshAll();
    }
  }

  Future<void> _refreshAll() async {
    if (_userId.isEmpty || !mounted) return;
    await Future.wait([
      context.read<ShowCustomersCubit>().showCustomers(userId: _userId),
      context.read<ShowMerchantdataCubit>().getUserDataById(_userId),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HomeMerchantView.backgroundLight,
        body: SafeArea(
          child: Column(
            children: [
              BlocBuilder<ShowMerchantdataCubit, ShowMerchantdataState>(
                builder: (context, state) {
                  if (state is ShowMerchantdataSucsess) {
                    return CustomHeaderMerchant(
                      name: (state.message['name'] as String?) ?? 'التاجر',
                      id: (state.message['id'] as num?)?.toInt() ?? 0,
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(color: Color(0xFF19e619)),
                  );
                },
              ),
              CustomSearchWidget(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                onClear: () {
                  setState(() {
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
              ),
              BlocBuilder<ShowCustomersCubit, ShowCustomersState>(
                builder: (context, state) {
                  if (state is ShowCustomersLoading) {
                    return const Expanded(
                      child: Center(child: CustomLoadingWidget()),
                    );
                  } else if (state is ShowCustomersSuccses) {
                    final allCustomers = state.customers;
                    final debtorCount = allCustomers
                        .where(
                          (c) => ((c['net_debt'] as num?)?.toDouble() ?? 0) > 0,
                        )
                        .length;

                    final filteredCustomers = allCustomers.where((c) {
                      final name = (c['Name_customer'] ?? '')
                          .toString()
                          .toLowerCase();
                      final id = (c['id'] ?? '').toString();
                      final matchesSearch =
                          _searchQuery.isEmpty ||
                          name.contains(_searchQuery.toLowerCase()) ||
                          id.contains(_searchQuery);
                      if (!matchesSearch) return false;

                      final netDebt =
                          (c['net_debt'] as num?)?.toDouble() ?? 0.0;
                      if (_debtFilter == 'debt') return netDebt > 0.0;
                      if (_debtFilter == 'settled') return netDebt <= 0.0;
                      return true;
                    }).toList();

                    return Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFF19e619),
                        onRefresh: _refreshAll,
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          children: [
                            // بطاقة ملخص ديون السوق للتاجر
                            _buildMarketSummaryCard(
                              totalReceivables: state.totalReceivables,
                              totalCustomers: allCustomers.length,
                              debtorCount: debtorCount,
                            ),
                            const SizedBox(height: 12),
                            // فلاتر سريعة
                            Row(
                              children: [
                                _buildFilterChip('الكل', 'all'),
                                const SizedBox(width: 8),
                                _buildFilterChip('عليه مديونية', 'debt'),
                                const SizedBox(width: 8),
                                _buildFilterChip('خالص', 'settled'),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (filteredCustomers.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 48,
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      allCustomers.isEmpty
                                          ? Icons.people_outline
                                          : Icons.search_off,
                                      size: 64,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      allCustomers.isEmpty
                                          ? 'لا يوجد عملاء مرتبطون بعد.\nشارك رقمك التعريفي مع زبائنك لإضافتك!'
                                          : 'لا توجد نتائج تطابق الفلتر الحالي',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...filteredCustomers.map(
                                (customer) => CustomerCard(
                                  name:
                                      (customer['Name_customer'] as String?) ??
                                      'عميل',
                                  conectId:
                                      (customer['id'] as num?)?.toInt() ?? 0,
                                  netDebt:
                                      (customer['net_debt'] as num?)
                                          ?.toDouble() ??
                                      0.0,
                                  onReturn: () {
                                    if (mounted && _userId.isNotEmpty) {
                                      context
                                          .read<ShowCustomersCubit>()
                                          .showCustomers(userId: _userId);
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is ShowCustomersFaild) {
                    return Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              state.error,
                              style: const TextStyle(
                                color: Colors.red,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _refreshAll,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Expanded(
                    child: Center(child: CustomLoadingWidget()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarketSummaryCard({
    required double totalReceivables,
    required int totalCustomers,
    required int debtorCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D2818), Color(0xFF14532D)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF14532D).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إجمالي الديون المستحقة لك',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalReceivables.toStringAsFixed(2),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'ر.ي',
                    style: TextStyle(
                      color: Color(0xFF37ec13),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  '$debtorCount / $totalCustomers',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFamily: 'Tajawal',
                  ),
                ),
                const Text(
                  'عميل مدين',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final selected = _debtFilter == value;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : Colors.black87,
          fontFamily: 'Cairo',
        ),
      ),
      selected: selected,
      selectedColor: const Color(0xFF0fa30f),
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      onSelected: (_) => setState(() => _debtFilter = value),
    );
  }
}
