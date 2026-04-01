import 'dart:convert';

import '../../../domain/entities/statistics/dashboard_statistics.dart';

DashboardStatisticsModel dashboardStatisticsModelFromJson(String str) {
  final Map<String, dynamic> decoded = json.decode(str);
  final data = decoded['data'] as Map<String, dynamic>? ?? decoded;
  return DashboardStatisticsModel.fromJson(data);
}

class DashboardStatisticsModel extends DashboardStatistics {
  const DashboardStatisticsModel({
    required super.totalTransactions,
    required super.totalPointsEarned,
    required super.totalPointsSpent,
    required super.uniqueCustomers,
    required super.dailyStats,
    super.recentTransactions,
  });

  factory DashboardStatisticsModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['dailyStats'] as List<dynamic>?)
            ?.map((e) => DailyStatModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final recentList = (json['recentTransactions'] as List<dynamic>?)
            ?.map((e) => RecentTransactionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DashboardStatisticsModel(
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      totalPointsEarned: json['totalPointsEarned'] as int? ?? 0,
      totalPointsSpent: json['totalPointsSpent'] as int? ?? 0,
      uniqueCustomers: json['uniqueCustomers'] as int? ?? 0,
      dailyStats: dailyList,
      recentTransactions: recentList,
    );
  }
}

class DailyStatModel extends DailyStat {
  const DailyStatModel({
    required super.date,
    required super.transactionCount,
    required super.pointsEarned,
    required super.pointsSpent,
  });

  factory DailyStatModel.fromJson(Map<String, dynamic> json) {
    return DailyStatModel(
      date: DateTime.parse(json['date'] as String),
      transactionCount: json['transactionCount'] as int? ?? 0,
      pointsEarned: json['pointsEarned'] as int? ?? 0,
      pointsSpent: json['pointsSpent'] as int? ?? 0,
    );
  }
}

class RecentTransactionModel extends RecentTransaction {
  const RecentTransactionModel({
    required super.id,
    required super.customerName,
    required super.type,
    required super.points,
    super.amount,
    required super.balanceAfter,
    required super.createdAt,
  });

  factory RecentTransactionModel.fromJson(Map<String, dynamic> json) {
    return RecentTransactionModel(
      id: json['id'] as int? ?? 0,
      customerName: json['customerName'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble(),
      balanceAfter: json['balanceAfter'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
