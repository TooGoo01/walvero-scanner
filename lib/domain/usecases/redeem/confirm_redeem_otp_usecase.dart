import 'package:dartz/dartz.dart';
import 'package:walveroScanner/domain/repositories/redeem_repository.dart' show RedeemRepository;

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/redeem/confirm_otp_response.dart';
import 'confirm_redeem_otp_usecase.dart' show ConfirmRedeemOtpParams;
import 'start_redeem_usecase.dart';

class ConfirmRedeemOtpUseCase
    implements UseCase<ConfirmOtpResponse, ConfirmRedeemOtpParams> {
  final RedeemRepository repository;

  ConfirmRedeemOtpUseCase(this.repository);

  @override
  Future<Either<Failure, ConfirmOtpResponse>> call(
      ConfirmRedeemOtpParams params) {
    return repository.confirmRedeemOtp(params);
  }
}
