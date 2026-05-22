import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../core/error/exceptions.dart';
import '../../../core/constant/strings.dart';
import '../../../domain/entities/redeem/confirm_otp_response.dart';
import '../../../domain/entities/redeem/start_redeem_response.dart';
import '../../../domain/usecases/redeem/get_lookup_bycode_usecase.dart';
import '../../../domain/usecases/redeem/start_redeem_usecase.dart';
import '../../models/redeem/confirm_otp_response_model.dart';
import '../../models/redeem/lookup_card_model.dart';
import '../../models/redeem/program_ui_config_model.dart';
import '../../models/redeem/start_redeem_response_model.dart';

abstract class RedeemRemoteDataSource {
  Future<ProgramUiConfigModel> uiConfig(String token, {int? programId});
  Future<LookupCardModel> lookupCode(LookupCodeParams params, String token, {int? programId});
  Future<StartRedeemResponse> startRedeem(StartRedeemParams params, String token, {int? programId});
  Future<ConfirmOtpResponse> confirmRedeemOtp(
    ConfirmRedeemOtpParams params,
    String token, {
    int? programId,
  });
  Future<Map<String, dynamic>> reverseTransaction(ReverseTransactionParams params, String token, {int? programId});
}

class ReverseTransactionParams {
  final int transactionId;
  final String orderId;
  final String originalType;
  final String reason;

  const ReverseTransactionParams({
    required this.transactionId,
    required this.orderId,
    required this.originalType,
    required this.reason,
  });
}

Map<String, String> _buildHeaders(String token, {int? programId, bool isPost = false}) {
  final headers = <String, String>{
    'Authorization': 'Bearer $token',
  };
  if (isPost) {
    headers['Content-Type'] = 'application/json';
    headers['Accept'] = 'application/json';
  } else {
    headers['Content-Type'] = 'application/json';
  }
  if (programId != null) {
    headers['X-Program-Id'] = programId.toString();
  }
  return headers;
}

class RedeemRemoteDataSourceImpl implements RedeemRemoteDataSource {
  final http.Client client;
  RedeemRemoteDataSourceImpl({required this.client});

  @override
  Future<ProgramUiConfigModel> uiConfig(token, {int? programId}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/Redeem/UiConfig'),
      headers: _buildHeaders(token, programId: programId),
    );
    if (response.statusCode == 200) {
      return programUiConfigModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<LookupCardModel> lookupCode(params, token, {int? programId}) async {
    final response = await client.get(
      Uri.parse(
          '$baseUrl/api/Redeem/LookupByCode?code=${params.code}&currentPoints=${params.balance}'),
      headers: _buildHeaders(token, programId: programId),
    );
    if (response.statusCode == 200) {
      // DEBUG: backend-dən hansı dəyər gəlir görmək üçün requireReceiptOcr-ı çap edirik
      try {
        final raw = json.decode(response.body) as Map<String, dynamic>;
        debugPrint('[LOOKUP] requireReceiptOcr=${raw['requireReceiptOcr']} '
            'success=${raw['success']} cardNumber=${raw['cardNumber']}');
      } catch (_) {}
      return lookupCardModelFromJson(response.body);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<StartRedeemResponse> startRedeem(
    StartRedeemParams params,
    token, {
    int? programId,
  }) async {
    final hasImage = params.receiptImage != null;
    // Backend [FromBody] JSON action = /api/redeem/start, [FromForm] multipart = /api/redeem/startwithreceipt
    final uri = Uri.parse(hasImage
        ? '$baseUrl/api/redeem/startwithreceipt'
        : '$baseUrl/api/redeem/start');

    late http.Response response;

    if (hasImage) {
      // multipart upload — backend RedeemController.StartWithReceipt
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      if (programId != null) {
        request.headers['X-Program-Id'] = programId.toString();
      }

      request.fields['code'] = params.code;
      request.fields['delta'] = params.delta.toString();
      request.fields['orderId'] = params.orderId;
      request.fields['mode'] = params.operationType;
      request.fields['paymentMethod'] = params.paymentMethod;
      if (params.spendCount != null) {
        request.fields['spendCount'] = params.spendCount.toString();
      }

      final file = params.receiptImage!;
      final mimeType = _guessImageMime(file.path);
      request.files.add(await http.MultipartFile.fromPath(
        'receiptImage',
        file.path,
        contentType: MediaType.parse(mimeType),
      ));

      final streamed = await client.send(request);
      response = await http.Response.fromStream(streamed);
    } else {
      final body = {
        'code': params.code,
        'delta': params.delta,
        'orderId': params.orderId,
        'mode': params.operationType,
        'paymentMethod': params.paymentMethod,
        'spendCount': params.spendCount,
      };

      response = await client.post(
        uri,
        headers: _buildHeaders(token, programId: programId, isPost: true),
        body: json.encode(body),
      );
    }

    debugPrint('[REDEEM] POST $uri status=${response.statusCode} bodyLen=${response.body.length}');
    if (response.statusCode != 200) {
      debugPrint('[REDEEM] body: ${response.body}');
    }

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return StartRedeemResponseModel.fromJson(jsonMap);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 400) {
      // Backend OCR mismatch / receipt validation failure — message-i propagate et
      String? serverMsg;
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] is String) {
          serverMsg = body['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: serverMsg);
    } else {
      // 415, 500, etc — body-də message varsa propagate et
      String? serverMsg;
      try {
        final body = json.decode(response.body);
        if (body is Map && body['message'] is String) {
          serverMsg = body['message'] as String;
        }
      } catch (_) {}
      throw ServerException(message: serverMsg ?? 'HTTP ${response.statusCode}');
    }
  }

  static String _guessImageMime(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  @override
  Future<ConfirmOtpResponse> confirmRedeemOtp(
    ConfirmRedeemOtpParams params,
    token, {
    int? programId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/redeem/confirm');

    final body = {
      'requestId': params.requestId,
      'code': params.otpCode,
    };

    final response = await client.post(
      uri,
      headers: _buildHeaders(token, programId: programId, isPost: true),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final jsonMap = json.decode(response.body) as Map<String, dynamic>;
      return ConfirmOtpResponseModel.fromJson(jsonMap);
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>> reverseTransaction(
    ReverseTransactionParams params,
    token, {
    int? programId,
  }) async {
    final uri = Uri.parse('$baseUrl/api/transaction/Reverse');

    final body = {
      'transactionId': params.transactionId,
      'orderId': params.orderId,
      'originalType': params.originalType,
      'reason': params.reason,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    final response = await client.post(
      uri,
      headers: _buildHeaders(token, programId: programId, isPost: true),
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw ServerException();
    }
  }
}
