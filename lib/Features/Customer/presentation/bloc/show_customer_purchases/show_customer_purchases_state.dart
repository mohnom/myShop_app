part of 'show_customer_purchases_cubit.dart';

abstract class ShowCustomerPurchasesState {}

class ShowCustomerPurchasesInitial extends ShowCustomerPurchasesState {}

class ShowCustomerPurchasesLoading extends ShowCustomerPurchasesState {}

class ShowCustomerPurchasesSuccess extends ShowCustomerPurchasesState {
  final List<DebtItemModel> purchases;
  final List<PaymentModel> payments;
  final double grossPurchases;
  final double totalPaid;
  final double totalDebt;

  ShowCustomerPurchasesSuccess({
    required this.purchases,
    this.payments = const [],
    this.grossPurchases = 0.0,
    this.totalPaid = 0.0,
    required this.totalDebt,
  });
}

class ShowCustomerPurchasesEmpty extends ShowCustomerPurchasesState {}

class ShowCustomerPurchasesFailed extends ShowCustomerPurchasesState {
  final String error;
  ShowCustomerPurchasesFailed(this.error);
}
