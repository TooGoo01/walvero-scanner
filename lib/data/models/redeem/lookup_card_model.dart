import 'dart:convert';

import 'package:walveroScanner/domain/entities/redeem/redeem_lookup_response.dart' show LookupCard;

import '../../../domain/entities/redeem/program_ui_config.dart';

/// ----------------------
/// ProgramTierModel
/// ----------------------
class ProgramTierModel extends ProgramTier {
  const ProgramTierModel({
    required super.name,
    required super.percent,
    super.threshold,
    super.iconUrl,
  });

  factory ProgramTierModel.fromJson(Map<String, dynamic> json) =>
      ProgramTierModel(
        name: json['name'] as String,
        threshold: json['threshold'] == null
            ? null
            : (json['threshold'] as num).toInt(),
        percent: (json['percent'] as num).toInt(),
        iconUrl: json['iconUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'threshold': threshold,
        'percent': percent,
        'iconUrl': iconUrl,
      };

  factory ProgramTierModel.fromEntity(ProgramTier entity) => ProgramTierModel(
        name: entity.name,
        threshold: entity.threshold,
        percent: entity.percent,
        iconUrl: entity.iconUrl,
      );
}

/// ----------------------
/// LookupCardModel
/// ----------------------

LookupCardModel lookupCardModelFromJson(String str) =>
    LookupCardModel.fromJson(json.decode(str));

String lookupCardModelToJson(LookupCardModel data) =>
    json.encode(data.toJson());

class LookupCardModel extends LookupCard {
  const LookupCardModel({
    required super.success,
    required super.customerFullName,
    required super.cardNumber,
    required super.currentPoints,
    required super.tierIconUrl,
    required super.tierName,
    required super.tierPercent,
    required super.tierPercentCash,
    super.completedCycles,
    super.availableRewardCount,
    super.maxSpendCount,
    super.freeRewardLabel,
    super.currency,
  });

  factory LookupCardModel.fromJson(Map<String, dynamic> json) {
    return LookupCardModel(
      success: json['success'] as bool? ?? false,
      customerFullName: json['customerFullName'] as String? ?? '',
      cardNumber: json['cardNumber'] as String? ?? '',
      currentPoints: (json['currentPoints'] as num?)?.toInt() ?? 0,
      tierIconUrl: json['tierIconUrl'] as String? ?? '',
      tierName: json['tierName'] as String? ?? '',
      tierPercent: (json['tierPercent'] as num?)?.toInt() ?? 0,
      tierPercentCash: (json['tierPercentCash'] as num?)?.toInt() ?? 0,
      completedCycles: (json['completedCycles'] as num?)?.toInt(),
      availableRewardCount: (json['availableRewardCount'] as num?)?.toInt(),
      maxSpendCount: (json['maxSpendCount'] as num?)?.toInt(),
      freeRewardLabel: json['freeRewardLabel'] as String? ?? 'Pulsuz içki',
      currency: json['currency'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'customerFullName': customerFullName,
        'cardNumber': cardNumber,
        'currentPoints': currentPoints,
        'tierIconUrl': tierIconUrl,
        'tierName': tierName,
        'tierPercent': tierPercent,
        'tierPercentCash': tierPercentCash,
        'completedCycles': completedCycles,
        'availableRewardCount': availableRewardCount,
        'maxSpendCount': maxSpendCount,
        'freeRewardLabel': freeRewardLabel,
        'currency': currency,
      };

  factory LookupCardModel.fromEntity(LookupCard entity) => LookupCardModel(
        success: entity.success,
        customerFullName: entity.customerFullName,
        cardNumber: entity.cardNumber,
        currentPoints: entity.currentPoints,
        tierIconUrl: entity.tierIconUrl,
        tierName: entity.tierName,
        tierPercent: entity.tierPercent,
        tierPercentCash: entity.tierPercentCash,
        completedCycles: entity.completedCycles,
        availableRewardCount: entity.availableRewardCount,
        maxSpendCount: entity.maxSpendCount,
        freeRewardLabel: entity.freeRewardLabel,
        currency: entity.currency,
      );
}
