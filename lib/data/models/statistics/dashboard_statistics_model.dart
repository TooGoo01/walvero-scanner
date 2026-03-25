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
  });

  factory DashboardStatisticsModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['dailyStats'] as List<dynamic>?)
            ?.map((e) => DailyStatModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DashboardStatisticsModel(
      totalTransactions: json['totalTransactions'] as int? ?? 0,
      totalPointsEarned: json['totalPointsEarned'] as int? ?? 0,
      totalPointsSpent: json['totalPointsSpent'] as int? ?? 0,
      uniqueCustomers: json['uniqueCustomers'] as int? ?? 0,
      dailyStats: dailyList,
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
