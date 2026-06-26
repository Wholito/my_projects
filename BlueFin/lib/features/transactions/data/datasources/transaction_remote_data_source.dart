import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/features/transactions/data/models/transaction_model.dart';
import 'package:BlueFin/core/services/supabase_service.dart';

abstract class ITransactionRemoteDataSource {
  Future<List<TransactionModel>> fetchTransactions(String userId);
  Future<void> addTransaction(TransactionModel transaction, String userId);
  Future<void> deleteTransaction(String id, String userId);
  Future<void> updateTransaction(TransactionModel transaction, String userId);
}

class TransactionRemoteDataSource implements ITransactionRemoteDataSource {
  final SupabaseClient _supabase = SupabaseService().getClient;

  @override
  Future<List<TransactionModel>> fetchTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);
      return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Не удалось загрузить транзакции: $e');
    }
  }

  @override
  Future<void> addTransaction(TransactionModel transaction, String userId) async {
    try {
      await _supabase.from('transactions').insert({
        'id': transaction.id,
        'user_id': userId,
        'amount': transaction.amount,
        'category_id': transaction.categoryId,
        'date': transaction.date.toIso8601String(),
        'description': transaction.description,
        'type': transaction.type,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException('Не удалось добавить транзакцию: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String id, String userId) async {
    try {
      await _supabase
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException('Не удалось удалить транзакцию: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction, String userId) async {
    try {
      await _supabase
          .from('transactions')
          .update({
        'amount': transaction.amount,
        'category_id': transaction.categoryId,
        'date': transaction.date.toIso8601String(),
        'description': transaction.description,
        'type': transaction.type,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', transaction.id)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException('Не удалось обновить транзакцию: $e');
    }
  }
}