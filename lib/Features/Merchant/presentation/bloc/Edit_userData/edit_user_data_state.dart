part of 'edit_user_data_cubit.dart';

@immutable
sealed class EditUserDataState {}

final class EditUserDataInitial extends EditUserDataState {}

final class EditUserDataLoading extends EditUserDataState {}

final class EditUserDataSucesses extends EditUserDataState {
  final String message;
  EditUserDataSucesses(this.message);
}

final class EditUserDataFalied extends EditUserDataState {
  final String error;
  EditUserDataFalied(this.error);
}
