part of 'statistics_bloc.dart';

@immutable
abstract class StatisticsEvent {}

class LoadDashboard extends StatisticsEvent {
  final String? startDate;
  final String? endDate;
  LoadDashboard({this.startDate, this.endDate});
}
