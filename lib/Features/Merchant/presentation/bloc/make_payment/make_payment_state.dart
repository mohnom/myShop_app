part of 'make_payment_cubit.dart';

@immutable
sealed class MakePaymentState {}

final class MakePaymentInitial extends MakePaymentState {}

final class MakePaymentLoading extends MakePaymentState {}

final class MakePaymentSuccess extends MakePaymentState {}

final class MakePaymentFailed extends MakePaymentState {
  final String error;
  MakePaymentFailed(this.error);
}
