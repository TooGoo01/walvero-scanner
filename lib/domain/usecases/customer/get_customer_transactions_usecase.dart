import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/customer/transaction.dart';
import '../../repositories/customer_repository.dart';

class GetCustomerTransactionsUseCase implements UseCase<List<Transaction>, int> {
  final CustomerRepository repository;
  GetCustomerTransactionsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Transaction>>> call(int customerId) async {
    return await repository.getTransactionsByCustomer(customerId);
  }
}
