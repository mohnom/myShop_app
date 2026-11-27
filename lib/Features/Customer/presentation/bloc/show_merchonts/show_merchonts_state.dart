part of 'show_merchonts_cubit.dart';

@immutable
sealed class ShowMerchontsState {}

final class ShowMerchontsInitial extends ShowMerchontsState {}

final class ShowMerchontsLoading extends ShowMerchontsState {}

final class ShowMerchontsSuccess extends ShowMerchontsState {
  final List<Map<String, dynamic>> merchants;
  final double totalDebtAll;

  ShowMerchontsSuccess({
    required this.merchants,
    this.totalDebtAll = 0.0,
  });
}

final class ShowMerchontsFailed extends ShowMerchontsState {
  final String errMessage;
  ShowMerchontsFailed({required this.errMessage});
}
