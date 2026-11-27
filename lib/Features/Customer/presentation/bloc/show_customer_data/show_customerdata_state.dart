part of 'show_customerdata_cubit.dart';

@immutable
sealed class ShowCustomerdataState {}

final class ShowCustomerdataInitial extends ShowCustomerdataState {}

final class ShowCustomerdataLoading extends ShowCustomerdataState {}

final class ShowCustomerdataSucsess extends ShowCustomerdataState {
  final Map<String, dynamic> message;
  ShowCustomerdataSucsess(this.message);
}

final class ShowCustomerdataFailed extends ShowCustomerdataState {
  final String error;
  ShowCustomerdataFailed(this.error);
}
