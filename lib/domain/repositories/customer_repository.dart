import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/customer/customer.dart';
import '../entities/customer/transaction.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers();
  Future<Either<Failure, List<Transaction>>> getTransactionsByCustomer(int customerId);
  Future<Either<Failure, ReverseResult>> reverseTransaction({
    required String orderId,
    required int transactionId,
    required String originalType,
    required String reason,
  });
  Future<Either<Failure, ReverseResult>> reverseLastByCard({
    required String cardNumber,
    required String reason,
  });
}
