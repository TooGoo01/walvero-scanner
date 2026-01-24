// lib/presentation/blocs/redeem/redeem_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:walveroScanner/domain/usecases/redeem/get_remote_uiconfig_usecase.dart' show GetRemoteUiconfigUsecase;

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../../domain/entities/redeem/program_ui_config.dart';
import '../../../domain/entities/redeem/redeem_lookup_response.dart';
import '../../../domain/usecases/redeem/get_lookup_bycode_usecase.dart';
import '../../../domain/usecases/redeem/start_redeem_usecase.dart';


part 'redeem_event.dart';
part 'redeem_state.dart';

class RedeemBloc extends Bloc<RedeemEvent, RedeemState> {
  final GetRemoteUiconfigUsecase _getRemoteUiconfigUsecase;
  final GetLookupUseCase _lookupByCodeUseCase;
 final StartRedeemUseCase _startRedeemUseCase;
  final ConfirmRedeemOtpUseCase _confirmRedeemOtpUseCase;
  RedeemBloc(
    this._getRemoteUiconfigUsecase,
    this._lookupByCodeUseCase,

    this._startRedeemUseCase,
    this._confirmRedeemOtpUseCase,

  ) : super(const RedeemInitial()) {
    on<LoadUiConfig>(_onLoadUiConfig);
    on<LookupByCodeRequested>(_onLookupByCode);

    on<RedeemStartRequested>(_onRedeemStartRequested);
    on<RedeemOtpSubmitted>(_onRedeemOtpSubmitted);
    on<RedeemCustomerCleared>(_onCutomerClear);


  }

  Future<void> _onLoadUiConfig(
    LoadUiConfig event,
    Emitter<RedeemState> emit,
  ) async {
    emit(RedeemLoading(
      config: state.config,
      customer: state.customer,
    ));

    final result = await _getRemoteUiconfigUsecase(NoParams());

    result.fold(
      (failure) => emit(RedeemError(
        config: state.config,
        customer: state.customer,
        failure: failure,
      )),
      (config) => emit(RedeemLoaded(
        config: config,
        customer: state.customer,
      )),
    );
  }

  Future<void> _onLookupByCode(
    LookupByCodeRequested event,
    Emitter<RedeemState> emit,
  ) async {
    // UiConfig artıq yüklənibsə saxlayırıq
    emit(RedeemLoading(
      config: state.config,
       customer: state.customer,
    ));

    final result = await _lookupByCodeUseCase(event.params
    );

    result.fold(
      (failure) => emit(RedeemError(
        config: state.config,
        customer: state.customer,
        failure: failure,
      )),
      (customer) => emit(RedeemLoaded(
        config: state.config!,
        customer: customer,
      )),
    );
  }
  Future<void> _onRedeemStartRequested(
    RedeemStartRequested event,
    Emitter<RedeemState> emit,
  ) async {
    emit(RedeemLoading(
      config: state.config,
      customer: state.customer,
    ));

    final result = await _startRedeemUseCase(event.params);

    result.fold(
      (failure) {
        emit(RedeemError(
          config: state.config,
          customer: state.customer,
          failure: failure,
        ));
      },
      (response) {
        if (!response.success) {
          emit(RedeemError(
            config: state.config,
            customer: state.customer,
           
          ));
          return;
        }

        if (response.requiresOtp && response.redeemRequestId != null) {
          emit(RedeemOtpRequired(
            redeemRequestId: response.redeemRequestId!,
            infoMessage: response.message,
            config: state.config,
            customer: state.customer,
          ));
        } else {
          emit(RedeemStartLoaded(
            config: state.config,
            customer: state.customer,
          ));
        }
      },
    );
  }
Future<void> _onCutomerClear(
    RedeemCustomerCleared event,
    Emitter<RedeemState> emit,
  ) async {
    emit(RedeemLoading(
      config: state.config
    ));
      emit(RedeemLoaded(
            config: state.config
           
          ));
  }

  Future<void> _onRedeemOtpSubmitted(
    RedeemOtpSubmitted event,
    Emitter<RedeemState> emit,
  ) async {
    emit(RedeemLoading(
      config: state.config,
      customer: state.customer,
    ));

    final result = await _confirmRedeemOtpUseCase(event.params);

    result.fold(
      (failure) {
        emit(RedeemError(
          config: state.config,
          customer: state.customer,
          failure: failure,
        ));
      },
      (response) {
        if (!response.success) {
          emit(RedeemError(
            config: state.config,
            customer: state.customer,
          
          ));
          return;
        }

        emit(RedeemStartLoaded(
          config: state.config,
          customer: state.customer,
        ));
      },
    );
  }
}
