import 'package:equatable/equatable.dart';

class CountryCode extends Equatable {
  final int countryCode;
  final String name;
  final String code;
  final String flag;

  const CountryCode({
    required this.countryCode,
    required this.name,
    required this.code,
    required this.flag,
  });

  String get displayCode => '+$countryCode';

  @override
  List<Object?> get props => [countryCode, name, code, flag];
}
