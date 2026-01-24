// lib/presentation/blocs/redeem/redeem_state.dart

part of 'redeem_bloc.dart';

abstract class RedeemState extends Equatable {
  final ProgramUiConfig? config;
  final LookupCard? customer;
  final Failure? failure;

  const RedeemState({
    this.config,
    this.customer,
    this.failure,
  });

  @override
  List<Object?> get props => [config, customer, failure];
}

// İlk hal
class RedeemInitial extends RedeemState {
  const RedeemInitial() : super(
    config: null,
    customer: null,
    failure: null,
  );
}

// Loading halı
class RedeemLoading extends RedeemState {
  const RedeemLoading({
    ProgramUiConfig? config,
    LookupCard? customer,
  }) : super(
    config: config,
    customer: customer,
  );
}

// Uğurlu hal
class RedeemLoaded extends RedeemState {
  const RedeemLoaded({
    ProgramUiConfig? config,
    LookupCard? customer,
  }) : super(
    config: config,
    customer: customer,
  );
}
class RedeemStartLoaded extends RedeemState {
  const RedeemStartLoaded({
    ProgramUiConfig? config,
    LookupCard? customer,
  }) : super(
    config: config,
    
  );
}

// Xəta halı
class RedeemError extends RedeemState {
  const RedeemError({
    ProgramUiConfig? config,
    LookupCard? customer,
    Failure? failure,
  }) : super(
    config: config,
    customer: customer,
    failure: failure,
  );
}
class RedeemOtpRequired extends RedeemState {
  final int redeemRequestId;
  final String? infoMessage;

  const RedeemOtpRequired({
    required this.redeemRequestId,
    this.infoMessage,
    ProgramUiConfig? config,
    LookupCard? customer,
  }) : super(config: config);

  @override
  List<Object?> get props =>
      [...super.props, redeemRequestId, infoMessage];
}
