import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/transaction_model.dart';

abstract class ITransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<void> saveTransactions(List<TransactionModel> transactions);
}

class TransactionLocalDataSource implements ITransactionLocalDataSource {
  final SharedPreferences prefs;
  static const String _key = 'transactions';

  TransactionLocalDataSource(this.prefs);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    try {
      final jsonString = prefs.getString(_key);
      if (jsonString == null) return [];
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        if (!map.containsKey('categoryId') && map.containsKey('category')) {
          map['categoryId'] = map['category'] as String;
        }
        if (!map.containsKey('categoryId')) {
          map['categoryId'] = 'default';
        }
        return TransactionModel.fromJson(map);
      }).toList();
    } catch (e) {
      throw CacheException('Failed to load transactions: $e');
    }
  }

  @override
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    try {
      final jsonString = jsonEncode(transactions.map((e) => e.toJson()).toList());
      await prefs.setString(_key, jsonString);
    } catch (e) {
      throw CacheException('Failed to save transactions: $e');
    }
  }
}