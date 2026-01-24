import 'dart:convert';

import 'package:http/http.dart' as http;
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
  Future<ProgramUiConfigModel> uiConfig(String token);
  Future<LookupCardModel> lookupCode(LookupCodeParams params,String token);
  Future<StartRedeemResponse> startRedeem(StartRedeemParams params,String token);
  Future<ConfirmOtpResponse> confirmRedeemOtp(
    ConfirmRedeemOtpParams params,
    String token
  );

}

class RedeemRemoteDataSourceImpl implements RedeemRemoteDataSource {
  final http.Client client;
  RedeemRemoteDataSourceImpl({required this.client});

  @override
  Future<ProgramUiConfigModel> uiConfig(token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/Redeem/UiConfig'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
     
    );
    if (response.statusCode == 200) {
      return programUiConfigModelFromJson(response.body);
    } else {
      throw ServerException();
    }
  }
 @override
  Future<LookupCardModel> lookupCode(params,token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/Redeem/LookupByCode?code=${params.code}&currentPoints=${params.balance}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    
    );
    if (response.statusCode == 200) {
      return lookupCardModelFromJson(response.body);
    } else {
      throw ServerException();
    }
  }
 @override
  Future<StartRedeemResponse> startRedeem(
    StartRedeemParams params,
    token
  ) async {
    final uri = Uri.parse('$baseUrl/api/redeem/start');

    final body = {
      'code': params.code,
      'delta': params.delta,
      'orderId': params.orderId,
      'mode': params.operationType,
      'paymentMethod': params.paymentMethod,
      'spendCount': params.spendCount, // Null göndərilə bilər
    };

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
          'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Start redeem failed');
    }

    final jsonMap = json.decode(response.body) as Map<String, dynamic>;
    return StartRedeemResponseModel.fromJson(jsonMap);
  }

  @override
  Future<ConfirmOtpResponse> confirmRedeemOtp(
    ConfirmRedeemOtpParams params,
    token
  ) async {
    final uri = Uri.parse('$baseUrl/api/redeem/confirm');

    final body = {
      'requestId': params.requestId,
      'code': params.otpCode,
    };

    final response = await client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
          'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Confirm OTP failed');
    }

    final jsonMap = json.decode(response.body) as Map<String, dynamic>;
    return ConfirmOtpResponseModel.fromJson(jsonMap);
  }
 
}
