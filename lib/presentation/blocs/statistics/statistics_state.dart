part of 'statistics_bloc.dart';

@immutable
abstract class StatisticsState extends Equatable {}

class StatisticsInitial extends StatisticsState {
  @override
  List<Object> get props => [];
}

class StatisticsLoading extends StatisticsState {
  @override
  List<Object> get props => [];
}

class StatisticsLoaded extends StatisticsState {
  final DashboardStatistics statistics;
  StatisticsLoaded(this.statistics);
  @override
  List<Object> get props => [statistics];
}

class StatisticsError extends StatisticsState {
  final Failure failure;
  StatisticsError(this.failure);
  @override
  List<Object> get props => [failure];
}
