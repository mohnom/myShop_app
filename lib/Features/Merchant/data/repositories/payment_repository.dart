import 'package:flutter/foundation.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// تسجيل دفعة تسديد جديدة في جدول payments
  Future<void> makePayment({
    required int conectId,
    required double amount,
    String? note,
  }) async {
    await _supabase.from('payments').insert({
      'ID_Conect': conectId,
      'amount': amount,
      'date': DateTime.now().toIso8601String(),
      if (note != null && note.isNotEmpty) 'note': note,
    });
  }

  /// جلب سجل جميع الدفعات المسددة لعميل معين مرتبة من الأحدث للأقدم
  Future<List<PaymentModel>> fetchPayments(int conectId) async {
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
      debugPrint('fetchPayments warning: $e');
      return const [];
    }
  }

  /// حذف دفعة مسجلة بالخطأ
  Future<void> deletePayment(int paymentId) async {
    await _supabase.from('payments').delete().eq('id', paymentId);
  }

  /// جلب إجمالي المبالغ المسددة لعميل معين
  Future<double> getTotalPayments(int conectId) async {
    try {
      final response = await _supabase
          .from('payments')
          .select('amount')
          .eq('ID_Conect', conectId);

      if (response.isEmpty) return 0.0;

      return (response as List<dynamic>).fold<double>(
        0.0,
        (sum, item) =>
            sum + ((item as Map<String, dynamic>)['amount'] as num).toDouble(),
      );
    } catch (e) {
      debugPrint('getTotalPayments warning: $e');
      return 0.0;
    }
  }
}
