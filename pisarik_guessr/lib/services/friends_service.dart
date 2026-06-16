import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class FriendsService {
  FriendsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<AppUser>> watchFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {

      final ids = snapshot.docs.map((e) => e.id).toList();

      if (ids.isEmpty) {
        return <AppUser>[];
      }

      final friends = <AppUser>[];

      for (final id in ids) {
        try {
          final doc =
          await _firestore.collection('users').doc(id).get();

          if (doc.exists && doc.data() != null) {
            friends.add(
              AppUser.fromMap(doc.id, doc.data()!),
            );
          }
        } catch (_) {
          // Пропускаем друга, если профиль недоступен.
        }
      }

      return friends;
    });
  }

  Future<AppUser?> findByFriendCode(String code) async {
    final normalized = code.trim().toUpperCase();
    final result = await _firestore
        .collection('users')
        .where('friendCode', isEqualTo: normalized)
        .limit(1)
        .get();
    if (result.docs.isEmpty) return null;
    final doc = result.docs.first;
    return AppUser.fromMap(doc.id, doc.data());
  }

  Future<void> addFriendByCode({
    required String currentUserId,
    required String friendCode,
  }) async {
    final friend = await findByFriendCode(friendCode);
    if (friend == null) {
      throw Exception('Игрок с таким кодом не найден');
    }
    if (friend.id == currentUserId) {
      throw Exception('Нельзя добавить себя в друзья');
    }

    final batch = _firestore.batch();
    batch.set(
      _firestore.collection('users').doc(currentUserId).collection('friends').doc(friend.id),
      {'addedAt': FieldValue.serverTimestamp()},
    );
    batch.set(
      _firestore.collection('users').doc(friend.id).collection('friends').doc(currentUserId),
      {'addedAt': FieldValue.serverTimestamp()},
    );
    await batch.commit();
  }
}