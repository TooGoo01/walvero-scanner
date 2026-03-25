import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int id;
  final int tenantId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String? email;
  final int? gender;
  final DateTime? dateOfBirth;
  final List<LoyaltyCardInfo> loyaltyCards;
  final String? currency;

  const Customer({
    required this.id,
    required this.tenantId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.loyaltyCards = const [],
    this.currency,
  });

  String get fullName => '$firstName $lastName'.trim();

  @override
  List<Object?> get props => [id, tenantId, firstName, lastName, phoneNumber];
}

class LoyaltyCardInfo extends Equatable {
  final int id;
  final int customerId;
  final String cardNumber;
  final int currentPoints;
  final int lifetimePoints;
  final int currentSteps;
  final int completedCycles;
  final int availableRewardCount;
  final String? freeRewardLabel;
  final String? currency;

  const LoyaltyCardInfo({
    required this.id,
    required this.customerId,
    required this.cardNumber,
    this.currentPoints = 0,
    this.lifetimePoints = 0,
    this.currentSteps = 0,
    this.completedCycles = 0,
    this.availableRewardCount = 0,
    this.freeRewardLabel,
    this.currency,
  });

  @override
  List<Object?> get props => [id, customerId, cardNumber];
}
