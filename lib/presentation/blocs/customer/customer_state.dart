part of 'customer_bloc.dart';

@immutable
abstract class CustomerState extends Equatable {}

class CustomerInitial extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomersLoading extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomersLoaded extends CustomerState {
  final List<Customer> customers;
  CustomersLoaded(this.customers);
  @override
  List<Object> get props => [customers];
}

class TransactionsLoading extends CustomerState {
  @override
  List<Object> get props => [];
}

class TransactionsLoaded extends CustomerState {
  final List<Transaction> transactions;
  TransactionsLoaded(this.transactions);
  @override
  List<Object> get props => [transactions];
}

class ReverseLoading extends CustomerState {
  @override
  List<Object> get props => [];
}

class ReverseSuccess extends CustomerState {
  final ReverseResult result;
  ReverseSuccess(this.result);
  @override
  List<Object> get props => [result];
}

class CustomerError extends CustomerState {
  final Failure failure;
  CustomerError(this.failure);
  @override
  List<Object> get props => [failure];
}

class ReverseError extends CustomerState {
  final Failure failure;
  ReverseError(this.failure);
  @override
  List<Object> get props => [failure];
}
