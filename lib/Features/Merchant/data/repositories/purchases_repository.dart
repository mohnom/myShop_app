import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PurchasesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// جلب جميع مشتريات عميل معين مرتبة من الأحدث للأقدم
  Future<List<DebtItemModel>> fetchPurchases(int conectId) async {
    final response = await _supabase
        .from('Content')
        .select()
        .eq('ID_Conect', conectId)
        .order('Date', ascending: false);

    return (response as List<dynamic>)
        .map((item) => DebtItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// تعديل عملية بيع موجودة
  Future<void> updatePurchase({
    required int purchaseId,
    required String nameProduct,
    required double price,
    required int quantity,
    String? note,
  }) async {
    await _supabase
        .from('Content')
        .update({
          'NameProduct': nameProduct,
          'price': price,
          'Quantity': quantity,
          'note': (note == null || note.isEmpty) ? null : note,
        })
        .eq('id', purchaseId);
  }

  /// حذف منتج/عملية بيع بمعرفه
  Future<void> deletePurchase(int purchaseId) async {
    await _supabase.from('Content').delete().eq('id', purchaseId);
  }

  /// حساب إجمالي الديون بعد خصم المدفوعات إن وجدت
  double calculateTotalDebt(
    List<DebtItemModel> purchases, [
    double totalPayments = 0.0,
  ]) {
    final total = purchases.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final remaining = total - totalPayments;
    return remaining < 0 ? 0.0 : remaining;
  }

  /// جلب آخر عملية بيع لعميل معين
  Future<DebtItemModel?> fetchLastPurchase(int conectId) async {
    final response = await _supabase
        .from('Content')
        .select()
        .eq('ID_Conect', conectId)
        .order('Date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return DebtItemModel.fromJson(response);
  }
}
