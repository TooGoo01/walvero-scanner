import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/statistics/dashboard_statistics.dart';
import '../../repositories/statistics_repository.dart';

class GetDashboardStatisticsUseCase
    implements UseCase<DashboardStatistics, DashboardParams> {
  final StatisticsRepository repository;
  GetDashboardStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, DashboardStatistics>> call(
      DashboardParams params) async {
    return await repository.getDashboard(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class DashboardParams {
  final String? startDate;
  final String? endDate;

  const DashboardParams({this.startDate, this.endDate});
}
