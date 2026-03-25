import 'dart:convert';

import '../../../domain/entities/customer/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.loyaltyCardId,
    required super.type,
    required super.status,
    required super.points,
    super.amount,
    super.description,
    super.reverseReason,
    super.referenceNumber,
    super.orderId,
    super.localOccurredAt,
    super.balanceAfter,
    super.customerName,
    super.cardNumber,
    super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int,
      loyaltyCardId: json['loyaltyCardId'] as int? ?? 0,
      type: json['type'] as int? ?? 0,
      status: json['status'] as int? ?? 0,
      points: json['points'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble(),
      description: json['description'] as String?,
      reverseReason: json['reverseReason'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      orderId: json['orderId'] as String?,
      localOccurredAt: json['localOccurredAt'] as String?,
      balanceAfter: json['balanceAfter'] as int? ?? 0,
      customerName: json['customerName'] as String?,
      cardNumber: json['cardNumber'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class ReverseResultModel extends ReverseResult {
  const ReverseResultModel({
    required super.status,
    super.reversedAmount,
    required super.reversedPoints,
    required super.updatedBalance,
  });

  factory ReverseResultModel.fromJson(Map<String, dynamic> json) {
    return ReverseResultModel(
      status: json['status'] as String? ?? '',
      reversedAmount: (json['reversedAmount'] as num?)?.toDouble(),
      reversedPoints: json['reversedPoints'] as int? ?? 0,
      updatedBalance: json['updatedBalance'] as int? ?? 0,
    );
  }
}

List<TransactionModel> transactionListFromJson(String str) {
  final jsonData = json.decode(str);
  final List<dynamic> list;
  if (jsonData is Map<String, dynamic>) {
    list = jsonData['data'] as List<dynamic>? ?? [];
  } else if (jsonData is List) {
    list = jsonData;
  } else {
    return [];
  }
  return list.map((e) => TransactionModel.fromJson(e as Map<String, dynamic>)).toList();
}

ReverseResultModel reverseResultFromJson(String str) {
  final jsonData = json.decode(str) as Map<String, dynamic>;
  final data = jsonData['data'] as Map<String, dynamic>? ?? jsonData;
  return ReverseResultModel.fromJson(data);
}
