import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../models/app_user.dart';
import '../models/round.dart';
import 'score_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/friend_request.dart';
import 'local_db_service.dart';

const _cloudName = 'dv9aezcua';
const _uploadPreset = 'sf_uploads';
const _cloudinaryUrl =
    'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

class FirebaseService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> cacheUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final map = user.toMap();
    map['uid'] = user.uid;
    await prefs.setString('cached_user', jsonEncode(map));
  }

  Future<AppUser?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('cached_user');
    if (data != null) {
      final map = jsonDecode(data) as Map<String, dynamic>;
      return AppUser.fromMap(map, map['uid'] as String);
    }
    return null;
  }

  Future<void> clearCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_user');
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final friendCode = 'SF-${uid.substring(0, 4).toUpperCase()}';

    final user = AppUser(
      uid: uid,
      displayName: displayName,
      email: email,
      friendCode: friendCode,
      createdAt: DateTime.now(),
    );

    await _db.collection('users').doc(uid).set(user.toMap());
    return user;
  }

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  String? get currentUid => _auth.currentUser?.uid;

  User? get currentAuthUser => _auth.currentUser;

  Stream<User?> get authStream => _auth.authStateChanges();

  Future<AppUser?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, uid);
  }

  Future<AppUser?> getUserByFriendCode(String code) async {
    final query = await _db
        .collection('users')
        .where('friendCode', isEqualTo: code.toUpperCase())
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return AppUser.fromMap(doc.data(), doc.id);
  }

  Stream<AppUser?> watchCurrentUser() {
    final uid = currentUid;
    if (uid == null) return Stream.value(null);
    return _db.collection('users').doc(uid).snapshots().map(
          (doc) => doc.exists ? AppUser.fromMap(doc.data()!, uid) : null,
        );
  }

  Future<void> saveFcmToken(String token) async {
    final uid = currentUid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).update({
        'fcmToken': token,
        'fcmUpdatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      if (e.code == 'not-found') {
        await _db.collection('users').doc(uid).set(
          {
            'fcmToken': token,
            'fcmUpdatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    }
  }

  Future<bool> areFriends(String otherUid) async {
    final uid = currentUid!;
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('friends')
        .doc(otherUid)
        .get();
    return doc.exists;
  }

  Future<bool> hasOutgoingRequest(String toUid) async {
    final uid = currentUid!;
    final doc = await _db
        .collection('users')
        .doc(toUid)
        .collection('friend_requests')
        .doc(uid)
        .get();
    return doc.exists;
  }

  Future<void> sendFriendRequest(String toUid) async {
    final uid = currentUid!;
    if (uid == toUid) {
      throw StateError('Нельзя добавить себя');
    }

    if (await areFriends(toUid)) {
      throw StateError('Уже в друзьях');
    }
    if (await hasOutgoingRequest(toUid)) {
      throw StateError('Приглашение уже отправлено');
    }

    final me = await getUser(uid);
    final fromName = me?.displayName ?? 'Игрок';

    await _db
        .collection('users')
        .doc(toUid)
        .collection('friend_requests')
        .doc(uid)
        .set({
      'fromUid': uid,
      'fromName': fromName,
      'fromAvatarUrl': me?.avatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

  }

  Future<void> acceptFriendRequest(String fromUid) async {
    await addFriend(fromUid);
    final uid = currentUid!;
    await _db
        .collection('users')
        .doc(uid)
        .collection('friend_requests')
        .doc(fromUid)
        .delete();
  }

  Future<void> rejectFriendRequest(String fromUid) async {
    final uid = currentUid!;
    await _db
        .collection('users')
        .doc(uid)
        .collection('friend_requests')
        .doc(fromUid)
        .delete();
  }

  Stream<List<FriendRequest>> watchIncomingFriendRequests() {
    final uid = currentUid!;
    return _db
        .collection('users')
        .doc(uid)
        .collection('friend_requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FriendRequest.fromMap(d.data(), d.id))
            .toList());
  }

  Future<void> addFriend(String friendUid) async {
    final uid = currentUid!;
    final batch = _db.batch();
    batch.set(
      _db.collection('users').doc(uid).collection('friends').doc(friendUid),
      {'addedAt': FieldValue.serverTimestamp()},
    );
    batch.set(
      _db.collection('users').doc(friendUid).collection('friends').doc(uid),
      {'addedAt': FieldValue.serverTimestamp()},
    );
    batch.delete(
      _db.collection('users').doc(uid).collection('friend_requests').doc(friendUid),
    );
    batch.delete(
      _db
          .collection('users')
          .doc(friendUid)
          .collection('friend_requests')
          .doc(uid),
    );
    await batch.commit();
  }

  Future<void> removeFriend(String friendUid) async {
    final uid = currentUid!;
    final batch = _db.batch();
    batch.delete(
      _db.collection('users').doc(uid).collection('friends').doc(friendUid),
    );
    batch.delete(
      _db.collection('users').doc(friendUid).collection('friends').doc(uid),
    );
    await batch.commit();
  }

  Stream<List<AppUser>> watchFriends() {
    final uid = currentUid!;
    return _db
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .asyncMap((snap) async {
      final futures = snap.docs.map((d) => getUser(d.id));
      final users = await Future.wait(futures);
      return users.whereType<AppUser>().toList();
    });
  }

  Future<void> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final uid = currentUid!;
    final data = <String, dynamic>{};
    if (displayName != null) data['displayName'] = displayName;
    if (avatarUrl != null) data['avatarUrl'] = avatarUrl;

    if (data.isNotEmpty) {
      await _db.collection('users').doc(uid).update(data);
    }
  }

  Future<String> _uploadPhoto(File photoFile, String roundId) async {
    final bytes = await photoFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final response = await http.post(
      Uri.parse(_cloudinaryUrl),
      body: {
        'file': 'data:image/jpeg;base64,$base64Image',
        'upload_preset': _uploadPreset,
        'public_id': roundId,
        'folder': 'shadow_find',
      },
    );

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final url = json['secure_url'] as String;
    return url;
  }

  Future<String> uploadImage(File imageFile, String publicId) async {
    return _uploadPhoto(imageFile, publicId);
  }

  Future<PhotoRound> createRound({
    required File photoFile,
    required LatLng location,
    required List<String> invitedUids,
  }) async {
    final uid = currentUid!;
    final user = await getUser(uid);
    final authorAvatarUrl = user?.avatarUrl;
    final roundId = _uuid.v4();


    final photoUrl = await _uploadPhoto(photoFile, roundId);

    final round = PhotoRound(
      id: roundId,
      authorUid: uid,
      authorName: user?.displayName ?? 'Игрок',
      photoUrl: photoUrl,
      realLocation: location,
      invitedUids: invitedUids,
      status: RoundStatus.active,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      authorAvatarUrl: authorAvatarUrl,
    );

    await _db.collection('rounds').doc(roundId).set(round.toMap());

    final batch = _db.batch();
    for (final invitedUid in invitedUids) {
      batch.set(
        _db
            .collection('users')
            .doc(invitedUid)
            .collection('feed')
            .doc(roundId),
        {'roundId': roundId, 'receivedAt': FieldValue.serverTimestamp()},
      );
    }
    await batch.commit();

    return round;
  }

  Future<void> submitGuess({
    required String roundId,
    required LatLng guessedLocation,
    required String displayName,
    String? avatarUrl,
  }) async {
    final uid = currentUid!;
    final roundRef = _db.collection('rounds').doc(roundId);
    final userRef = _db.collection('users').doc(uid);
    var score = 0;

    await _db.runTransaction((tx) async {
      final roundSnap = await tx.get(roundRef);
      if (!roundSnap.exists) {
        throw StateError('Раунд не найден');
      }

      final round = PhotoRound.fromMap(roundSnap.data()!, roundId);
      if (!round.invitedUids.contains(uid)) {
        throw StateError('Вы не участвуете в этом раунде');
      }
      if (round.hasGuessedBy(uid)) {
        throw StateError('Вы уже угадали в этом раунде');
      }

      final distance =
          ScoreService.distanceBetween(round.realLocation, guessedLocation);
      score = ScoreService.calculate(round.realLocation, guessedLocation);

      final guess = Guess(
        uid: uid,
        displayName: displayName,
        guessedLocation: guessedLocation,
        distanceMeters: distance,
        score: score,
        submittedAt: DateTime.now(),
        avatarUrl: avatarUrl,
      );

      tx.update(roundRef, {
        'guesses': [
          ...round.guesses.map((g) => g.toMap()),
          guess.toMap(),
        ],
      });
    });

    try {
      await userRef.update({
        'totalScore': FieldValue.increment(score),
        'roundsPlayed': FieldValue.increment(1),
      });
    } on FirebaseException catch (e) {
      if (e.code != 'permission-denied') rethrow;
    }
  }

  Stream<List<PhotoRound>> watchMyFeed() {
    final uid = currentUid!;
    return _db
        .collection('users')
        .doc(uid)
        .collection('feed')
        .orderBy('receivedAt', descending: true)
        .limit(20)
        .snapshots()
        .asyncExpand((snap) {
      final ids = snap.docs
          .map((d) => d.data()['roundId'] as String?)
          .whereType<String>()
          .toList();
      return _watchRoundDocuments(ids);
    });
  }

  Stream<List<PhotoRound>> _watchRoundDocuments(List<String> roundIds) {
    if (roundIds.isEmpty) {
      return Stream.value(<PhotoRound>[]);
    }

    late StreamController<List<PhotoRound>> controller;
    final subs = <StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>>[];
    final latest = <String, PhotoRound>{};

    void emit() {
      if (controller.isClosed) return;
      final rounds = roundIds
          .where((id) => latest.containsKey(id))
          .map((id) => latest[id]!)
          .toList();
      controller.add(rounds);
    }

    controller = StreamController<List<PhotoRound>>(
      onListen: () {
        for (final id in roundIds) {
          subs.add(
            _db.collection('rounds').doc(id).snapshots().listen((doc) {
              if (doc.exists && doc.data() != null) {
                latest[id] = PhotoRound.fromMap(doc.data()!, doc.id);
                emit();
              }
            }),
          );
        }
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
      },
    );

    return controller.stream;
  }

  Future<PhotoRound?> fetchRound(String roundId) async {
    try {
      final doc = await _db.collection('rounds').doc(roundId).get(
            const GetOptions(source: Source.serverAndCache),
          );
      if (!doc.exists || doc.data() == null) return null;
      return PhotoRound.fromMap(doc.data()!, doc.id);
    } catch (_) {
      final rounds = await localDbService.loadRounds();
      for (final r in rounds) {
        if (r.id == roundId) return r;
      }
      return null;
    }
  }

  Stream<PhotoRound> watchRound(String roundId) {
    return _db.collection('rounds').doc(roundId).snapshots().map(
          (doc) => PhotoRound.fromMap(doc.data()!, doc.id),
        );
  }

  Future<List<AppUser>> getLeaderboard({int limit = 20}) async {
    try {
      final query = await _db
          .collection('users')
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get(const GetOptions(source: Source.serverAndCache));
      final leaders = query.docs
          .map((d) => AppUser.fromMap(d.data(), d.id))
          .toList();
      await localDbService.saveLeaderboard(leaders);
      return leaders;
    } catch (_) {
      final cached = await localDbService.loadLeaderboard();
      if (cached.isNotEmpty) return cached;
      rethrow;
    }
  }
}

final firebaseService = FirebaseService();
