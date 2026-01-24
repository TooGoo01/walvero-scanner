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
  });
factory UserModel.empty() =>  UserModel(
        id: '',
        userName: '',
        firstName: '',
        lastName:  '',
        email: '',
        expiration: DateTime.parse('2022-05-10T08:30:00Z'),

        phone: '',
        tenantId: null,
        programId: null,
        roles: 
            const [],
        image: null,
        googleLogoUrl: null,
      );
  /// Burda birbaşa **`data` obyektini** gözləyirik:
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
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'].toString(),
        userName: json['userName'] as String? ?? '',
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        expiration:  DateTime.parse(json['expiration'] as String),

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
        image: null, // backend hələ image göndərmir, gələcəkdə əlavə edə bilərsən
        googleLogoUrl: json['googleLogoUrl'] != null
            ? (json['googleLogoUrl'] as String).startsWith('http')
                ? json['googleLogoUrl'] as String
                : 'https://walvero.com${json['googleLogoUrl'] as String}'
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'expiration':  expiration.toIso8601String(),
        'phone': phone,
        'tenantId': tenantId,
        'programId': programId,
        'roles': roles,
        'image': image,
        'googleLogoUrl': googleLogoUrl,
      };
        
}
