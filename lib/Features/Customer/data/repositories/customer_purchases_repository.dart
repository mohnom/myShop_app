import 'package:flutter/foundation.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CustomerPurchasesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<DebtItemModel>> fetchPurchasesForMerchant(int conectId) async {
    final response = await _supabase
        .from('Content')
        .select()
        .eq('ID_Conect', conectId)
        .order('Date', ascending: false);

    return (response as List<dynamic>)
        .map((item) => DebtItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<PaymentModel>> fetchPaymentsForMerchant(int conectId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select()
          .eq('ID_Conect', conectId)
          .order('date', ascending: false);

      return (response as List<dynamic>)
          .map((item) => PaymentModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('fetchPaymentsForMerchant warning: $e');
      return const [];
    }
  }

  /// حساب صافي الديون لقائمة من اتصالات connects بعد خصم الدفعات المسددة
  Future<double> fetchTotalDebtsForConnects(List<int> connectIds) async {
    if (connectIds.isEmpty) return 0.0;
    try {
      final purchases = await _supabase
          .from('Content')
          .select('ID_Conect, price, Quantity')
          .inFilter('ID_Conect', connectIds);

      final Map<int, double> grossByConnect = {};
      for (final p in purchases as List<dynamic>) {
        final item = p as Map<String, dynamic>;
        final cid = (item['ID_Conect'] as num?)?.toInt();
        if (cid == null) continue;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final qty = (item['Quantity'] as num?)?.toDouble() ?? 1.0;
        grossByConnect[cid] = (grossByConnect[cid] ?? 0.0) + (price * qty);
      }

      final Map<int, double> paidByConnect = {};
      try {
        final payments = await _supabase
            .from('payments')
            .select('ID_Conect, amount')
            .inFilter('ID_Conect', connectIds);
        for (final pay in payments as List<dynamic>) {
          final item = pay as Map<String, dynamic>;
          final cid = (item['ID_Conect'] as num?)?.toInt();
          if (cid == null) continue;
          final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
          paidByConnect[cid] = (paidByConnect[cid] ?? 0.0) + amt;
        }
      } catch (_) {}

      double netTotal = 0.0;
      for (final cid in connectIds) {
        final diff = (grossByConnect[cid] ?? 0.0) - (paidByConnect[cid] ?? 0.0);
        if (diff > 0) netTotal += diff;
      }
      return netTotal;
    } catch (_) {
      return 0.0;
    }
  }
}
