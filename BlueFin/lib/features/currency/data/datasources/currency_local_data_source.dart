import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/exchange_rate_model.dart';

abstract class ICurrencyLocalDataSource {
  Future<List<ExchangeRateModel>> getRates();
  Future<void> saveRates(List<ExchangeRateModel> rates);
}

class CurrencyLocalDataSource implements ICurrencyLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'exchange_rates';

  CurrencyLocalDataSource(this.prefs);

  @override
  Future<List<ExchangeRateModel>> getRates() async {
    try {
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return [];
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => ExchangeRateModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw CacheException('Failed to load exchange rates: $e');
    }
  }

  @override
  Future<void> saveRates(List<ExchangeRateModel> rates) async {
    try {
      final jsonString = jsonEncode(rates.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      throw CacheException('Failed to save exchange rates: $e');
    }
  }
}