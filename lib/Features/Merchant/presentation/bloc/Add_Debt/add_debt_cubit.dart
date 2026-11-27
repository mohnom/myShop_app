import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/data/repositories/purchases_repository.dart';
import 'package:myshop/core/services/push_notification_sender.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'add_debt_state.dart';

class AddDebtCubit extends Cubit<AddDebtState> {
  AddDebtCubit() : super(AddDebtInitial());

  final PurchasesRepository _repository = PurchasesRepository();

  Future<void> addDebt(
    String nameProduct,
    double price,
    int idConect,
    int quantity, {
    String? note,
  }) async {
    final supabase = Supabase.instance.client;
    emit(AddDebtLoading());
    try {
      await supabase.from('Content').insert({
        'NameProduct': nameProduct,
        'price': price,
        'ID_Conect': idConect,
        'Quantity': quantity,
        'Date': DateTime.now().toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
      });
      emit(AddDebtSuccess());

      PushNotificationSender.instance.notifyCustomerOfNewSale(
        conectId: idConect,
        productName: nameProduct,
        price: price,
        quantity: quantity,
      );
    } catch (e) {
      debugPrint('addDebt error: $e');
      emit(AddDebtFailed('فشلت عملية حفظ المنتج، تحقق من الاتصال'));
    }
  }

  Future<void> updateDebt({
    required int purchaseId,
    required String nameProduct,
    required double price,
    required int quantity,
    String? note,
  }) async {
    emit(AddDebtLoading());
    try {
      await _repository.updatePurchase(
        purchaseId: purchaseId,
        nameProduct: nameProduct,
        price: price,
        quantity: quantity,
        note: note,
      );
      emit(AddDebtSuccess());
    } catch (e) {
      debugPrint('updateDebt error: $e');
      emit(AddDebtFailed('تعذر تعديل العملية، حاول مجدداً'));
    }
  }
}
