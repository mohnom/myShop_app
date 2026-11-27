import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';
import 'package:myshop/Features/Merchant/data/repositories/payment_repository.dart';
import 'package:myshop/Features/Merchant/data/repositories/purchases_repository.dart';

part 'show_purchases_state.dart';

class ShowPurchasesCubit extends Cubit<ShowPurchasesState> {
  ShowPurchasesCubit() : super(ShowPurchasesInitial());

  final PurchasesRepository _repository = PurchasesRepository();
  final PaymentRepository _paymentRepository = PaymentRepository();

  Future<void> fetchPurchases(int conectId) async {
    emit(ShowPurchasesLoading());
    try {
      final results = await Future.wait([
        _repository.fetchPurchases(conectId),
        _paymentRepository.fetchPayments(conectId),
      ]);

      final purchases = results[0] as List<DebtItemModel>;
      final payments = results[1] as List<PaymentModel>;

      final grossTotal = purchases.fold<double>(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );
      final totalPaid = payments.fold<double>(
        0.0,
        (sum, p) => sum + p.amount,
      );
      final remainingDebt = _repository.calculateTotalDebt(
        purchases,
        totalPaid,
      );

      emit(
        ShowPurchasesSuccess(
          purchases: purchases,
          payments: payments,
          grossTotal: grossTotal,
          totalPaid: totalPaid,
          remainingDebt: remainingDebt,
        ),
      );
    } catch (e) {
      debugPrint('ShowPurchases error: $e');
      emit(ShowPurchasesFailed('تعذر تحميل سجل المعاملات، تحقق من الاتصال'));
    }
  }
}
