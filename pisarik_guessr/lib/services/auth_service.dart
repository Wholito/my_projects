import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final _random = Random();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(user.uid, doc.data()!);
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final uid = credential.user!.uid;
    final friendCode = await _generateUniqueFriendCode();

    final appUser = AppUser(
      id: uid,
      email: email.trim(),
      displayName: displayName.trim(),
      friendCode: friendCode,
      photoUrl: credential.user?.photoURL,
    );

    await _firestore.collection('users').doc(uid).set(appUser.toMap());
    return appUser;
  }

  Future<void> updateDisplayName(String newName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');
    await user.updateDisplayName(newName);
    await _firestore.collection('users').doc(user.uid).update({'displayName': newName});
  }

  Future<void> updatePhotoUrl(String photoUrl) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');
    await user.updatePhotoURL(photoUrl);
    await _firestore.collection('users').doc(user.uid).update({'photoURL': photoUrl});
  }

  Future<AppUser?> refreshCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(user.uid, doc.data()!);
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final doc =
    await _firestore.collection('users').doc(credential.user!.uid).get();
    if (!doc.exists) {
      throw Exception('Профиль не найден');
    }
    return AppUser.fromMap(credential.user!.uid, doc.data()!);
  }

  Future<void> logout() => _auth.signOut();

  Future<String> _generateUniqueFriendCode() async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ123456789';
    for (var attempt = 0; attempt < 20; attempt++) {
      final code = List.generate(6, (_) => chars[_random.nextInt(chars.length)])
          .join();
      final existing = await _firestore
          .collection('users')
          .where('friendCode', isEqualTo: code)
          .limit(1)
          .get();
      if (existing.docs.isEmpty) return code;
    }
    throw Exception('Не удалось создать код друга');
  }
}