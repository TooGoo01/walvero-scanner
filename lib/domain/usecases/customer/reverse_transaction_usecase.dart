import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/customer/transaction.dart';
import '../../repositories/customer_repository.dart';

class ReverseTransactionUseCase implements UseCase<ReverseResult, ReverseTransactionParams> {
  final CustomerRepository repository;
  ReverseTransactionUseCase(this.repository);

  @override
  Future<Either<Failure, ReverseResult>> call(ReverseTransactionParams params) async {
    return await repository.reverseTransaction(
      orderId: params.orderId,
      transactionId: params.transactionId,
      originalType: params.originalType,
      reason: params.reason,
    );
  }
}

class ReverseTransactionParams extends Equatable {
  final String orderId;
  final int transactionId;
  final String originalType;
  final String reason;

  const ReverseTransactionParams({
    required this.orderId,
    required this.transactionId,
    required this.originalType,
    required this.reason,
  });

  @override
  List<Object?> get props => [orderId, transactionId, originalType, reason];
}
