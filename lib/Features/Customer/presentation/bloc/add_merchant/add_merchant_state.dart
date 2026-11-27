part of 'add_merchant_cubit.dart';

@immutable
sealed class AddMerchantState {}

final class AddMerchantInitial extends AddMerchantState {}

final class AddMerchantLoading extends AddMerchantState {}

final class AddMerchantSuccess extends AddMerchantState {}

final class AddMerchantFailed extends AddMerchantState {
  final String errMessage;
  AddMerchantFailed( this.errMessage);
}
