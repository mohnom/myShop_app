import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'delete_merchant_state.dart';

class DeleteMerchantCubit extends Cubit<DeleteMerchantState> {
  DeleteMerchantCubit() : super(DeleteMerchantInitial());

  /// فك الارتباط بالمتجر فقط في حال كان الرصيد المتبقي صفراً لحماية حقوق التاجر
  Future<void> deleteMerchant(int conectId) async {
    emit(DeleteMerchantLoading());
    try {
      final supabase = Supabase.instance.client;

      // التحقق المحاسبي: حساب إجمالي المشتريات والمدفوعات قبل السماح بالحذف
      final purchases = await supabase
          .from('Content')
          .select('price, Quantity')
          .eq('ID_Conect', conectId);

      double grossTotal = 0.0;
      for (final row in purchases as List<dynamic>) {
        final item = row as Map<String, dynamic>;
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final qty = (item['Quantity'] as num?)?.toInt() ?? 1;
        grossTotal += price * qty;
      }

      double totalPaid = 0.0;
      try {
        final payments = await supabase
            .from('payments')
            .select('amount')
            .eq('ID_Conect', conectId);
        for (final row in payments as List<dynamic>) {
          final p = row as Map<String, dynamic>;
          totalPaid += (p['amount'] as num?)?.toDouble() ?? 0.0;
        }
      } catch (_) {}

      final remainingDebt = grossTotal - totalPaid;
      if (remainingDebt > 0.01) {
        emit(
          DeleteMerchantFailed(
            error:
                'لا يمكن حذف المتجر لوجود مديونية متبقية بقيمة ${remainingDebt.toStringAsFixed(2)} ر.ي. يرجى تسديد الحساب لدى التاجر أولاً.',
          ),
        );
        return;
      }

      await supabase.from('connects').delete().eq('id', conectId);
      emit(DeleteMerchantSuccess());
    } catch (e) {
      debugPrint('deleteMerchant error: $e');
      emit(
        DeleteMerchantFailed(
          error: 'تعذر حذف المتجر حالياً، تحقق من اتصال الإنترنت',
        ),
      );
    }
  }
}
