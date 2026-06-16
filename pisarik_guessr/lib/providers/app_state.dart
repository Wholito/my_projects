import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/friends_service.dart';
import '../services/game_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppState extends ChangeNotifier {
  AppState({
    AuthService? authService,
    FriendsService? friendsService,
    GameService? gameService,
  })  : auth = authService ?? AuthService(),
        friends = friendsService ?? FriendsService(),
        game = gameService ?? GameService();

  final AuthService auth;
  final FriendsService friends;
  final GameService game;

  AppUser? _user;
  AppUser? get user => _user;

  bool _loading = true;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    try {
      _user = await auth.getCurrentUser();
      if (_user != null) {
        await _cleanupStaleActiveGame();
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _cleanupStaleActiveGame() async {
    final uid = _user!.id;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final activeGameId = userDoc.data()?['activeGameId'] as String?;
    if (activeGameId == null) return;
    final gameDoc = await FirebaseFirestore.instance.collection('games').doc(activeGameId).get();
    if (!gameDoc.exists) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'activeGameId': FieldValue.delete(),
      });
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    try {
      _error = null;
      _user = await auth.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserProfile({
    required String newName,
    String? newPhotoUrl,
  }) async {
    try {
      _error = null;
      if (newName.isNotEmpty) {
        await auth.updateDisplayName(newName);
      }
      if (newPhotoUrl != null) {
        await auth.updatePhotoUrl(newPhotoUrl);
      }
      _user = await auth.refreshCurrentUser();
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _error = null;
      _user = await auth.login(email: email, password: password);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await auth.logout();
    _user = null;
    notifyListeners();
  }

  Future<bool> addFriend(String code) async {
    if (_user == null) return false;
    try {
      _error = null;
      await friends.addFriendByCode(
        currentUserId: _user!.id,
        friendCode: code,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = _formatError(e);
      notifyListeners();
      return false;
    }
  }

  String _formatError(Object e) {
    final msg = e.toString();
    if (msg.contains('email-already-in-use')) {
      return 'Email уже зарегистрирован';
    }
    if (msg.contains('weak-password')) {
      return 'Пароль слишком простой (минимум 6 символов)';
    }
    if (msg.contains('invalid-credential') ||
        msg.contains('wrong-password') ||
        msg.contains('user-not-found')) {
      return 'Неверный email или пароль';
    }
    if (msg.contains('invalid-email')) {
      return 'Некорректный email';
    }
    if (msg.contains('Exception:')) {
      return msg.replaceFirst('Exception: ', '');
    }
    return 'Ошибка: $msg';
  }
}