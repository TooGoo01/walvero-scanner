import 'package:dartz/dartz.dart';
import 'package:walveroScanner/domain/entities/redeem/redeem_lookup_response.dart' show LookupCard;

import '../../../../core/error/failures.dart';
import '../../core/usecases/usecase.dart';
import '../entities/redeem/confirm_otp_response.dart';
import '../entities/redeem/program_ui_config.dart';
import '../entities/redeem/start_redeem_response.dart';
import '../usecases/redeem/get_lookup_bycode_usecase.dart';
import '../usecases/redeem/start_redeem_usecase.dart';

abstract class RedeemRepository {
 Future<Either<Failure, StartRedeemResponse>> startRedeem(
    StartRedeemParams params,
  );

  Future<Either<Failure, ConfirmOtpResponse>> confirmRedeemOtp(
    ConfirmRedeemOtpParams params,
  );
  Future<Either<Failure, ProgramUiConfig>> getRemoteUI();
  Future<Either<Failure, LookupCard>> getLookupCard(
    LookupCodeParams params,
  );

  
}