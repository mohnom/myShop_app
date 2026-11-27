part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginCusomerSucsess extends LoginState {
  final String massege;
  LoginCusomerSucsess(this.massege);
}

final class LoginMerchontSucsess extends LoginState {
  final String massege;
  LoginMerchontSucsess(this.massege);
}

final class LoginFailure extends LoginState {
  final String error;
  LoginFailure(this.error);
}
