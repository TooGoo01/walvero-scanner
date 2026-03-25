import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/customer/customer.dart';
import '../../../domain/entities/customer/transaction.dart';
import '../../../domain/usecases/customer/get_customers_usecase.dart';
import '../../../domain/usecases/customer/get_customer_transactions_usecase.dart';
import '../../../domain/usecases/customer/reverse_transaction_usecase.dart';

part 'customer_event.dart';
part 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase _getCustomersUseCase;
  final GetCustomerTransactionsUseCase _getTransactionsUseCase;
  final ReverseTransactionUseCase _reverseTransactionUseCase;

  CustomerBloc(
    this._getCustomersUseCase,
    this._getTransactionsUseCase,
    this._reverseTransactionUseCase,
  ) : super(CustomerInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
    on<LoadCustomerTransactions>(_onLoadTransactions);
    on<ReverseTransactionEvent>(_onReverseTransaction);
  }

  FutureOr<void> _onLoadCustomers(
      LoadCustomers event, Emitter<CustomerState> emit) async {
    try {
      emit(CustomersLoading());
      final result = await _getCustomersUseCase(NoParams());
      result.fold(
        (failure) => emit(CustomerError(failure)),
        (customers) => emit(CustomersLoaded(customers)),
      );
    } catch (e) {
      emit(CustomerError(ExceptionFailure()));
    }
  }

  FutureOr<void> _onLoadTransactions(
      LoadCustomerTransactions event, Emitter<CustomerState> emit) async {
    try {
      emit(TransactionsLoading());
      final result = await _getTransactionsUseCase(event.customerId);
      result.fold(
        (failure) => emit(CustomerError(failure)),
        (transactions) => emit(TransactionsLoaded(transactions)),
      );
    } catch (e) {
      emit(CustomerError(ExceptionFailure()));
    }
  }

  FutureOr<void> _onReverseTransaction(
      ReverseTransactionEvent event, Emitter<CustomerState> emit) async {
    try {
      emit(ReverseLoading());
      final result = await _reverseTransactionUseCase(
        ReverseTransactionParams(
          orderId: event.orderId,
          transactionId: event.transactionId,
          originalType: event.originalType,
          reason: event.reason,
        ),
      );
      result.fold(
        (failure) => emit(ReverseError(failure)),
        (reverseResult) => emit(ReverseSuccess(reverseResult)),
      );
    } catch (e) {
      emit(ReverseError(ExceptionFailure()));
    }
  }
}
