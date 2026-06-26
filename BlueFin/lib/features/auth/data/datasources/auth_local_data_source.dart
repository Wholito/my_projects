import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

abstract class IAuthLocalDataSource {
  Future<void> saveUserAndToken(UserModel user, TokenModel token);
  Future<UserModel?> getUser();
  Future<TokenModel?> getToken();
  Future<void> clearAll();
  Future<void> saveUserId(String userId);
  Future<String?> getUserId();
}

class AuthLocalDataSource implements IAuthLocalDataSource {
  final SharedPreferences prefs;

  AuthLocalDataSource(this.prefs);

  @override
  Future<void> saveUserAndToken(UserModel user, TokenModel token) async {
    try {
      await prefs.setString('user', jsonEncode(user.toJson()));
      await prefs.setString('token', jsonEncode(token.toJson()));
    } catch (e) {
      throw CacheException('Failed to save user/token: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final jsonString = prefs.getString('user');
      if (jsonString == null) return null;
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to get user: $e');
    }
  }

  @override
  Future<TokenModel?> getToken() async {
    try {
      final jsonString = prefs.getString('token');
      if (jsonString == null) return null;
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return TokenModel.fromJson(map);
    } catch (e) {
      throw CacheException('Failed to get token: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await prefs.remove('user');
      await prefs.remove('token');
    } catch (e) {
      throw CacheException('Failed to clear storage: $e');
    }
  }

  @override
  Future<void> saveUserId(String userId) async {
    await prefs.setString('user_id', userId);
  }

  @override
  Future<String?> getUserId() async {
    return prefs.getString('user_id');
  }
}