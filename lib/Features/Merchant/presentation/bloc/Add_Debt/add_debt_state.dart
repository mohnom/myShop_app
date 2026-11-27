part of 'add_debt_cubit.dart';

@immutable
sealed class AddDebtState {}

final class AddDebtInitial extends AddDebtState {}
final class AddDebtSuccess  extends AddDebtState {}
final class AddDebtFailed extends AddDebtState {
  final String error;
  AddDebtFailed(this.error);
}
final class AddDebtLoading extends AddDebtState {}

