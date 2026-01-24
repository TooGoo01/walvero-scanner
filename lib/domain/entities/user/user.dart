import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime expiration;

  final String? phone;
  final int? tenantId;
  final int? programId;
  final List<String> roles;
  final String? image; // gələcəkdə avatar / profil şəkli üçün
  final String? googleLogoUrl; // Google logo URL for avatar

  const User({
    required this.id,
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.expiration,

    this.phone,
    this.tenantId,
    this.programId,
    this.roles = const [],
    this.image,
    this.googleLogoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        userName,
        firstName,
        lastName,
        email,
        expiration,
        phone,
        tenantId,
        programId,
        roles,
        image,
        googleLogoUrl,
      ];
}
