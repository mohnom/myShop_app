import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'show_customers_state.dart';

class ShowCustomersCubit extends Cubit<ShowCustomersState> {
  ShowCustomersCubit() : super(ShowCustomersInitial());

  Future<void> showCustomers({required String userId}) async {
    emit(ShowCustomersLoading());

    try {
      final supabase = Supabase.instance.client;
      final merchantResponse = await supabase
          .from('merchont')
          .select('id,name')
          .eq('maerchont_id_fkey', userId)
          .maybeSingle();

      if (merchantResponse == null) {
        emit(ShowCustomersFaild(error: 'لا يوجد حساب تاجر مرتبط بهذا المستخدم'));
        return;
      }

      final connectsRaw = await supabase
          .from('connects')
          .select('*')
          .eq('ID_merchont', merchantResponse['id']);

      final connectsList = List<Map<String, dynamic>>.from(connectsRaw);
      if (connectsList.isEmpty) {
        emit(ShowCustomersSuccses(customers: const [], totalReceivables: 0.0));
        return;
      }

      final connectIds = connectsList
          .map<int?>((c) => (c['id'] as num?)?.toInt())
          .whereType<int>()
          .toList();

      // حساب مديونية كل عميل وإجمالي السوق باستعلام مجمع سريع
      final Map<int, double> purchasesByConnect = {};
      final Map<int, double> paymentsByConnect = {};

      if (connectIds.isNotEmpty) {
        final purchasesRows = await supabase
            .from('Content')
            .select('ID_Conect, price, Quantity')
            .inFilter('ID_Conect', connectIds);

        for (final row in purchasesRows as List<dynamic>) {
          final map = row as Map<String, dynamic>;
          final cid = (map['ID_Conect'] as num?)?.toInt();
          if (cid == null) continue;
          final price = (map['price'] as num?)?.toDouble() ?? 0.0;
          final qty = (map['Quantity'] as num?)?.toInt() ?? 1;
          purchasesByConnect[cid] =
              (purchasesByConnect[cid] ?? 0.0) + (price * qty);
        }

        try {
          final paymentRows = await supabase
              .from('payments')
              .select('ID_Conect, amount')
              .inFilter('ID_Conect', connectIds);

          for (final row in paymentRows as List<dynamic>) {
            final map = row as Map<String, dynamic>;
            final cid = (map['ID_Conect'] as num?)?.toInt();
            if (cid == null) continue;
            final amt = (map['amount'] as num?)?.toDouble() ?? 0.0;
            paymentsByConnect[cid] = (paymentsByConnect[cid] ?? 0.0) + amt;
          }
        } catch (_) {}
      }

      double totalReceivables = 0.0;
      final enrichedCustomers = connectsList.map((c) {
        final cid = (c['id'] as num?)?.toInt() ?? 0;
        final gross = purchasesByConnect[cid] ?? 0.0;
        final paid = paymentsByConnect[cid] ?? 0.0;
        final net = (gross - paid) < 0 ? 0.0 : (gross - paid);
        totalReceivables += net;
        return {
          ...c,
          'net_debt': net,
        };
      }).toList();

      // ترتيب العملاء: الأعلى مديونية أولاً لتسهيل المتابعة على التاجر
      enrichedCustomers.sort(
        (a, b) => ((b['net_debt'] as double?) ?? 0.0).compareTo(
          (a['net_debt'] as double?) ?? 0.0,
        ),
      );

      emit(
        ShowCustomersSuccses(
          customers: enrichedCustomers,
          totalReceivables: totalReceivables,
        ),
      );
    } catch (e) {
      debugPrint('ShowCustomers error: $e');
      emit(ShowCustomersFaild(error: 'تعذر جلب قائمة العملاء، تحقق من الاتصال'));
    }
  }
}
