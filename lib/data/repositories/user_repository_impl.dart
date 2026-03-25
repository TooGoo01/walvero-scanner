import 'package:dartz/dartz.dart';
import 'package:walveroScanner/core/usecases/usecase.dart' show NoParams;

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/user_remote_data_source.dart';
import '../models/user/authentication_response_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  Future<void> _saveAuthResponse(AuthenticationResponseModel response) async {
    await localDataSource.saveToken(response.token);
    await localDataSource.saveUser(response.user);
    if (response.refreshToken != null &&
        response.refreshTokenExpiration != null) {
      await localDataSource.saveRefreshToken(
        response.refreshToken!,
        response.refreshTokenExpiration!,
      );
    }
    // Save default programId so API calls include X-Program-Id from start
    final defaultProgramId = response.user.programId;
    if (defaultProgramId != null) {
      await localDataSource.saveSelectedProgramId(defaultProgramId);
    }
  }

  @override
  Future<Either<Failure, User>> signIn(params) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final remoteResponse = await remoteDataSource.signIn(params);
      await _saveAuthResponse(remoteResponse);
      return Right(remoteResponse.user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ExceptionFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUp(params) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final remoteResponse = await remoteDataSource.signUp(params);
      await _saveAuthResponse(remoteResponse);
      return Right(remoteResponse.user);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, NoParams>> signOut() async {
    try {
      await localDataSource.clearCache();
      return Right(NoParams());
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getLocalUser() async {
    try {
      final user = await localDataSource.getUser();
      return Right(user);
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User>> refreshToken() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final storedRefreshToken = await localDataSource.getRefreshToken();
      final refreshExpiration =
          await localDataSource.getRefreshTokenExpiration();

      if (storedRefreshToken == null) {
        return Left(AuthenticationFailure());
      }

      if (refreshExpiration != null &&
          refreshExpiration.toUtc().isBefore(DateTime.now().toUtc())) {
        return Left(AuthenticationFailure());
      }

      final remoteResponse =
          await remoteDataSource.refreshToken(storedRefreshToken);
      await _saveAuthResponse(remoteResponse);
      return Right(remoteResponse.user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(AuthenticationFailure());
    }
  }
}
