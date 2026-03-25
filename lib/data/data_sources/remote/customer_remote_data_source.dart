import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constant/strings.dart';
import '../../../core/error/exceptions.dart';
import '../../models/customer/customer_model.dart';
import '../../models/customer/transaction_model.dart';

abstract class CustomerRemoteDataSource {
  Future<List<CustomerModel>> getCustomers(String token);
  Future<List<TransactionModel>> getTransactionsByCustomer(String token, int customerId);
  Future<ReverseResultModel> reverseTransaction(String token, {
    required String orderId,
    required int transactionId,
    required String originalType,
    required String reason,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final http.Client client;
  CustomerRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CustomerModel>> getCustomers(String token) async {
    final uri = Uri.parse('$baseUrl/api/Customer/List');
    final response = await client.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == false) {
        throw ServerException();
      }
      return customerListFromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCustomer(String token, int customerId) async {
    final uri = Uri.parse('$baseUrl/api/Transaction/ByCustomer').replace(
      queryParameters: {'customerId': customerId.toString()},
    );
    final response = await client.get(uri, headers: _headers(token)).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map<String, dynamic> && decoded['success'] == false) {
        throw ServerException();
      }
      return transactionListFromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<ReverseResultModel> reverseTransaction(String token, {
    required String orderId,
    required int transactionId,
    required String originalType,
    required String reason,
  }) async {
    final uri = Uri.parse('$baseUrl/api/Transaction/Reverse');
    final body = json.encode({
      'orderId': orderId,
      'transactionId': transactionId,
      'originalType': originalType,
      'reason': reason,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });

    final response = await client.post(uri, headers: _headers(token), body: body).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (decoded['success'] == false || decoded['data'] == null) {
        throw ServerException();
      }
      return reverseResultFromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
}
