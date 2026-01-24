import 'dart:convert';

import 'user_model.dart';

AuthenticationResponseModel authenticationResponseModelFromJson(String str) {
  final Map<String, dynamic> decoded = json.decode(str);

  // backend cavabında token və user məlumatları "data" içindədir
  final data = decoded['data'] as Map<String, dynamic>;

  return AuthenticationResponseModel.fromJson(data);
}

String authenticationResponseModelToJson(AuthenticationResponseModel data) =>
    json.encode(data.toJson());

class AuthenticationResponseModel {
  final String token;
  final UserModel user;

  AuthenticationResponseModel({
    required this.token,
    required this.user,
  });

  /// Burada artıq "data" obyektini gözləyirik:
  /// {
  ///   "id": 5,
  ///   "tenantId": null,
  ///   "programId": 3,
  ///   "userName": "0773840809",
  ///   "firstName": "Elmir",
  ///   "lastName": "Levelup",
  ///   "email": "elmir.gasimzada@gmail.com",
  ///   "phone": null,
  ///   "token": "...",
  ///   "expiration": "...",
  ///   "roles": [...]
  /// }
  factory AuthenticationResponseModel.fromJson(Map<String, dynamic> json) =>
      AuthenticationResponseModel(
        token: json['token'] as String,
        // UserModel bütün user field-lərini json-dan götürür, token/expiration-ı sadəcə görməzlikdən gəlir
        user: UserModel.fromJson(json),
      );

  Map<String, dynamic> toJson() => {
        'token': token,
        'user': user.toJson(),
      };
}
