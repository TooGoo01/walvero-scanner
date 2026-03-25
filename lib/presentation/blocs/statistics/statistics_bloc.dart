import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/statistics/dashboard_statistics.dart';
import '../../../domain/usecases/statistics/get_dashboard_statistics_usecase.dart';

part 'statistics_event.dart';
part 'statistics_state.dart';

class StatisticsBloc extends Bloc<StatisticsEvent, StatisticsState> {
  final GetDashboardStatisticsUseCase _getDashboardUseCase;

  StatisticsBloc(this._getDashboardUseCase) : super(StatisticsInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  FutureOr<void> _onLoadDashboard(
      LoadDashboard event, Emitter<StatisticsState> emit) async {
    try {
      emit(StatisticsLoading());
      final result = await _getDashboardUseCase(
        DashboardParams(
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
      result.fold(
        (failure) => emit(StatisticsError(failure)),
        (stats) => emit(StatisticsLoaded(stats)),
      );
    } catch (e) {
      emit(StatisticsError(ExceptionFailure()));
    }
  }
}
