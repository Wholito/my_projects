import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String baseUrl = 'api.weatherapi.com';

  static String get _apiKey {
    final fromEnv = dotenv.env['WEATHER_API_KEY'];
    if (fromEnv != null && fromEnv.isNotEmpty) {
      return fromEnv;
    }
    return '';
  }

  Map<String, String> _baseParams({String lang = 'en'}) => {
        'key': _apiKey,
        'lang': lang,
      };

  Future<WeatherModel> getWeatherByCity(String cityName, {String lang = 'en'}) async {
    final url = Uri.https(
      baseUrl,
      '/v1/current.json',
      {
        ..._baseParams(lang: lang),
        'q': cityName,
      },
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('weather_error_${response.statusCode}');
  }

  Future<WeatherModel> getWeatherByLocation(
    double latitude,
    double longitude, {
    String lang = 'en',
  }) async {
    final url = Uri.https(
      baseUrl,
      '/v1/current.json',
      {
        ..._baseParams(lang: lang),
        'q': '$latitude,$longitude',
      },
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return WeatherModel.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('weather_error_${response.statusCode}');
  }

  Future<ForecastBundle> getForecast(String query, {String lang = 'en', int days = 3}) async {
    final url = Uri.https(
      baseUrl,
      '/v1/forecast.json',
      {
        ..._baseParams(lang: lang),
        'q': query,
        'days': '$days',
      },
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return ForecastBundle.fromJson(
        json.decode(response.body) as Map<String, dynamic>,
      );
    }
    return ForecastBundle(days: []);
  }

  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }
    final url = Uri.https(
      baseUrl,
      '/v1/search.json',
      {
        'key': _apiKey,
        'q': query,
      },
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body) as List<dynamic>;
      return data
          .map((city) => CitySuggestion.fromJson(city as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

class CitySuggestion {
  final String name;
  final String region;
  final String country;
  final String url;

  CitySuggestion({
    required this.name,
    required this.region,
    required this.country,
    required this.url,
  });

  factory CitySuggestion.fromJson(Map<String, dynamic> json) {
    return CitySuggestion(
      name: json['name'] as String? ?? '',
      region: json['region'] as String? ?? '',
      country: json['country'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  String get displayName {
    if (region.isNotEmpty && region != name) {
      return '$name, $region, $country';
    }
    return '$name, $country';
  }

  SavedCity toSavedCity() => SavedCity(
        name: name,
        country: country,
        region: region,
      );
}
