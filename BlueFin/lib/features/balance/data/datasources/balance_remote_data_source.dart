import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/services/supabase_service.dart';
import 'package:BlueFin/features/balance/data/models/balance_model.dart';

abstract class IBalanceRemoteDataSource {
  Future<BalanceModel> fetchBalance(String userId);
  Future<void> updateBalance(BalanceModel balance, String userId);
}

class BalanceRemoteDataSource implements IBalanceRemoteDataSource {
  final SupabaseClient _supabase = SupabaseService().getClient;

  @override
  Future<BalanceModel> fetchBalance(String userId) async {
    try {
      final response = await _supabase
          .from('balances')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      if (response == null) {
        final initialBalance = BalanceModel(
          amount: 0.0,
          currency: 'BYN',
          updatedAt: DateTime.now(),
        );
        await _supabase.from('balances').insert({
          'user_id': userId,
          'amount': initialBalance.amount,
          'currency': initialBalance.currency,
          'updated_at': initialBalance.updatedAt.toIso8601String(),
        });
        return initialBalance;
      }
      return BalanceModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw ServerException('Не удалось загрузить баланс: $e');
    }
  }

  @override
  Future<void> updateBalance(BalanceModel balance, String userId) async {
    try {
      await _supabase
          .from('balances')
          .update({
        'amount': balance.amount,
        'currency': balance.currency,
        'updated_at': balance.updatedAt.toIso8601String(),
      })
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException('Не удалось обновить баланс: $e');
    }
  }
}