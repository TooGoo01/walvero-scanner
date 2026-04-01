import 'package:equatable/equatable.dart';

class ProgramSummary extends Equatable {
  final int id;
  final String programName;
  final int programType;

  const ProgramSummary({
    required this.id,
    required this.programName,
    required this.programType,
  });

  String get programTypeLabel {
    switch (programType) {
      case 1:
        return 'Progress';
      case 2:
        return 'Points';
      case 3:
        return 'Tier';
      default:
        return 'Unknown';
    }
  }

  factory ProgramSummary.fromJson(Map<String, dynamic> json) {
    return ProgramSummary(
      id: json['id'] as int,
      programName: json['programName'] as String? ?? '',
      programType: json['programType'] as int? ?? 1,
    );
  }

  @override
  List<Object?> get props => [id, programName, programType];
}

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
  final String? image;
  final String? googleLogoUrl;
  final String? refreshToken;
  final DateTime? refreshTokenExpiration;
  final List<ProgramSummary> programs;
  final String? tenantName;
  final DateTime? subscriptionExpiryDate;

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
    this.refreshToken,
    this.refreshTokenExpiration,
    this.programs = const [],
    this.tenantName,
    this.subscriptionExpiryDate,
  });

  bool get isTenantAdmin => roles.contains('Tenant Admin');
  bool get hasMultiplePrograms => programs.length > 1;

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
        refreshToken,
        refreshTokenExpiration,
        programs,
        tenantName,
        subscriptionExpiryDate,
      ];
}
