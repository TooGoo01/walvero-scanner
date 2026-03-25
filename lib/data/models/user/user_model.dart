import 'dart:convert';

import '../../../domain/entities/user/user.dart';

UserModel userModelFromJson(String str) =>
    UserModel.fromJson(json.decode(str) as Map<String, dynamic>);

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.userName,
    required super.firstName,
    required super.lastName,
    required super.email,
    required super.expiration,
    super.phone,
    super.tenantId,
    super.programId,
    super.roles = const [],
    super.image,
    super.googleLogoUrl,
    super.refreshToken,
    super.refreshTokenExpiration,
    super.programs = const [],
  });

  factory UserModel.empty() => UserModel(
        id: '',
        userName: '',
        firstName: '',
        lastName: '',
        email: '',
        expiration: DateTime.parse('2022-05-10T08:30:00Z'),
        phone: '',
        tenantId: null,
        programId: null,
        roles: const [],
        image: null,
        googleLogoUrl: null,
        refreshToken: null,
        refreshTokenExpiration: null,
        programs: const [],
      );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        userName: json['userName'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        expiration: DateTime.parse(json['expiration'] as String),
        phone: json['phone'] as String?,
        tenantId: json['tenantId'] == null
            ? null
            : int.tryParse(json['tenantId'].toString()),
        programId: json['programId'] == null
            ? null
            : int.tryParse(json['programId'].toString()),
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        image: null,
        googleLogoUrl: json['googleLogoUrl'] != null
            ? (json['googleLogoUrl'] as String).startsWith('http')
                ? json['googleLogoUrl'] as String
                : 'https://walvero.com${json['googleLogoUrl'] as String}'
            : null,
        refreshToken: json['refreshToken'] as String?,
        refreshTokenExpiration: json['refreshTokenExpiration'] != null
            ? DateTime.parse(json['refreshTokenExpiration'] as String)
            : null,
        programs: (json['programs'] as List<dynamic>?)
                ?.map((e) => ProgramSummary.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'expiration': expiration.toIso8601String(),
        'phone': phone,
        'tenantId': tenantId,
        'programId': programId,
        'roles': roles,
        'image': image,
        'googleLogoUrl': googleLogoUrl,
        'refreshToken': refreshToken,
        'refreshTokenExpiration': refreshTokenExpiration?.toIso8601String(),
        'programs': programs
            .map((p) => <String, dynamic>{
                  'id': p.id,
                  'programName': p.programName,
                  'programType': p.programType,
                })
            .toList(),
      };
}
