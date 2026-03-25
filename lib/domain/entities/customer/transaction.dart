import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final int id;
  final int loyaltyCardId;
  final int type; // 1=Earned, 2=Redeemed, 3=Expired, 4=Adjusted, 5=Bonus
  final int status; // 0=Pending, 1=Applied, 2=Rejected, 3=Expired, 4=Reversed
  final int points;
  final double? amount;
  final String? description;
  final String? reverseReason;
  final String? referenceNumber;
  final String? orderId;
  final String? localOccurredAt;
  final int balanceAfter;
  final String? customerName;
  final String? cardNumber;
  final String? createdAt;

  const Transaction({
    required this.id,
    required this.loyaltyCardId,
    required this.type,
    required this.status,
    required this.points,
    this.amount,
    this.description,
    this.reverseReason,
    this.referenceNumber,
    this.orderId,
    this.localOccurredAt,
    this.balanceAfter = 0,
    this.customerName,
    this.cardNumber,
    this.createdAt,
  });

  String get typeName {
    switch (type) {
      case 1: return 'Earned';
      case 2: return 'Redeemed';
      case 3: return 'Expired';
      case 4: return 'Adjusted';
      case 5: return 'Bonus';
      default: return 'Unknown';
    }
  }

  String get statusName {
    switch (status) {
      case 0: return 'Pending';
      case 1: return 'Applied';
      case 2: return 'Rejected';
      case 3: return 'Expired';
      case 4: return 'Reversed';
      default: return 'Unknown';
    }
  }

  bool get isReversed => status == 4;
  bool get canReverse => status == 1 && (type == 1 || type == 2);

  @override
  List<Object?> get props => [id, loyaltyCardId, type, status, points];
}

class ReverseResult extends Equatable {
  final String status;
  final double? reversedAmount;
  final int reversedPoints;
  final int updatedBalance;

  const ReverseResult({
    required this.status,
    this.reversedAmount,
    required this.reversedPoints,
    required this.updatedBalance,
  });

  @override
  List<Object?> get props => [status, reversedPoints, updatedBalance];
}
