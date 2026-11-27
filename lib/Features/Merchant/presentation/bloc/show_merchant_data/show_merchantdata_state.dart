part of 'show_merchantdata_cubit.dart';

@immutable
sealed class ShowMerchantdataState {}

final class ShowMerchantdataInitial extends ShowMerchantdataState {}

final class ShowMerchantdataLoading extends ShowMerchantdataState {}

final class ShowMerchantdataSucsess extends ShowMerchantdataState {
  final Map<String, dynamic> message;
  ShowMerchantdataSucsess(this.message);
}

final class ShowMerchantdataFailed extends ShowMerchantdataState {
  final String error;
  ShowMerchantdataFailed(this.error);
}
