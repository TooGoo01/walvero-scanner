import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart' show Equatable;

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/redeem/confirm_otp_response.dart';
import '../../entities/redeem/start_redeem_response.dart';
import '../../repositories/redeem_repository.dart';

class StartRedeemUseCase
    implements UseCase<StartRedeemResponse, StartRedeemParams> {
  final RedeemRepository repository;

  StartRedeemUseCase(this.repository);

  @override
  Future<Either<Failure, StartRedeemResponse>> call(
      StartRedeemParams params) async {
    return await repository.startRedeem(params);
  }
}
class StartRedeemParams {
  final String code;
  final int delta;
  final String orderId;

  final String operationType; // 'earn' / 'pay'
  final String paymentMethod; // 'cash' / 'card'
  final int? spendCount; // YENİ: Free reward xərcləmə sayı (ProgressBased üçün)

  StartRedeemParams({
    required this.code,
    required this.delta,
    required this.orderId,
    required this.operationType,
    required this.paymentMethod,
    this.spendCount, // Null olarsa, points-based redeem
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'delta': delta,
        'orderId': orderId,
        'operationType': operationType,
        'paymentMethod': paymentMethod,
        'spendCount': spendCount, // Null göndərilə bilər
      };
}

class ConfirmRedeemOtpParams extends Equatable {
  final int requestId;
  final String otpCode;

  const ConfirmRedeemOtpParams({
    required this.requestId,
    required this.otpCode,
  });

  @override
  List<Object?> get props => [requestId, otpCode];
}
class ConfirmRedeemOtpUseCase
    implements UseCase<ConfirmOtpResponse, ConfirmRedeemOtpParams> {
  final RedeemRepository repository;

  ConfirmRedeemOtpUseCase(this.repository);

  @override
  Future<Either<Failure, ConfirmOtpResponse>> call(
      ConfirmRedeemOtpParams params) async {
    return await repository.confirmRedeemOtp(params);
  }
}
