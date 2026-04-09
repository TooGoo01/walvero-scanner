import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/customer/customer.dart';
import '../../domain/entities/customer/transaction.dart';
import '../../domain/repositories/customer_repository.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/customer_remote_data_source.dart';
import '../data_sources/remote/user_remote_data_source.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remoteDataSource;
  final UserLocalDataSource userLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  CustomerRepositoryImpl({
    required this.remoteDataSource,
    required this.userLocalDataSource,
    required this.userRemoteDataSource,
    required this.networkInfo,
  });

  Future<String?> _tryRefreshToken() async {
    try {
      final refreshToken = await userLocalDataSource.getRefreshToken();
      if (refreshToken == null) return null;

      final refreshExp = await userLocalDataSource.getRefreshTokenExpiration();
      if (refreshExp != null && refreshExp.toUtc().isBefore(DateTime.now().toUtc())) {
        return null;
      }

      final response = await userRemoteDataSource.refreshToken(refreshToken);
      await userLocalDataSource.saveToken(response.token);
      await userLocalDataSource.saveUser(response.user);
      if (response.refreshToken != null && response.refreshTokenExpiration != null) {
        await userLocalDataSource.saveRefreshToken(response.refreshToken!, response.refreshTokenExpiration!);
      }
      return response.token;
    } catch (_) {
      return null;
    }
  }

  Future<Either<Failure, T>> _withAuth<T>(Future<T> Function(String token) fn) async {
    if (!await networkInfo.isConnected) return Left(NetworkFailure());
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) return Left(AuthenticationFailure());

    try {
      return Right(await fn(token));
    } on UnauthorizedException {
      final newToken = await _tryRefreshToken();
      if (newToken == null) return Left(AuthenticationFailure());
      try {
        return Right(await fn(newToken));
      } catch (_) {
        return Left(AuthenticationFailure());
      }
    } on Failure catch (f) {
      return Left(f);
    } catch (_) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomers() =>
      _withAuth((token) => remoteDataSource.getCustomers(token));

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCustomer(int customerId) =>
      _withAuth((token) => remoteDataSource.getTransactionsByCustomer(token, customerId));

  @override
  Future<Either<Failure, ReverseResult>> reverseTransaction({
    required String orderId,
    required int transactionId,
    required String originalType,
    required String reason,
  }) =>
      _withAuth((token) => remoteDataSource.reverseTransaction(
            token,
            orderId: orderId,
            transactionId: transactionId,
            originalType: originalType,
            reason: reason,
          ));

  @override
  Future<Either<Failure, ReverseResult>> reverseLastByCard({
    required String cardNumber,
    required String reason,
  }) =>
      _withAuth((token) => remoteDataSource.reverseLastByCard(
            token,
            cardNumber: cardNumber,
            reason: reason,
          ));
}
