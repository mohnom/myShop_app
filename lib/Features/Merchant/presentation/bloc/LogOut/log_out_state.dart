part of 'log_out_cubit.dart';

@immutable
sealed class LogOutState {}

final class LogOutInitial extends LogOutState {}

final class LogOutLoading extends LogOutState {}

final class LogOutSucesses extends LogOutState {
  final String message;
  LogOutSucesses(this.message);
}

final class LogOutFailed extends LogOutState {
  final String error;
  LogOutFailed(this.error);
}
