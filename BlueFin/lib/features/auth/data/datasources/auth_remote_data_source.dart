import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:BlueFin/core/errors/exceptions.dart';
import 'package:BlueFin/core/services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/token_model.dart';

abstract class IAuthRemoteDataSource {
  Future<(UserModel, TokenModel)> signIn(String email, String password);
  Future<(UserModel, TokenModel)> signUp(String email, String password, String? name);
  Future<void> signOut();
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final SupabaseClient _supabase = SupabaseService().getClient;

  DateTime _extractExpiresAt(dynamic expiresAt) {
    if (expiresAt == null) {
      return DateTime.now().add(const Duration(days: 7));
    }
    if (expiresAt is DateTime) {
      return expiresAt;
    }
    if (expiresAt is int) {
      return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000);
    }
    if (expiresAt is String) {
      return DateTime.parse(expiresAt);
    }
    return DateTime.now().add(const Duration(days: 7));
  }

  @override
  Future<(UserModel, TokenModel)> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) throw ServerException('Ошибка входа');

      var profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profile == null) {
        final userName = user.userMetadata?['name'] ?? email.split('@').first;
        await _supabase.rpc('create_profile', params: {
          'p_id': user.id,
          'p_email': user.email,
          'p_name': userName,
        });
        profile = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
      }

      final userModel = UserModel(
        id: user.id,
        email: user.email!,
        name: profile['name'],
        photoUrl: profile['photo_url'],
      );
      final tokenModel = TokenModel(
        accessToken: response.session?.accessToken ?? '',
        refreshToken: response.session?.refreshToken,
        expiresAt: _extractExpiresAt(response.session?.expiresAt),
      );
      return (userModel, tokenModel);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Ошибка входа: $e');
    }
  }

  @override
  Future<(UserModel, TokenModel)> signUp(String email, String password, String? name) async {
    try {
      final signUpResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      final user = signUpResponse.user;
      if (user == null) {
        try {
          final signInResponse = await _supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (signInResponse.user != null) {
            return await signIn(email, password);
          } else {
            throw ServerException('Пользователь уже существует, но вход не удался');
          }
        } catch (e) {
          throw ServerException('Пользователь с таким email уже существует, но не удалось войти');
        }
      }

      final signInResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = signInResponse.session;
      if (session == null) throw ServerException('Не удалось получить сессию после регистрации');

      final userName = name ?? email.split('@').first;
      await _supabase.rpc('create_profile', params: {
        'p_id': user.id,
        'p_email': email,
        'p_name': userName,
      });

      final userModel = UserModel(
        id: user.id,
        email: user.email!,
        name: userName,
        photoUrl: null,
      );
      final tokenModel = TokenModel(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
        expiresAt: _extractExpiresAt(session.expiresAt),
      );
      return (userModel, tokenModel);
    } on AuthException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException('Ошибка регистрации: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw ServerException('Ошибка выхода: $e');
    }
  }
}