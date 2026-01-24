import 'package:equatable/equatable.dart';

class ProgramTier extends Equatable {
  final String name;
  final int? threshold;
  final int percent;
  final String? iconUrl;

  const ProgramTier({
    required this.name,
    required this.percent,
    this.threshold,
    this.iconUrl,
  });

  @override
  List<Object?> get props => [
        name,
        threshold,
        percent,
        iconUrl,
      ];
}

class ProgramUiConfig extends Equatable {
  final bool success;
  final String programName;
  final int templateType; // 1=Progress, 2=Points, 3=TierBased
  final bool showBalanceOnUi;
  final List<ProgramTier> tiers;

  const ProgramUiConfig({
    required this.success,
    required this.programName,
    required this.templateType,
    required this.showBalanceOnUi,
    required this.tiers,
  });

  @override
  List<Object?> get props => [
        success,
        programName,
        templateType,
        showBalanceOnUi,
        tiers,
      ];
}
