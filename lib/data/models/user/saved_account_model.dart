import 'dart:convert';
import '../../../domain/entities/user/user.dart';

class SavedAccount {
  final String userId;
  final String userName;
  final String firstName;
  final String lastName;
  final String? email;
  final String? image;
  final String token;
  final String? refreshToken;
  final DateTime? refreshTokenExpiration;
  final List<String> roles;
  final int? tenantId;
  final int? programId;

  SavedAccount({
    required this.userId,
    required this.userName,
    required this.firstName,
    required this.lastName,
    this.email,
    this.image,
    required this.token,
    this.refreshToken,
    this.refreshTokenExpiration,
    required this.roles,
    this.tenantId,
    this.programId,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'userName': userName,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'image': image,
        'token': token,
        'refreshToken': refreshToken,
        'refreshTokenExpiration': refreshTokenExpiration?.toIso8601String(),
        'roles': roles,
        'tenantId': tenantId,
        'programId': programId,
      };

  factory SavedAccount.fromJson(Map<String, dynamic> json) => SavedAccount(
        userId: json['userId'] as String,
        userName: json['userName'] as String,
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        email: json['email'] as String?,
        image: json['image'] as String?,
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String?,
        refreshTokenExpiration: json['refreshTokenExpiration'] != null
            ? DateTime.tryParse(json['refreshTokenExpiration'] as String)
            : null,
        roles: (json['roles'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        tenantId: json['tenantId'] as int?,
        programId: json['programId'] as int?,
      );

  String get displayName =>
      '$firstName $lastName'.trim().isEmpty ? userName : '$firstName $lastName'.trim();

  static List<SavedAccount> listFromJson(String jsonString) {
    final list = jsonDecode(jsonString) as List<dynamic>;
    return list.map((e) => SavedAccount.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<SavedAccount> accounts) {
    return jsonEncode(accounts.map((e) => e.toJson()).toList());
  }
}

/// Extension for converting SavedAccount to User entity for UI display
extension SavedAccountToUser on SavedAccount {
  User toUser() => User(
        id: userId,
        userName: userName,
        firstName: firstName,
        lastName: lastName,
        email: email ?? '',
        expiration: DateTime.now().add(const Duration(hours: 1)),
        roles: roles,
        tenantId: tenantId,
        programId: programId,
        image: image,
      );
}
