import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../entities/statistics/dashboard_statistics.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, DashboardStatistics>> getDashboard({
    String? startDate,
    String? endDate,
  });
}
