import 'package:equatable/equatable.dart';



class LookupCard extends Equatable {
  final bool success;
  final String customerFullName;
  final String cardNumber;
  final String? tierName;
  final String? tierIconUrl;
  final int currentPoints; // 1=Progress, 2=Points, 3=TierBased
  final int tierPercent; // 1=Progress, 2=Points, 3=TierBased
  final int tierPercentCash; // 1=Progress, 2=Points, 3=TierBased
  // ProgressBased kartlar üçün yeni field-lər
  final int? completedCycles; // Mövcud pulsuz mükafat sayı
  final int? availableRewardCount; // Xərclənə bilən mükafat sayı
  final int? maxSpendCount; // UI input limiti
  final String? freeRewardLabel; // Mükafat label-i (default: "Pulsuz içki")
  final String? currency; // Valyuta (məs: "AZN", "USD", və s.)

  const LookupCard({
    required this.success,
    required this.customerFullName,
    required this.cardNumber,
    required this.tierName,
    required this.tierIconUrl,
    required this.currentPoints,
    required this.tierPercent,
    required this.tierPercentCash,
    this.completedCycles,
    this.availableRewardCount,
    this.maxSpendCount,
    this.freeRewardLabel,
    this.currency,
  });

  // ProgressBased kart yoxlaması
  bool get isProgressBased => 
      completedCycles != null && 
      availableRewardCount != null && 
      maxSpendCount != null;

  @override
  List<Object?> get props => [
        success,
        customerFullName,
        cardNumber,
        tierName,
        tierIconUrl,
        currentPoints,
        tierPercent,
        tierPercentCash,
        completedCycles,
        availableRewardCount,
        maxSpendCount,
        freeRewardLabel,
        currency,
      ];
}
