import 'package:http/http.dart' as http;

import '../../../core/constant/strings.dart';
import '../../../core/error/exceptions.dart';
import '../../models/country/country_code_model.dart';

abstract class CountryRemoteDataSource {
  Future<List<CountryCodeModel>> getCountryCodes();
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final http.Client client;
  CountryRemoteDataSourceImpl({required this.client});

  @override
  Future<List<CountryCodeModel>> getCountryCodes() async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/Country/PublicCountryCodeList'),
      headers: {
        'Content-Type': 'application/json',
        'accept': 'text/plain',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return countryCodeListFromJson(response.body);
    } else {
      throw ServerException();
    }
  }
}
