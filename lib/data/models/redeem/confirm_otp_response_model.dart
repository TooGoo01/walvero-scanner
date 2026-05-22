// lib/data/models/redeem/confirm_otp_response_model.dart


import '../../../domain/entities/redeem/confirm_otp_response.dart';

class ConfirmOtpResponseModel extends ConfirmOtpResponse {
  const ConfirmOtpResponseModel({
    required bool success,
    String? message,
    int? loyaltyCardId,
    double? appliedDelta,
    double? oldPoints,
    double? newPoints,
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
      appliedDelta: (json['appliedDelta'] as num?)?.toDouble(),
      oldPoints: (json['oldPoints'] as num?)?.toDouble(),
      newPoints: (json['newPoints'] as num?)?.toDouble(),
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
