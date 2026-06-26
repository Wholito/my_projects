import 'dart:convert';

import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/features/categories/data/models/category_model.dart';
import 'package:BlueFin/features/categories/domain/entities/category.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ICategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<void> saveCategories(List<CategoryModel> categories);
}

class CategoryLocalDataSource implements ICategoryLocalDataSource{
  final SharedPreferences prefs;
  static const String _key = 'Categories';
  CategoryLocalDataSource(this.prefs);

  @override
  Future<List<CategoryModel>> getCategories() async{
    try
      {
        final jsonString = prefs.getString(_key);
        if (jsonString == null){return [];}
        final List<dynamic> list = jsonDecode(jsonString);
        return list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      } catch(e){
      throw CacheException('Не удалось загрузить категории');
    };
  }

  @override
  Future<void> saveCategories(List<CategoryModel> categories) async{
    final jsonString = jsonEncode(categories.map((e) => e.toJson()).toList());
    try {
      await prefs.setString(_key, jsonString);
    } catch (e) {
      throw CacheException('Не удалось сохранить категории');
    };
  }


}