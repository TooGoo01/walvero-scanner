// lib/presentation/blocs/redeem/redeem_event.dart
part of 'redeem_bloc.dart';

abstract class RedeemEvent extends Equatable {
  const RedeemEvent();

  @override
  List<Object?> get props => [];
}

class LoadUiConfig extends RedeemEvent {
  const LoadUiConfig();
}

class LookupByCodeRequested extends RedeemEvent {
  final LookupCodeParams params; // amount üçün lazım ola bilər

  const LookupByCodeRequested(this.params);

  @override
  List<Object?> get props => [params];
}
class RedeemStartRequested extends RedeemEvent {
  final StartRedeemParams params;

  const RedeemStartRequested(this.params);

  @override
  List<Object?> get props => [params];
}
class RedeemCustomerCleared extends RedeemEvent {
  const RedeemCustomerCleared();
}
/// 2-ci addım: OTP təsdiqi
class RedeemOtpSubmitted extends RedeemEvent {
  final ConfirmRedeemOtpParams params;

  const RedeemOtpSubmitted(this.params);

  @override
  List<Object?> get props => [params];
}