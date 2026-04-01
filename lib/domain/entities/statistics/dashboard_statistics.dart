import 'package:equatable/equatable.dart';

class DashboardStatistics extends Equatable {
  final int totalTransactions;
  final int totalPointsEarned;
  final int totalPointsSpent;
  final int uniqueCustomers;
  final List<DailyStat> dailyStats;
  final List<RecentTransaction> recentTransactions;

  const DashboardStatistics({
    required this.totalTransactions,
    required this.totalPointsEarned,
    required this.totalPointsSpent,
    required this.uniqueCustomers,
    required this.dailyStats,
    this.recentTransactions = const [],
  });

  @override
  List<Object?> get props => [
        totalTransactions,
        totalPointsEarned,
        totalPointsSpent,
        uniqueCustomers,
        dailyStats,
        recentTransactions,
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

class RecentTransaction extends Equatable {
  final int id;
  final String customerName;
  final String type;
  final int points;
  final double? amount;
  final int balanceAfter;
  final DateTime createdAt;

  const RecentTransaction({
    required this.id,
    required this.customerName,
    required this.type,
    required this.points,
    this.amount,
    required this.balanceAfter,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, customerName, type, points, amount, balanceAfter, createdAt];
}
