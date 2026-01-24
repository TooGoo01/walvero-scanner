// lib/domain/entities/redeem/confirm_otp_response.dart
import 'package:equatable/equatable.dart';

class ConfirmOtpResponse extends Equatable {
  final bool success;
  final String? message;

  final int? loyaltyCardId;
  final int? appliedDelta;
  final int? oldPoints;
  final int? newPoints;
  final bool? isPending;

  const ConfirmOtpResponse({
    required this.success,
    this.message,
    this.loyaltyCardId,
    this.appliedDelta,
    this.oldPoints,
    this.newPoints,
    this.isPending,
  });

  @override
  List<Object?> get props => [
        success,
        message,
        loyaltyCardId,
        appliedDelta,
        oldPoints,
        newPoints,
        isPending,
      ];
}
