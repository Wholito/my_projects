import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/character_repository.dart';
import '../data/item_repository.dart';
import '../models/game_mode.dart';
import '../models/game_session.dart';
import '../models/game_theme.dart';
import '../utils/russian_alphabet.dart';

class GameService {
  GameService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _games =>
      _firestore.collection('games');

  Stream<GameSession?> watchGame(String gameId) {
    return _games.doc(gameId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return GameSession.fromMap(doc.id, doc.data()!);
    });
  }

  Stream<List<GameMessage>> watchMessages(String gameId) {
    return _games
        .doc(gameId)
        .collection('messages')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => GameMessage.fromMap(d.id, d.data()))
        .toList());
  }

  Future<String> createGame(String hostId) async {
    final existingGames = await _games
        .where('hostId', isEqualTo: hostId)
        .where('phase', isNotEqualTo: 'finished')
        .get();
    for (final doc in existingGames.docs) {
      final data = doc.data();
      if (data['guestId'] == null) {
        await _games.doc(doc.id).delete();
      } else {
        throw Exception('У вас уже есть активная игра с другим игроком.');
      }
    }

    final guestGames = await _games
        .where('guestId', isEqualTo: hostId)
        .where('phase', isNotEqualTo: 'finished')
        .get();
    if (guestGames.docs.isNotEmpty) {
      throw Exception('Вы уже участвуете в игре как гость.');
    }

    final doc = await _games.add({
      'hostId': hostId,
      'guestId': null,
      'theme': null,
      'phase': GamePhase.waitingForPlayer.name,
      'describerId': null,
      'guesserId': null,
      'characterId': null,
      'currentLetter': null,
      'wordCount': 0,
      'hostThemeVote': null,
      'guestThemeVote': null,
      'winnerId': null,
      'correctGuess': null,
      'createdAt': FieldValue.serverTimestamp(),
      'pussyMode': false,
      'guessedItems': [],
    });

    await _setActiveGame(hostId, doc.id);
    return doc.id;
  }

  Future<void> _setActiveGame(String userId, String gameId) async {
    await _firestore.collection('users').doc(userId).update({
      'activeGameId': gameId,
    });
  }

  Future<void> _clearActiveGame(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'activeGameId': FieldValue.delete(),
    });
  }


  Stream<String?> watchActiveGameId(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map(
          (doc) => doc.data()?['activeGameId'] as String?,
        );
  }

  Future<void> joinGame(String gameId, String guestId) async {
    final guestDoc = await _firestore.collection('users').doc(guestId).get();
    if (guestDoc.data()?['activeGameId'] != null) {
      throw ('Вы уже участвуете в другой игре');
    }
    final ref = _games.doc(gameId);
    String? hostId;

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw ('Игра не найдена или закончена');
      final data = snap.data()!;
      if (data['guestId'] != null) {
        throw ('В игре уже два игрока');
      }
      if (data['hostId'] == guestId) {
        throw ('Нельзя присоединиться к своей игре');
      }

      hostId = data['hostId'] as String;
      final hostVote = data['hostThemeVote'] as String?;
      final guestVote = data['guestThemeVote'] as String?;

      final updates = <String, dynamic>{
        'guestId': guestId,
        'describerId': hostId,
        'guesserId': guestId,
      };

      final theme = _resolveTheme(hostVote, guestVote);
      if (theme != null) {
        updates['theme'] = theme;
        updates['phase'] = GamePhase.characterSelection.name;
        if (theme == GameTheme.brawlStars.id) {
          updates['pussyMode'] = true;
          updates['gameMode'] = GameMode.characters.id;
        }
      } else {
        updates['phase'] = GamePhase.themeSelection.name;
      }

      tx.update(ref, updates);
    });

    await _setActiveGame(guestId, gameId);
    await deleteAllInvitesForUser(guestId);
  }

  Future<void> inviteFriendToGame({
    required String gameId,
    required String friendId,
    required String hostId,
  }) async {
    final oldInvites = await _firestore
        .collection('gameInvites')
        .where('gameId', isEqualTo: gameId)
        .where('fromUserId', isEqualTo: hostId)
        .where('toUserId', isEqualTo: friendId)
        .get();
    for (final doc in oldInvites.docs) {
      await doc.reference.delete();
    }
    if (friendId == hostId) {
      throw ('Нельзя пригласить самого себя');
    }

    final friendDoc = await _firestore.collection('users').doc(friendId).get();
    if (friendDoc.exists && friendDoc.data()?['activeGameId'] != null) {
      throw ('Друг уже участвует в другой игре');
    }

    final existingInvite = await _firestore
        .collection('gameInvites')
        .where('gameId', isEqualTo: gameId)
        .where('fromUserId', isEqualTo: hostId)
        .where('toUserId', isEqualTo: friendId)
        .get();

    if (existingInvite.docs.isNotEmpty) {
      throw ('Вы уже приглашали этого друга. Дождитесь ответа или отмените приглашение.');
    }

    await _firestore.collection('gameInvites').add({
      'gameId': gameId,
      'fromUserId': hostId,
      'toUserId': friendId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> watchInvites(String userId) {
    return _firestore
        .collection('gameInvites')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snapshot) async {
      final invites = <Map<String, dynamic>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final fromUserId = data['fromUserId'] as String;
        final userDoc = await _firestore.collection('users').doc(fromUserId).get();
        final userName = userDoc.data()?['displayName'] ?? 'Игрок';
        final userPhoto = userDoc.data()?['photoURL'] as String?;
        invites.add({
          'id': doc.id,
          'gameId': data['gameId'],
          'fromUserId': fromUserId,
          'fromUserName': userName,
          'fromUserPhotoUrl': userPhoto,
          'createdAt': data['createdAt'],
        });
      }
      return invites;
    });
  }

  Future<void> acceptInvite(String inviteId, String gameId, String userId) async {
    await joinGame(gameId, userId);
    await _firestore.collection('gameInvites').doc(inviteId).update({'status': 'accepted'});
    await _setActiveGame(userId, gameId);
    final gameDoc = await _games.doc(gameId).get();
    final hostId = gameDoc.data()?['hostId'] as String?;
    if (hostId != null) {
      await _setActiveGame(hostId, gameId);
    }
  }

  Future<void> declineInvite(String inviteId) async {
    final inviteDoc = await _firestore.collection('gameInvites').doc(inviteId).get();
    if (!inviteDoc.exists) return;
    final data = inviteDoc.data()!;
    final gameId = data['gameId'] as String;
    final fromUserId = data['fromUserId'] as String;

    await inviteDoc.reference.delete();

    final gameDoc = await _games.doc(gameId).get();
    if (gameDoc.exists) {
      final game = GameSession.fromMap(gameId, gameDoc.data()!);
      if (game.phase == GamePhase.waitingForPlayer && game.guestId == null) {
        await _games.doc(gameId).delete();
        await _clearActiveGame(fromUserId);
      }
    }
  }

  Future<void> _deleteGameAndCleanup(GameSession game, String hostId) async {
    final messages = await _games.doc(game.id).collection('messages').get();
    final batch = _firestore.batch();
    for (final msg in messages.docs) {
      batch.delete(msg.reference);
    }

    final invites = await _firestore.collection('gameInvites').where('gameId', isEqualTo: game.id).get();
    for (final inv in invites.docs) {
      batch.delete(inv.reference);
    }

    batch.delete(_games.doc(game.id));
    batch.update(_firestore.collection('users').doc(hostId), {'activeGameId': FieldValue.delete()});
    await batch.commit();
  }

  String? _resolveTheme(String? hostVote, String? guestVote) {
    if (hostVote != null && guestVote != null) {
      return hostVote;
    }
    if (hostVote != null) return hostVote;
    if (guestVote != null) return guestVote;
    return null;
  }

  Map<String, dynamic> _themeResolvedUpdates(Map<String, dynamic> data) {
    final hostId = data['hostId'] as String;
    final guestId = data['guestId'] as String?;
    final hostVote = data['hostThemeVote'] as String?;
    final guestVote = data['guestThemeVote'] as String?;
    if (guestId == null) return {};
    final theme = _resolveTheme(hostVote, guestVote);
    if (theme == null) return {};

    String nextPhase;
    Map<String, dynamic> updates = {
      'theme': theme,
      'describerId': hostId,
      'guesserId': guestId,
    };

    if (theme == GameTheme.brawlStars.id) {
      nextPhase = GamePhase.roleAssignment.name;
      updates['pussyMode'] = true;
      updates['gameMode'] = GameMode.characters.id;
    } else {
      nextPhase = GamePhase.modeSelection.name;
    }

    updates['phase'] = nextPhase;
    return updates;
  }

  Future<void> voteTheme({
    required String gameId,
    required String userId,
    required GameTheme theme,
  }) async {
    final ref = _games.doc(gameId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      final hostId = data['hostId'] as String;
      final isHost = userId == hostId;

      var hostVote = data['hostThemeVote'] as String?;
      var guestVote = data['guestThemeVote'] as String?;

      if (isHost) {
        hostVote = theme.id;
      } else {
        guestVote = theme.id;
      }

      final mergedData = {
        ...data,
        'hostThemeVote': hostVote,
        'guestThemeVote': guestVote,
      };

      final updates = <String, dynamic>{
        'hostThemeVote': hostVote,
        'guestThemeVote': guestVote,
        ..._themeResolvedUpdates(mergedData),
      };

      tx.update(ref, updates);
    });
  }

  Future<void> selectMode(String gameId, String userId, GameMode mode) async {
    final ref = _games.doc(gameId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      final hostId = data['hostId'] as String;
      if (userId != hostId) throw ('Только хост может выбрать режим');
      tx.update(ref, {
        'gameMode': mode.id,
        'phase': GamePhase.roleAssignment.name,
      });
    });
  }

  Future<void> selectItem({
    required String gameId,
    required String itemId,
  }) async {
    await _games.doc(gameId).update({
      'characterId': itemId,
      'phase': GamePhase.playing.name,
      'currentLetter': null,
      'wordCount': 0,
    });
  }

  Future<void> swapRoles(String gameId) async {
    final ref = _games.doc(gameId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final data = snap.data()!;
      tx.update(ref, {
        'describerId': data['guesserId'],
        'guesserId': data['describerId'],
        'phase': GamePhase.characterSelection.name,
      });
    });
  }

  Future<void> confirmRoles(String gameId) async {
    await _games.doc(gameId).update({
      'phase': GamePhase.characterSelection.name,
    });
  }

  Future<void> selectCharacter({
    required String gameId,
    required String characterId,
  }) async {
    await _games.doc(gameId).update({
      'characterId': characterId,
      'phase': GamePhase.playing.name,
      'currentLetter': null,
      'wordCount': 0,
    });
  }

  Future<void> requestLetter({
    required String gameId,
    required String letter,
  }) async {
    if (!isAllowedLetter(letter)) {
      throw ('Буква недоступна (нельзя ь, ъ, ы)');
    }
    await _games.doc(gameId).update({
      'currentLetter': letter.trim().toLowerCase().replaceAll('ё', 'е'),
    });
  }

  Future<void> forceCorrectGuess({
    required String gameId,
    required String guesserId,
    required String guessText,
    required String describerId,
  }) async {
    final gameDoc = await _games.doc(gameId).get();
    if (!gameDoc.exists) throw ('Игра не найдена или закончена');
    final game = GameSession.fromMap(gameDoc.id, gameDoc.data()!);

    if (game.describerId != describerId) {
      throw ('Только загадывающий может зачесть ответ');
    }
    if (game.guesserId != guesserId) {
      throw ('Неверный ID угадывающего');
    }
    if (game.phase != GamePhase.playing) {
      throw ('Игра не в активной фазе');
    }

    final batch = _firestore.batch();

    batch.set(_games.doc(gameId).collection('messages').doc(), {
      'senderId': describerId,
      'text': 'Зачтено: "$guessText"',
      'createdAt': FieldValue.serverTimestamp(),
      'isGuess': false,
      'isCorrect': false,
    });

    batch.update(_games.doc(gameId), {
      'phase': GamePhase.finished.name,
      'winnerId': guesserId,
      'correctGuess': guessText,
      'guessedItems': FieldValue.arrayUnion([_normalizeString(guessText)]),
    });

    await batch.commit();

    await _clearActiveGame(game.hostId);
    if (game.guestId != null) await _clearActiveGame(game.guestId!);
  }

  Future<void> sendDescription({
    required String gameId,
    required String senderId,
    required String text,
  }) async {
    final gameDoc = await _games.doc(gameId).get();
    if (!gameDoc.exists) throw ('Игра не найдена ил закончена');
    final game = GameSession.fromMap(gameDoc.id, gameDoc.data()!);

    if (game.describerId != senderId) {
      throw ('Только загадывающий может описывать');
    }
    if (game.currentLetter == null) {
      throw ('Сначала угадывающий должен выбрать букву');
    }
    if (!textStartsWithLetter(text, game.currentLetter!)) {
      throw (
        'Все слова должны начинаться на «${game.currentLetter!.toUpperCase()}»',
      );
    }

    final words = countWords(text);
    final batch = _firestore.batch();
    batch.update(_games.doc(gameId), {
      'wordCount': FieldValue.increment(words),
    });
    batch.set(_games.doc(gameId).collection('messages').doc(), {
      'senderId': senderId,
      'text': text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isGuess': false,
      'isCorrect': false,
    });
    await batch.commit();
  }

  Future<bool> submitGuess({
    required String gameId,
    required String senderId,
    required String guess,
  }) async {
    final gameDoc = await _games.doc(gameId).get();
    if (!gameDoc.exists) throw ('Игра не найдена ил закончена');
    final game = GameSession.fromMap(gameDoc.id, gameDoc.data()!);

    if (game.guesserId != senderId) {
      throw ('Только угадывающий может угадывать');
    }

    final normalizedGuess = _normalizeString(guess);

    if (game.guessedItems.contains(normalizedGuess)) {
      throw ('Вы уже пробовали этот вариант. Попробуйте другой.');
    }

    bool isCorrect = false;
    if (game.gameMode == GameMode.items) {
      final item = ItemRepository.findByGuess(guess, game.theme!);
      isCorrect = item?.id == game.characterId;
    } else {
      final character = CharacterRepository.findById(game.characterId);
      isCorrect = character?.matchesGuess(guess) ?? false;
    }

    final batch = _firestore.batch();

    batch.set(_games.doc(gameId).collection('messages').doc(), {
      'senderId': senderId,
      'text': guess.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'isGuess': true,
      'isCorrect': isCorrect,
    });

    batch.update(_games.doc(gameId), {
      'guessCount': FieldValue.increment(1),
      'guessedItems': FieldValue.arrayUnion([normalizedGuess]),
    });

    if (isCorrect) {
      batch.update(_games.doc(gameId), {
        'phase': GamePhase.finished.name,
        'winnerId': senderId,
        'correctGuess': guess.trim(),
      });
    }

    await batch.commit();

    if (isCorrect) {
      await _clearActiveGame(game.hostId);
      if (game.guestId != null) await _clearActiveGame(game.guestId!);
    }
    return isCorrect;
  }

  String _normalizeString(String s) {
    return s.trim().toLowerCase().replaceAll('ё', 'е');
  }

  Future<void> leaveGame(GameSession game, String userId) async {
    await _clearActiveGame(userId);
    final otherId = userId == game.hostId ? game.guestId : game.hostId;
    if (otherId != null) await _clearActiveGame(otherId);

    final invites = await _firestore
        .collection('gameInvites')
        .where('gameId', isEqualTo: game.id)
        .get();
    final batch = _firestore.batch();
    for (final inv in invites.docs) batch.delete(inv.reference);

    final messages = await _games.doc(game.id).collection('messages').get();
    for (final msg in messages.docs) batch.delete(msg.reference);

    batch.delete(_games.doc(game.id));
    await batch.commit();
  }

  Future<void> setPussyMode(String gameId, bool enabled) async {
    await _games.doc(gameId).update({'pussyMode': enabled});
  }

  Future<String?> findActiveGameBetween(String userId1, String userId2) async {
    final snapshot = await _firestore
        .collection('games')
        .where('phase', isNotEqualTo: 'finished')
        .get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final hostId = data['hostId'] as String?;
      final guestId = data['guestId'] as String?;
      if (hostId == userId1 || hostId == userId2) {
        if (guestId == null || guestId == userId1 || guestId == userId2) {
          return doc.id;
        }
      }
    }
    return null;
  }


  Future<DocumentSnapshot> getGame(String gameId) {
    return _games.doc(gameId).get();
  }

  Stream<Map<String, dynamic>?> watchActiveGameDetails(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().asyncMap((userSnapshot) async {
      final gameId = userSnapshot.data()?['activeGameId'] as String?;
      if (gameId == null) return null;

      final gameSnapshot = await _games.doc(gameId).get();
      if (!gameSnapshot.exists) return null;

      final gameData = gameSnapshot.data()!;
      final opponentId = gameData['hostId'] == userId ? gameData['guestId'] : gameData['hostId'];

      if (opponentId == null) {
        return {
          'gameId': gameId,
          'opponentName': 'Ожидание игрока',
          'opponentPhoto': null,
          'phase': gameData['phase'],
        };
      }

      final opponentSnapshot = await _firestore.collection('users').doc(opponentId).get();
      if (!opponentSnapshot.exists) {
        return {
          'gameId': gameId,
          'opponentName': 'Игрок',
          'opponentPhoto': null,
          'phase': gameData['phase'],
        };
      }

      final opponentData = opponentSnapshot.data()!;
      return {
        'gameId': gameId,
        'opponentName': opponentData['displayName'] ?? 'Игрок',
        'opponentPhoto': opponentData['photoURL'],
        'phase': gameData['phase'],
      };
    });
  }
  Future<void> clearActiveGame(String userId) async {
    await _clearActiveGame(userId);
  }

  Future<void> deleteGame(String gameId) async {
    final ref = _games.doc(gameId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final game = GameSession.fromMap(gameId, doc.data()!);
    final batch = _firestore.batch();
    final messages = await ref.collection('messages').get();
    for (final msg in messages.docs) batch.delete(msg.reference);
    final invites = await _firestore.collection('gameInvites').where('gameId', isEqualTo: gameId).get();
    for (final inv in invites.docs) batch.delete(inv.reference);
    batch.delete(ref);
    await batch.commit();
    await _clearActiveGame(game.hostId);
    if (game.guestId != null) await _clearActiveGame(game.guestId!);
  }

  Future<void> cleanupPendingInvites(String gameId, String hostId, String friendId) async {
    final invites = await _firestore
        .collection('gameInvites')
        .where('gameId', isEqualTo: gameId)
        .where('fromUserId', isEqualTo: hostId)
        .where('toUserId', isEqualTo: friendId)
        .where('status', isEqualTo: 'pending')
        .get();
    final batch = _firestore.batch();
    for (final inv in invites.docs) batch.delete(inv.reference);
    await batch.commit();
  }

  Future<void> deleteAllInvitesForUser(String userId) async {
    final invites = await _firestore
        .collection('gameInvites')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .get();
    final batch = _firestore.batch();
    for (final inv in invites.docs) batch.delete(inv.reference);
    await batch.commit();
  }
}

