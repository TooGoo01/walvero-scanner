import 'package:equatable/equatable.dart';

class DashboardStatistics extends Equatable {
  final int totalTransactions;
  final int totalPointsEarned;
  final int totalPointsSpent;
  final int uniqueCustomers;
  final List<DailyStat> dailyStats;

  const DashboardStatistics({
    required this.totalTransactions,
    required this.totalPointsEarned,
    required this.totalPointsSpent,
    required this.uniqueCustomers,
    required this.dailyStats,
  });

  @override
  List<Object?> get props => [
        totalTransactions,
        totalPointsEarned,
        totalPointsSpent,
        uniqueCustomers,
        dailyStats,
      ];
}

class DailyStat extends Equatable {
  final DateTime date;
  final int transactionCount;
  final int pointsEarned;
  final int pointsSpent;

  const DailyStat({
    required this.date,
    required this.transactionCount,
    required this.pointsEarned,
    required this.pointsSpent,
  });

  @override
  List<Object?> get props => [date, transactionCount, pointsEarned, pointsSpent];
}
