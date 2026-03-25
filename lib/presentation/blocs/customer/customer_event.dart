part of 'customer_bloc.dart';

@immutable
abstract class CustomerEvent {}

class LoadCustomers extends CustomerEvent {}

class LoadCustomerTransactions extends CustomerEvent {
  final int customerId;
  LoadCustomerTransactions(this.customerId);
}

class ReverseTransactionEvent extends CustomerEvent {
  final String orderId;
  final int transactionId;
  final String originalType;
  final String reason;

  ReverseTransactionEvent({
    required this.orderId,
    required this.transactionId,
    required this.originalType,
    required this.reason,
  });
}
