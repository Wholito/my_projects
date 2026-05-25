import '../models/app_user.dart';
import '../models/friend_request.dart';
import '../models/round.dart';
import 'package:latlong2/latlong.dart';

class CacheCodec {
  static Map<String, dynamic> roundToJson(PhotoRound r) {
    return {
      'id': r.id,
      'authorUid': r.authorUid,
      'authorName': r.authorName,
      'photoUrl': r.photoUrl,
      'realLocation': {
        'lat': r.realLocation.latitude,
        'lng': r.realLocation.longitude,
      },
      'invitedUids': r.invitedUids,
      'guesses': r.guesses.map(_guessToJson).toList(),
      'status': r.status.name,
      'createdAt': r.createdAt.toIso8601String(),
      'expiresAt': r.expiresAt?.toIso8601String(),
      'authorAvatarUrl': r.authorAvatarUrl,
    };
  }

  static PhotoRound roundFromJson(Map<String, dynamic> json) {
    final geo = json['realLocation'] as Map<String, dynamic>;
    return PhotoRound(
      id: json['id'] as String,
      authorUid: json['authorUid'] as String,
      authorName: json['authorName'] as String,
      photoUrl: json['photoUrl'] as String,
      realLocation: LatLng(
        (geo['lat'] as num).toDouble(),
        (geo['lng'] as num).toDouble(),
      ),
      invitedUids: List<String>.from(json['invitedUids'] ?? []),
      guesses: (json['guesses'] as List<dynamic>? ?? [])
          .map((g) => _guessFromJson(g as Map<String, dynamic>))
          .toList(),
      status: RoundStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => RoundStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
    );
  }

  static Map<String, dynamic> _guessToJson(Guess g) => {
        'uid': g.uid,
        'displayName': g.displayName,
        'guessedLocation': {
          'lat': g.guessedLocation.latitude,
          'lng': g.guessedLocation.longitude,
        },
        'distanceMeters': g.distanceMeters,
        'score': g.score,
        'submittedAt': g.submittedAt.toIso8601String(),
        if (g.avatarUrl != null) 'avatarUrl': g.avatarUrl,
      };

  static Guess _guessFromJson(Map<String, dynamic> json) {
    final geo = json['guessedLocation'] as Map<String, dynamic>;
    return Guess(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String,
      guessedLocation: LatLng(
        (geo['lat'] as num).toDouble(),
        (geo['lng'] as num).toDouble(),
      ),
      distanceMeters: (json['distanceMeters'] as num).toDouble(),
      score: json['score'] as int? ?? 0,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  static Map<String, dynamic> userToJson(AppUser u) => {
        'uid': u.uid,
        ...u.toMap(),
        'createdAt': u.createdAt.toIso8601String(),
      };

  static AppUser userFromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      displayName: json['displayName'] as String? ?? 'Игрок',
      email: json['email'] as String? ?? '',
      friendCode: json['friendCode'] as String? ?? '',
      totalScore: json['totalScore'] as int? ?? 0,
      roundsPlayed: json['roundsPlayed'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static Map<String, dynamic> friendRequestToJson(FriendRequest r) => {
        'fromUid': r.fromUid,
        'fromName': r.fromName,
        'fromAvatarUrl': r.fromAvatarUrl,
        'createdAt': r.createdAt.toIso8601String(),
      };

  static FriendRequest friendRequestFromJson(Map<String, dynamic> json) {
    return FriendRequest(
      fromUid: json['fromUid'] as String,
      fromName: json['fromName'] as String? ?? 'Игрок',
      fromAvatarUrl: json['fromAvatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
