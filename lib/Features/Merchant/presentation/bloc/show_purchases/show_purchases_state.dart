part of 'show_purchases_cubit.dart';

abstract class ShowPurchasesState {}

class ShowPurchasesInitial extends ShowPurchasesState {}

class ShowPurchasesLoading extends ShowPurchasesState {}

class ShowPurchasesSuccess extends ShowPurchasesState {
  final List<DebtItemModel> purchases;
  final List<PaymentModel> payments;
  final double grossTotal;
  final double totalPaid;
  final double remainingDebt;

  ShowPurchasesSuccess({
    required this.purchases,
    this.payments = const [],
    this.grossTotal = 0.0,
    this.totalPaid = 0.0,
    this.remainingDebt = 0.0,
  });
}

class ShowPurchasesEmpty extends ShowPurchasesState {}

class ShowPurchasesFailed extends ShowPurchasesState {
  final String error;
  ShowPurchasesFailed(this.error);
}
