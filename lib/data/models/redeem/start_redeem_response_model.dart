// lib/data/models/redeem/start_redeem_response_model.dart


import '../../../domain/entities/redeem/start_redeem_response.dart';

class StartRedeemResponseModel extends StartRedeemResponse {
  const StartRedeemResponseModel({
    required bool success,
    String? message,
    bool requiresOtp = false,
    int? loyaltyCardId,
    int? appliedDelta,
    int? oldPoints,
    int? newPoints,
    bool? isPending,
    int? redeemRequestId,
    int? remainingRewardCount,
    String? freeRewardLabel,
  }) : super(
          success: success,
          message: message,
          requiresOtp: requiresOtp,
          loyaltyCardId: loyaltyCardId,
          appliedDelta: appliedDelta,
          oldPoints: oldPoints,
          newPoints: newPoints,
          isPending: isPending,
          redeemRequestId: redeemRequestId,
          remainingRewardCount: remainingRewardCount,
          freeRewardLabel: freeRewardLabel,
        );

  factory StartRedeemResponseModel.fromJson(Map<String, dynamic> json) {
    // Response-da 'data' obyekti ola bilər
    final data = json['data'] as Map<String, dynamic>?;
    
    return StartRedeemResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      requiresOtp: json['requiresOtp'] as bool? ?? false,
      loyaltyCardId: (json['loyaltyCardId'] as num?)?.toInt(),
      appliedDelta: data != null 
          ? (data['appliedDelta'] as num?)?.toInt() 
          : (json['appliedDelta'] as num?)?.toInt(),
      oldPoints: (json['oldPoints'] as num?)?.toInt(),
      newPoints: (json['newPoints'] as num?)?.toInt(),
      isPending: json['isPending'] as bool?,
      redeemRequestId: (json['redeemRequestId'] as num?)?.toInt(),
      remainingRewardCount: data != null 
          ? (data['remainingRewardCount'] as num?)?.toInt() 
          : null,
      freeRewardLabel: data != null 
          ? (data['freeRewardLabel'] as String?) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'requiresOtp': requiresOtp,
        'loyaltyCardId': loyaltyCardId,
        'appliedDelta': appliedDelta,
        'oldPoints': oldPoints,
        'newPoints': newPoints,
        'isPending': isPending,
        'redeemRequestId': redeemRequestId,
        'remainingRewardCount': remainingRewardCount,
        'freeRewardLabel': freeRewardLabel,
      };
}
