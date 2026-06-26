import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/services/supabase_service.dart';
import 'package:BlueFin/features/categories/data/models/category_model.dart';
import 'package:BlueFin/features/transactions/domain/entities/transaction.dart';

abstract class ICategoryRemoteDataSource {
  Future<List<CategoryModel>> fetchCategories(String userId);
  Future<void> addCategory(CategoryModel category, String userId);
  Future<void> updateCategory(CategoryModel category, String userId);
  Future<void> deleteCategory(String id, String userId);
}

class CategoryRemoteDataSource implements ICategoryRemoteDataSource {
  final SupabaseClient _supabase = SupabaseService().getClient;

  @override
  Future<List<CategoryModel>> fetchCategories(String userId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('name', ascending: true);
      return (response as List).map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Не удалось загрузить категории: $e');
    }
  }

  @override
  Future<void> addCategory(CategoryModel category, String userId) async {
    try {
      await _supabase.from('categories').insert({
        'id': category.id,
        'user_id': userId,
        'name': category.name,
        'type': category.type == TransactionType.income ? 'income' : 'expense',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException('Не удалось добавить категорию: $e');
    }
  }

  @override
  Future<void> updateCategory(CategoryModel category, String userId) async {
    try {
      await _supabase
          .from('categories')
          .update({
        'name': category.name,
        'type': category.type == TransactionType.income ? 'income' : 'expense',
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', category.id)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException('Не удалось обновить категорию: $e');
    }
  }

  @override
  Future<void> deleteCategory(String id, String userId) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);
    } catch (e) {
      throw ServerException('Не удалось удалить категорию: $e');
    }
  }
}