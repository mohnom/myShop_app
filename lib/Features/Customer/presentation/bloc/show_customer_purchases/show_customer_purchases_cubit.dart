import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Customer/data/repositories/customer_purchases_repository.dart';
import 'package:myshop/Features/Merchant/data/models/debt_item_model.dart';
import 'package:myshop/Features/Merchant/data/models/payment_model.dart';

part 'show_customer_purchases_state.dart';

class ShowCustomerPurchasesCubit extends Cubit<ShowCustomerPurchasesState> {
  ShowCustomerPurchasesCubit() : super(ShowCustomerPurchasesInitial());

  final CustomerPurchasesRepository _repository = CustomerPurchasesRepository();

  Future<void> fetchPurchasesForMerchant(int conectId) async {
    emit(ShowCustomerPurchasesLoading());
    try {
      final results = await Future.wait([
        _repository.fetchPurchasesForMerchant(conectId),
        _repository.fetchPaymentsForMerchant(conectId),
      ]);

      final purchases = results[0] as List<DebtItemModel>;
      final payments = results[1] as List<PaymentModel>;

      final grossTotal = purchases.fold<double>(
        0.0,
        (sum, p) => sum + (p.price * p.quantity),
      );
      final totalPaid = payments.fold<double>(
        0.0,
        (sum, p) => sum + p.amount,
      );
      final remaining = (grossTotal - totalPaid) < 0
          ? 0.0
          : (grossTotal - totalPaid);

      emit(
        ShowCustomerPurchasesSuccess(
          purchases: purchases,
          payments: payments,
          grossPurchases: grossTotal,
          totalPaid: totalPaid,
          totalDebt: remaining,
        ),
      );
    } catch (e) {
      debugPrint('ShowCustomerPurchases error: $e');
      emit(ShowCustomerPurchasesFailed('تعذر تحميل كشف الحساب، تحقق من الشبكة'));
    }
  }
}
