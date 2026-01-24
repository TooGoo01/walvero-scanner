import 'package:dartz/dartz.dart';
import 'package:walveroScanner/data/data_sources/remote/redeem_remote_data_source.dart' show RedeemRemoteDataSource;
import 'package:walveroScanner/domain/entities/redeem/program_ui_config.dart';
import 'package:walveroScanner/domain/entities/redeem/redeem_lookup_response.dart' show LookupCard;
import 'package:walveroScanner/domain/repositories/redeem_repository.dart' show RedeemRepository;


import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/redeem/confirm_otp_response.dart';
import '../../domain/entities/redeem/start_redeem_response.dart';
import '../../domain/usecases/redeem/start_redeem_usecase.dart';
import '../data_sources/local/user_local_data_source.dart';

class RedeemRepositoryImpl implements RedeemRepository {
  final RedeemRemoteDataSource remoteDataSource;
 
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  RedeemRepositoryImpl({
    required this.remoteDataSource,
    
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  
   

  @override
  Future<Either<Failure, ProgramUiConfig>> getRemoteUI() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    try {
      final remoteProduct = await remoteDataSource.uiConfig(
        token,
      );
     
      return Right(remoteProduct);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

   @override
  Future<Either<Failure, LookupCard>> getLookupCard(LookupCodeParams) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    final token = await userLocalDataSource.getToken();
    if (token.isEmpty) {
      return Left(AuthenticationFailure());
    }
    try {
      final remoteProduct = await remoteDataSource.lookupCode(LookupCodeParams,
        token
      );
     
      return Right(remoteProduct);
    } on Failure catch (failure) {
      return Left(failure);
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
    try {
      final result = await remoteDataSource.startRedeem(params,token);
      return Right(result);
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
    try {
      final result = await remoteDataSource.confirmRedeemOtp(params,token);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
 
}
