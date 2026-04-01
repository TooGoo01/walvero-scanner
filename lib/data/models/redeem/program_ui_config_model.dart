import 'dart:convert';

import '../../../domain/entities/redeem/program_ui_config.dart';

ProgramUiConfigModel programUiConfigModelFromJson(String str) =>
    ProgramUiConfigModel.fromJson(json.decode(str));

String programUiConfigModelToJson(ProgramUiConfigModel data) =>
    json.encode(data.toJson());

class ProgramTierModel extends ProgramTier {
  const ProgramTierModel({
    required super.name,
    required super.percent,
    super.threshold,
    super.iconUrl,
  });

  factory ProgramTierModel.fromJson(Map<String, dynamic> json) =>
      ProgramTierModel(
        name: json['name'] as String? ?? '',
        threshold: json['threshold'] == null
            ? null
            : (json['threshold'] as num).toInt(),
        percent: (json['percent'] as num?)?.toInt() ?? 0,
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

class ProgramUiConfigModel extends ProgramUiConfig {
  const ProgramUiConfigModel({
    required super.success,
    required super.programName,
    required super.templateType,
    required super.showBalanceOnUi,
    required List<ProgramTierModel> super.tiers,
  });

  factory ProgramUiConfigModel.fromJson(Map<String, dynamic> json) {
    final tiersJson = json['tiers'] as List<dynamic>? ?? [];

    final tiers = tiersJson
        .map((e) => ProgramTierModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProgramUiConfigModel(
      success: json['success'] as bool? ?? false,
      programName: json['programName'] as String? ?? '',
      templateType: (json['templateType'] as num?)?.toInt() ?? 0,
      showBalanceOnUi: json['showBalanceOnUi'] as bool? ?? false,
      tiers: tiers,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'programName': programName,
        'templateType': templateType,
        'showBalanceOnUi': showBalanceOnUi,
        'tiers': tiers
            .map((t) => (t as ProgramTierModel).toJson())
            .toList(),
      };

  factory ProgramUiConfigModel.fromEntity(ProgramUiConfig entity) =>
      ProgramUiConfigModel(
        success: entity.success,
        programName: entity.programName,
        templateType: entity.templateType,
        showBalanceOnUi: entity.showBalanceOnUi,
        tiers: entity.tiers
            .map((t) => ProgramTierModel.fromEntity(t))
            .toList(),
      );
}
