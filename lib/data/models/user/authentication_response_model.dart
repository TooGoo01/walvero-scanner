import 'dart:convert';

import 'user_model.dart';

AuthenticationResponseModel authenticationResponseModelFromJson(String str) {
  final Map<String, dynamic> decoded = json.decode(str);
  final data = decoded['data'] as Map<String, dynamic>;
  return AuthenticationResponseModel.fromJson(data);
}

String authenticationResponseModelToJson(AuthenticationResponseModel data) =>
    json.encode(data.toJson());

class AuthenticationResponseModel {
  final String token;
  final String? refreshToken;
  final DateTime? refreshTokenExpiration;
  final UserModel user;

  AuthenticationResponseModel({
    required this.token,
    required this.user,
    this.refreshToken,
    this.refreshTokenExpiration,
  });

  factory AuthenticationResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthenticationResponseModel(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String?,
        refreshTokenExpiration: json['refreshTokenExpiration'] != null
            ? DateTime.parse(json['refreshTokenExpiration'] as String)
            : null,
        user: UserModel.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'refreshToken': refreshToken,
        'refreshTokenExpiration': refreshTokenExpiration?.toIso8601String(),
        'user': user.toJson(),
      };
}
