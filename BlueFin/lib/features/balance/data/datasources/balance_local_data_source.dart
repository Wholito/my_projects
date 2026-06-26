import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/balance_model.dart';

abstract class IBalanceLocalDataSource {
  Future<BalanceModel?> getBalance();
  Future<void> saveBalance(BalanceModel balance);
}

class BalanceLocalDataSource implements IBalanceLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'balance';

  BalanceLocalDataSource(this.prefs);

  @override
  Future<BalanceModel?> getBalance() async {
    try {
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return null;
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return BalanceModel.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to load balance: $e');
    }
  }

  @override
  Future<void> saveBalance(BalanceModel balance) async {
    try {
      final jsonString = jsonEncode(balance.toJson());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      throw CacheException('Failed to save balance: $e');
    }
  }
}