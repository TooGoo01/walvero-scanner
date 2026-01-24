// lib/data/models/redeem/confirm_otp_response_model.dart


import '../../../domain/entities/redeem/confirm_otp_response.dart';

class ConfirmOtpResponseModel extends ConfirmOtpResponse {
  const ConfirmOtpResponseModel({
    required bool success,
    String? message,
    int? loyaltyCardId,
    int? appliedDelta,
    int? oldPoints,
    int? newPoints,
    bool? isPending,
  }) : super(
          success: success,
          message: message,
          loyaltyCardId: loyaltyCardId,
          appliedDelta: appliedDelta,
          oldPoints: oldPoints,
          newPoints: newPoints,
          isPending: isPending,
        );

  factory ConfirmOtpResponseModel.fromJson(Map<String, dynamic> json) {
    return ConfirmOtpResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      loyaltyCardId: (json['loyaltyCardId'] as num?)?.toInt(),
      appliedDelta: (json['appliedDelta'] as num?)?.toInt(),
      oldPoints: (json['oldPoints'] as num?)?.toInt(),
      newPoints: (json['newPoints'] as num?)?.toInt(),
      isPending: json['isPending'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'loyaltyCardId': loyaltyCardId,
        'appliedDelta': appliedDelta,
        'oldPoints': oldPoints,
        'newPoints': newPoints,
        'isPending': isPending,
      };
}
