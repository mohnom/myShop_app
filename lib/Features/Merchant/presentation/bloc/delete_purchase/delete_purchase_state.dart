part of 'delete_purchase_cubit.dart';

abstract class DeletePurchaseState {}

class DeletePurchaseInitial extends DeletePurchaseState {}

class DeletePurchaseLoading extends DeletePurchaseState {}

class DeletePurchaseSuccess extends DeletePurchaseState {}

class DeletePurchaseFailed extends DeletePurchaseState {
  final String error;
  DeletePurchaseFailed(this.error);
}
