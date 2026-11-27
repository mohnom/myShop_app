part of 'delete_merchant_cubit.dart';

@immutable
sealed class DeleteMerchantState {}

final class DeleteMerchantInitial extends DeleteMerchantState {}
final class DeleteMerchantLoading extends DeleteMerchantState {}
final class DeleteMerchantSuccess extends DeleteMerchantState {}
final class DeleteMerchantFailed extends DeleteMerchantState {

  DeleteMerchantFailed({required this.error});

    final String error;

    
}


