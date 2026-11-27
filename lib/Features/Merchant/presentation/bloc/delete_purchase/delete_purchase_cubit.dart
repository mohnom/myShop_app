import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myshop/Features/Merchant/data/repositories/purchases_repository.dart';

part 'delete_purchase_state.dart';

class DeletePurchaseCubit extends Cubit<DeletePurchaseState> {
  DeletePurchaseCubit() : super(DeletePurchaseInitial());

  final PurchasesRepository _repository = PurchasesRepository();

  Future<void> deletePurchase(int purchaseId) async {
    emit(DeletePurchaseLoading());
    try {
      await _repository.deletePurchase(purchaseId);
      emit(DeletePurchaseSuccess());
    } catch (e) {
      emit(DeletePurchaseFailed(e.toString()));
    }
  }
}
