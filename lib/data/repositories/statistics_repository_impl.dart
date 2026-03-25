import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/statistics/dashboard_statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/statistics_remote_data_source.dart';
import '../data_sources/remote/user_remote_data_source.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  final UserLocalDataSource userLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  StatisticsRepositoryImpl({
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
      if (refreshExp != null &&
          refreshExp.toUtc().isBefore(DateTime.now().toUtc())) {
        return null;
      }

      final response = await userRemoteDataSource.refreshToken(refreshToken);
      await userLocalDataSource.saveToken(response.token);
      await userLocalDataSource.saveUser(response.user);
      if (response.refreshToken != null &&
          response.refreshTokenExpiration != null) {
        await userLocalDataSource.saveRefreshToken(
          response.refreshToken!,
          response.refreshTokenExpiration!,
        );
      }
      return response.token;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Either<Failure, DashboardStatistics>> getDashboard({
    String? startDate,
    String? endDate,
  }) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    try {
      final result = await remoteDataSource.getDashboard(
        token,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on UnauthorizedException {
      final newToken = await _tryRefreshToken();
      if (newToken == null) return Left(AuthenticationFailure());
      try {
        final result = await remoteDataSource.getDashboard(
          newToken,
          startDate: startDate,
          endDate: endDate,
        );
        return Right(result);
      } catch (_) {
        return Left(AuthenticationFailure());
      }
    } on Failure catch (failure) {
      return Left(failure);
    } catch (_) {
      return Left(ServerFailure());
    }
  }
}
