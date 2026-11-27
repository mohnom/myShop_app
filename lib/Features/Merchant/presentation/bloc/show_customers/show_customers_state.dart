part of 'show_customers_cubit.dart';

@immutable
sealed class ShowCustomersState {}

final class ShowCustomersInitial extends ShowCustomersState {}

final class ShowCustomersLoading extends ShowCustomersState {}

final class ShowCustomersSuccses extends ShowCustomersState {
  final List<Map<String, dynamic>> customers;
  final double totalReceivables;

  ShowCustomersSuccses({
    required this.customers,
    this.totalReceivables = 0.0,
  });
}

final class ShowCustomersFaild extends ShowCustomersState {
  final String error;
  ShowCustomersFaild({required this.error});
}
