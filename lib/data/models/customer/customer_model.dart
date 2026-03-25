import 'dart:convert';

import '../../../domain/entities/customer/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.tenantId,
    required super.firstName,
    required super.lastName,
    required super.phoneNumber,
    super.email,
    super.gender,
    super.dateOfBirth,
    super.loyaltyCards,
    super.currency,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final cards = (json['loyaltyCards'] as List<dynamic>?)
            ?.map((c) => LoyaltyCardInfoModel.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    return CustomerModel(
      id: json['id'] as int,
      tenantId: json['tenantId'] as int,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      email: json['email'] as String?,
      gender: json['gender'] as int?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      loyaltyCards: cards,
      currency: json['currency'] as String?,
    );
  }
}

class LoyaltyCardInfoModel extends LoyaltyCardInfo {
  const LoyaltyCardInfoModel({
    required super.id,
    required super.customerId,
    required super.cardNumber,
    super.currentPoints,
    super.lifetimePoints,
    super.currentSteps,
    super.completedCycles,
    super.availableRewardCount,
    super.freeRewardLabel,
    super.currency,
  });

  factory LoyaltyCardInfoModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyCardInfoModel(
      id: json['id'] as int,
      customerId: json['customerId'] as int,
      cardNumber: json['cardNumber'] as String? ?? '',
      currentPoints: json['currentPoints'] as int? ?? 0,
      lifetimePoints: json['lifetimePoints'] as int? ?? 0,
      currentSteps: json['currentSteps'] as int? ?? 0,
      completedCycles: json['completedCycles'] as int? ?? 0,
      availableRewardCount: json['availableRewardCount'] as int? ?? 0,
      freeRewardLabel: json['freeRewardLabel'] as String?,
      currency: json['currency'] as String?,
    );
  }
}

List<CustomerModel> customerListFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> list;
  if (jsonData is Map<String, dynamic>) {
    list = jsonData['data'] as List<dynamic>? ?? [];
  } else if (jsonData is List) {
    list = jsonData;
  } else {
    return [];
  }
  return list.map((e) => CustomerModel.fromJson(e as Map<String, dynamic>)).toList();
}
