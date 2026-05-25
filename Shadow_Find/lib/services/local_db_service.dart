import 'dart:convert';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import '../models/friend_request.dart';
import '../models/round.dart';
import 'cache_codec.dart';

final localDbService = LocalDbService();

class LocalDbService {
  Database? _db;

  Future<Database> get _database async {
    if (_db != null) return _db!;
    final base = await getDatabasesPath();
    _db = await openDatabase(
      join(base, 'shadow_find_cache.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE cached_rounds (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL,
            sort_key INTEGER NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_friends (
            uid TEXT PRIMARY KEY,
            payload TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_friend_requests (
            from_uid TEXT PRIMARY KEY,
            payload TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE cached_leaderboard (
            id TEXT PRIMARY KEY,
            payload TEXT NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> saveRounds(List<PhotoRound> rounds) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete('cached_rounds');
    for (var i = 0; i < rounds.length; i++) {
      final r = rounds[i];
      batch.insert(
        'cached_rounds',
        {
          'id': r.id,
          'payload': jsonEncode(CacheCodec.roundToJson(r)),
          'sort_key': i,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<PhotoRound>> loadRounds() async {
    final db = await _database;
    final rows = await db.query('cached_rounds', orderBy: 'sort_key ASC');
    return rows
        .map((row) => CacheCodec.roundFromJson(
              jsonDecode(row['payload'] as String) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveFriends(List<AppUser> friends) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete('cached_friends');
    for (final f in friends) {
      batch.insert(
        'cached_friends',
        {
          'uid': f.uid,
          'payload': jsonEncode(CacheCodec.userToJson(f)),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<AppUser>> loadFriends() async {
    final db = await _database;
    final rows = await db.query('cached_friends');
    return rows
        .map((row) => CacheCodec.userFromJson(
              jsonDecode(row['payload'] as String) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveFriendRequests(List<FriendRequest> requests) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete('cached_friend_requests');
    for (final r in requests) {
      batch.insert(
        'cached_friend_requests',
        {
          'from_uid': r.fromUid,
          'payload': jsonEncode(CacheCodec.friendRequestToJson(r)),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<FriendRequest>> loadFriendRequests() async {
    final db = await _database;
    final rows = await db.query('cached_friend_requests');
    return rows
        .map((row) => CacheCodec.friendRequestFromJson(
              jsonDecode(row['payload'] as String) as Map<String, dynamic>,
            ))
        .toList();
  }

  Future<void> saveLeaderboard(List<AppUser> leaders) async {
    final db = await _database;
    final payload = jsonEncode(leaders.map(CacheCodec.userToJson).toList());
    await db.insert(
      'cached_leaderboard',
      {'id': 'default', 'payload': payload},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppUser>> loadLeaderboard() async {
    final db = await _database;
    final rows = await db.query(
      'cached_leaderboard',
      where: 'id = ?',
      whereArgs: ['default'],
      limit: 1,
    );
    if (rows.isEmpty) return [];
    final list = jsonDecode(rows.first['payload'] as String) as List<dynamic>;
    return list
        .map((e) => CacheCodec.userFromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> clearAll() async {
    final db = await _database;
    await db.delete('cached_rounds');
    await db.delete('cached_friends');
    await db.delete('cached_friend_requests');
    await db.delete('cached_leaderboard');
  }
}
