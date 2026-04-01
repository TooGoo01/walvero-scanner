import 'package:flutter/foundation.dart';
import 'package:dartz/dartz.dart';
import 'package:walveroScanner/data/data_sources/remote/redeem_remote_data_source.dart'
    show RedeemRemoteDataSource, ReverseTransactionParams;
import 'package:walveroScanner/domain/entities/redeem/program_ui_config.dart';
import 'package:walveroScanner/domain/entities/redeem/redeem_lookup_response.dart'
    show LookupCard;
import 'package:walveroScanner/domain/repositories/redeem_repository.dart'
    show RedeemRepository;

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/redeem/confirm_otp_response.dart';
import '../../domain/entities/redeem/start_redeem_response.dart';
import '../../domain/usecases/redeem/start_redeem_usecase.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/user_remote_data_source.dart';

class RedeemRepositoryImpl implements RedeemRepository {
  final RedeemRemoteDataSource remoteDataSource;
  final UserLocalDataSource userLocalDataSource;
  final UserRemoteDataSource userRemoteDataSource;
  final NetworkInfo networkInfo;

  RedeemRepositoryImpl({
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

  Future<int?> _getSelectedProgramId() async {
    return await userLocalDataSource.getSelectedProgramId();
  }

  @override
  Future<Either<Failure, ProgramUiConfig>> getRemoteUI() async {
    if (!await networkInfo.isConnected) {
      debugPrint('[UICONFIG] network not connected');
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      debugPrint('[UICONFIG] token is EMPTY');
      return Left(AuthenticationFailure());
    }
    final programId = await _getSelectedProgramId();
    debugPrint('[UICONFIG] token=${token.substring(0, 20)}..., programId=$programId');
    try {
      final result = await remoteDataSource.uiConfig(token, programId: programId);
      debugPrint('[UICONFIG] SUCCESS');
      return Right(result);
    } on UnauthorizedException {
      debugPrint('[UICONFIG] 401 Unauthorized, trying refresh...');
      final newToken = await _tryRefreshToken();
      if (newToken == null) {
        debugPrint('[UICONFIG] refresh FAILED');
        return Left(AuthenticationFailure());
      }
      debugPrint('[UICONFIG] refresh OK, retrying with new token');
      try {
        final result = await remoteDataSource.uiConfig(newToken, programId: programId);
        debugPrint('[UICONFIG] retry SUCCESS');
        return Right(result);
      } catch (e) {
        debugPrint('[UICONFIG] retry FAILED: $e');
        return Left(AuthenticationFailure());
      }
    } on Failure catch (failure) {
      debugPrint('[UICONFIG] Failure: $failure');
      return Left(failure);
    } catch (e) {
      debugPrint('[UICONFIG] EXCEPTION: $e');
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, LookupCard>> getLookupCard(lookupCodeParams) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    final programId = await _getSelectedProgramId();
    try {
      final result =
          await remoteDataSource.lookupCode(lookupCodeParams, token, programId: programId);
      return Right(result);
    } on UnauthorizedException {
      final newToken = await _tryRefreshToken();
      if (newToken == null) return Left(AuthenticationFailure());
      try {
        final result =
            await remoteDataSource.lookupCode(lookupCodeParams, newToken, programId: programId);
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

  @override
  Future<Either<Failure, StartRedeemResponse>> startRedeem(
    StartRedeemParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    final programId = await _getSelectedProgramId();
    try {
      final result = await remoteDataSource.startRedeem(params, token, programId: programId);
      return Right(result);
    } on UnauthorizedException {
      final newToken = await _tryRefreshToken();
      if (newToken == null) return Left(AuthenticationFailure());
      try {
        final result = await remoteDataSource.startRedeem(params, newToken, programId: programId);
        return Right(result);
      } catch (_) {
        return Left(AuthenticationFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ConfirmOtpResponse>> confirmRedeemOtp(
    ConfirmRedeemOtpParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    final programId = await _getSelectedProgramId();
    try {
      final result = await remoteDataSource.confirmRedeemOtp(params, token, programId: programId);
      return Right(result);
    } on UnauthorizedException {
      final newToken = await _tryRefreshToken();
      if (newToken == null) return Left(AuthenticationFailure());
      try {
        final result =
            await remoteDataSource.confirmRedeemOtp(params, newToken, programId: programId);
        return Right(result);
      } catch (_) {
        return Left(AuthenticationFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> reverseTransaction(
    ReverseTransactionParams params,
  ) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    final programId = await _getSelectedProgramId();
    try {
      final result = await remoteDataSource.reverseTransaction(params, token, programId: programId);
      return Right(result);
    } on UnauthorizedException {
      final newToken = await _tryRefreshToken();
      if (newToken == null) return Left(AuthenticationFailure());
      try {
        final result = await remoteDataSource.reverseTransaction(params, newToken, programId: programId);
        return Right(result);
      } catch (_) {
        return Left(AuthenticationFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
