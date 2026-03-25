import 'dart:convert';

import '../../../domain/entities/country/country_code.dart';

List<CountryCodeModel> countryCodeListFromJson(String str) {
  final Map<String, dynamic> decoded = json.decode(str);
  final data = decoded['data'] as List<dynamic>? ?? [];
  return data
      .map((e) => CountryCodeModel.fromJson(e as Map<String, dynamic>))
      .toList();
}

class CountryCodeModel extends CountryCode {
  const CountryCodeModel({
    required super.countryCode,
    required super.name,
    required super.code,
    required super.flag,
  });

  factory CountryCodeModel.fromJson(Map<String, dynamic> json) {
    return CountryCodeModel(
      countryCode: json['countryCode'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      flag: json['flag'] as String? ?? '',
    );
  }
}
