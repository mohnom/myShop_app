import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/data/repositories/payment_repository.dart';
import 'package:myshop/core/services/push_notification_sender.dart';

part 'make_payment_state.dart';

class MakePaymentCubit extends Cubit<MakePaymentState> {
  MakePaymentCubit() : super(MakePaymentInitial());

  final PaymentRepository _paymentRepository = PaymentRepository();

  Future<void> processPayment({
    required int conectId,
    required double amount,
    required double currentDebt,
    String? note,
  }) async {
    emit(MakePaymentLoading());
    try {
      await _paymentRepository.makePayment(
        conectId: conectId,
        amount: amount,
        note: note,
      );

      final remaining = (currentDebt - amount) < 0
          ? 0.0
          : (currentDebt - amount);

      emit(MakePaymentSuccess());

      // إشعار الزبون فوراً بتسجيل دفعة التسديد والرصيد المتبقي
      PushNotificationSender.instance.notifyCustomerOfPayment(
        conectId: conectId,
        amount: amount,
        remainingDebt: remaining,
      );
    } catch (e) {
      debugPrint('MakePayment error: $e');
      emit(
        MakePaymentFailed(
          'تعذر تسجيل الدفعة، تأكد من اتصال الإنترنت ووجود جدول payments في قاعدة البيانات',
        ),
      );
    }
  }

  Future<void> deletePayment(int paymentId) async {
    try {
      await _paymentRepository.deletePayment(paymentId);
      emit(MakePaymentSuccess());
    } catch (e) {
      debugPrint('DeletePayment error: $e');
      emit(MakePaymentFailed('تعذر حذف سجل الدفعة'));
    }
  }
}
