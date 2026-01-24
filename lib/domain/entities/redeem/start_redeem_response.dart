// lib/domain/entities/redeem/start_redeem_response.dart
import 'package:equatable/equatable.dart';

class StartRedeemResponse extends Equatable {
  /// API əməliyyatı uğurlu oldumu?
  final bool success;

  /// Serverdən gələn mesaj (uğurlu və ya uğursuz ola bilər).
  final String? message;

  /// OTP tələb olunurmu? (success = true olanda maraqlıdır)
  final bool requiresOtp;

  /// Kartın Id-si (serverdən gəlirsə).
  final int? loyaltyCardId;

  /// Tətbiq olunan delta (xal dəyişikliyi).
  final int? appliedDelta;

  /// Əməliyyatdan əvvəlki balans.
  final int? oldPoints;

  /// Əməliyyatdan sonrakı balans.
  final int? newPoints;

  /// Əməliyyat pending statusdadırmı? (OTP gözlənir və s.)
  final bool? isPending;

  /// OTP üçün requestId (requiresOtp = true olanda)
  final int? redeemRequestId;
  
  /// YENİ: Redeem-dən sonra qalan CompletedCycles (ProgressBased üçün)
  final int? remainingRewardCount;
  
  /// YENİ: Mükafat label-i (ProgressBased üçün)
  final String? freeRewardLabel;

  const StartRedeemResponse({
    required this.success,
    this.message,
    this.requiresOtp = false,
    this.loyaltyCardId,
    this.appliedDelta,
    this.oldPoints,
    this.newPoints,
    this.isPending,
    this.redeemRequestId,
    this.remainingRewardCount,
    this.freeRewardLabel,
  });

  @override
  List<Object?> get props => [
        success,
        message,
        requiresOtp,
        loyaltyCardId,
        appliedDelta,
        oldPoints,
        newPoints,
        isPending,
        redeemRequestId,
        remainingRewardCount,
        freeRewardLabel,
      ];
}
