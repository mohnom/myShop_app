import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'show_merchonts_state.dart';

class ShowMerchontsCubit extends Cubit<ShowMerchontsState> {
  ShowMerchontsCubit() : super(ShowMerchontsInitial());

  Future<void> showMerchonts({required String userId}) async {
    emit(ShowMerchontsLoading());
    try {
      final supabase = Supabase.instance.client;
      final customerResponse = await supabase
          .from('cutomers')
          .select('id')
          .eq('customers_id_fkey', userId)
          .maybeSingle();

      if (customerResponse == null) {
        emit(
          ShowMerchontsFailed(errMessage: 'لم يتم العثور على بيانات العميل'),
        );
        return;
      }

      final int customerId = (customerResponse['id'] as num).toInt();

      final response = await supabase
          .from('connects')
          .select('*')
          .eq('ID_customer', customerId);

      final connectsList = List<Map<String, dynamic>>.from(response);
      if (connectsList.isEmpty) {
        emit(ShowMerchontsSuccess(merchants: const [], totalDebtAll: 0.0));
        return;
      }

      final connectIds = connectsList
          .map<int?>((m) => (m['id'] as num?)?.toInt())
          .whereType<int>()
          .toList();

      final Map<int, double> grossByConnect = {};
      final Map<int, DateTime> lastDateByConnect = {};
      final Map<int, double> paidByConnect = {};

      if (connectIds.isNotEmpty) {
        final purchases = await supabase
            .from('Content')
            .select('ID_Conect, price, Quantity, Date')
            .inFilter('ID_Conect', connectIds);

        for (final row in purchases as List<dynamic>) {
          final item = row as Map<String, dynamic>;
          final cid = (item['ID_Conect'] as num?)?.toInt();
          if (cid == null) continue;
          final price = (item['price'] as num?)?.toDouble() ?? 0.0;
          final qty = (item['Quantity'] as num?)?.toInt() ?? 1;
          grossByConnect[cid] = (grossByConnect[cid] ?? 0.0) + (price * qty);

          final rawDate = item['Date'] as String?;
          if (rawDate != null) {
            final parsed = DateTime.tryParse(rawDate);
            if (parsed != null) {
              final existing = lastDateByConnect[cid];
              if (existing == null || parsed.isAfter(existing)) {
                lastDateByConnect[cid] = parsed;
              }
            }
          }
        }

        try {
          final payments = await supabase
              .from('payments')
              .select('ID_Conect, amount')
              .inFilter('ID_Conect', connectIds);
          for (final row in payments as List<dynamic>) {
            final item = row as Map<String, dynamic>;
            final cid = (item['ID_Conect'] as num?)?.toInt();
            if (cid == null) continue;
            final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
            paidByConnect[cid] = (paidByConnect[cid] ?? 0.0) + amt;
          }
        } catch (_) {}
      }

      double totalAll = 0.0;
      final enriched = connectsList.map((m) {
        final cid = (m['id'] as num?)?.toInt() ?? 0;
        final gross = grossByConnect[cid] ?? 0.0;
        final paid = paidByConnect[cid] ?? 0.0;
        final net = (gross - paid) < 0 ? 0.0 : (gross - paid);
        totalAll += net;
        return {
          ...m,
          'net_debt': net,
          'last_purchase_date': lastDateByConnect[cid]?.toIso8601String(),
        };
      }).toList();

      emit(ShowMerchontsSuccess(merchants: enriched, totalDebtAll: totalAll));
    } catch (e) {
      debugPrint('showMerchonts error: $e');
      emit(
        ShowMerchontsFailed(errMessage: 'تعذر جلب المتاجر، تحقق من الإنترنت'),
      );
    }
  }
}
