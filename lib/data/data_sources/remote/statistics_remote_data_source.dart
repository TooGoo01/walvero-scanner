import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constant/strings.dart';
import '../../../core/error/exceptions.dart';
import '../../models/statistics/dashboard_statistics_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<DashboardStatisticsModel> getDashboard(
    String token, {
    String? startDate,
    String? endDate,
  });
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final http.Client client;
  StatisticsRemoteDataSourceImpl({required this.client});

  @override
  Future<DashboardStatisticsModel> getDashboard(
    String token, {
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final uri = Uri.parse('$baseUrl/api/Statistics/dashboard')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (decoded['success'] != true || decoded['data'] == null) {
        throw ServerException();
      }
      return dashboardStatisticsModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }
}
