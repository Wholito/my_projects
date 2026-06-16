
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/friend_request.dart';
import '../models/round.dart';
import '../services/connectivity_service.dart';
import '../services/firebase_service.dart';
import '../services/local_db_service.dart';
import 'package:latlong2/latlong.dart';

class AuthProvider extends ChangeNotifier {
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  void setUser(AppUser? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading(true);
    try {
      _user = await firebaseService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      await firebaseService.cacheUser(_user!);
      _error = null;
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await firebaseService.signIn(email, password);
      await _loadSessionUser();
      _error = null;
      return true;
    } catch (e) {
      _error = _parseError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSessionUser() async {
    final uid = firebaseService.currentUid;
    if (uid == null) return;

    final cached = await firebaseService.getCachedUser();
    if (cached != null && cached.uid == uid) {
      _user = cached;
      notifyListeners();
    }

    final fresh = await firebaseService.getUser(uid);
    if (fresh != null) {
      _user = fresh;
      await firebaseService.cacheUser(fresh);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await firebaseService.signOut();
    await firebaseService.clearCachedUser();
    await localDbService.clearAll();
    _user = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('email-already-in-use')) return 'Email уже используется';
    if (raw.contains('wrong-password')) return 'Неверный пароль';
    if (raw.contains('user-not-found')) return 'Пользователь не найден';
    if (raw.contains('weak-password')) return 'Пароль слишком короткий';
    return 'Ошибка входа. Попробуй снова.';
  }
}


class FriendsProvider extends ChangeNotifier {
  List<AppUser> _friends = [];
  List<FriendRequest> _incomingRequests = [];
  final Set<String> _outgoingRequestUids = {};
  bool _loading = false;
  String? _searchResult;
  AppUser? _foundUser;

  List<AppUser> get friends => _friends;
  List<FriendRequest> get incomingRequests => _incomingRequests;
  bool get loading => _loading;
  String? get searchResult => _searchResult;
  AppUser? get foundUser => _foundUser;

  bool hasOutgoingRequest(String uid) => _outgoingRequestUids.contains(uid);

  void setFriends(List<AppUser> friends) {
    _friends = friends;
    notifyListeners();
  }

  void setIncomingRequests(List<FriendRequest> requests) {
    _incomingRequests = requests;
    notifyListeners();
  }

  Future<void> searchByCode(String code) async {
    _setLoading(true);
    _foundUser = null;
    _searchResult = null;
    try {
      _foundUser = await firebaseService.getUserByFriendCode(code);
      _searchResult = _foundUser == null ? 'Игрок не найден' : null;
    } catch (_) {
      _searchResult = 'Ошибка поиска';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> sendFriendRequest(String uid) async {
    try {
      await firebaseService.sendFriendRequest(uid);
      _outgoingRequestUids.add(uid);
      _foundUser = null;
      _searchResult = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString().replaceFirst('Bad state: ', '');
    }
  }

  Future<void> acceptFriendRequest(String fromUid) async {
    await firebaseService.acceptFriendRequest(fromUid);
    _incomingRequests.removeWhere((r) => r.fromUid == fromUid);
    notifyListeners();
  }

  Future<void> rejectFriendRequest(String fromUid) async {
    await firebaseService.rejectFriendRequest(fromUid);
    _incomingRequests.removeWhere((r) => r.fromUid == fromUid);
    notifyListeners();
  }

  Future<void> removeFriend(String uid) async {
    await firebaseService.removeFriend(uid);
    _friends.removeWhere((f) => f.uid == uid);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }
}


class FeedProvider extends ChangeNotifier {
  List<PhotoRound> _rounds = [];
  bool _loading = false;

  List<PhotoRound> get rounds => _rounds;
  bool get loading => _loading;

  void setRounds(List<PhotoRound> rounds) {
    _rounds = rounds;
    notifyListeners();
  }

  void upsertRound(PhotoRound round) {
    final index = _rounds.indexWhere((r) => r.id == round.id);
    if (index >= 0) {
      _rounds = [..._rounds]..[index] = round;
    } else {
      _rounds = [round, ..._rounds];
    }
    notifyListeners();
  }

  List<PhotoRound> pendingGuessFor(String uid) =>
      _rounds.where((r) => !r.hasGuessedBy(uid)).toList();

  List<PhotoRound> guessedBy(String uid) =>
      _rounds.where((r) => r.hasGuessedBy(uid)).toList();
}

class GameProvider extends ChangeNotifier {
  bool _submitting = false;
  Guess? _lastGuess;
  String? _error;

  bool get submitting => _submitting;
  Guess? get lastGuess => _lastGuess;
  String? get error => _error;

  Future<bool> submitGuess({
    required String roundId,
    required double lat,
    required double lng,
    required String displayName,
    String? avatarUrl,
  }) async {
    if (!connectivityService.isOnline) {
      _error = 'Нет интернета или связь нестабильна. Подключись и попробуй снова.';
      notifyListeners();
      return false;
    }

    _submitting = true;
    _error = null;
    notifyListeners();

    try {
      await firebaseService.submitGuess(
        roundId: roundId,
        guessedLocation: LatLng(lat, lng),
        displayName: displayName,
        avatarUrl: avatarUrl,
      );
      return true;
    } on StateError catch (e) {
      _error = e.message;
      return false;
    } on FirebaseException catch (e) {
      _error = _firebaseErrorMessage(e);
      return false;
    } catch (e) {
      _error = 'Не удалось отправить ответ';
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void clear() {
    _lastGuess = null;
    _error = null;
    notifyListeners();
  }
}

String _firebaseErrorMessage(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return 'Нет доступа к серверу. Обнови правила Firestore.';
    case 'unavailable':
      return 'Сервер недоступен. Проверь интернет.';
    default:
      return e.message ?? 'Ошибка Firestore (${e.code})';
  }
}
