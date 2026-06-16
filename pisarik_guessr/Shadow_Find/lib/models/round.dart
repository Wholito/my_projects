import 'package:latlong2/latlong.dart';

enum RoundStatus { pending, active, completed }

class PhotoRound {
  final String id;
  final String authorUid;
  final String authorName;
  final String photoUrl;
  final LatLng realLocation;
  final List<String> invitedUids;
  final List<Guess> guesses;
  final RoundStatus status;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final String? authorAvatarUrl;
  final String? avatarUrl;


  PhotoRound({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.photoUrl,
    required this.realLocation,
    required this.invitedUids,
    this.guesses = const [],
    this.status = RoundStatus.pending,
    required this.createdAt,
    this.expiresAt,
    this.authorAvatarUrl,
    this.avatarUrl,
  });

  factory PhotoRound.fromMap(Map<String, dynamic> map, String id) {
    final geo = map['realLocation'] as Map<String, dynamic>;
    return PhotoRound(
      id: id,
      authorUid: map['authorUid'],
      authorName: map['authorName'],
      photoUrl: map['photoUrl'],
      realLocation: LatLng(
        (geo['lat'] as num).toDouble(),
        (geo['lng'] as num).toDouble(),
      ),
      invitedUids: List<String>.from(map['invitedUids'] ?? []),
      guesses: (map['guesses'] as List<dynamic>? ?? [])
          .map((g) => Guess.fromMap(g as Map<String, dynamic>))
          .toList(),
      status: RoundStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => RoundStatus.pending,
      ),
      createdAt: (map['createdAt'] as dynamic).toDate(),
      expiresAt: map['expiresAt'] != null
          ? (map['expiresAt'] as dynamic).toDate()
          : null,
      authorAvatarUrl: map['authorAvatarUrl'],
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() => {
        'authorUid': authorUid,
        'authorName': authorName,
        'photoUrl': photoUrl,
        'realLocation': {
          'lat': realLocation.latitude,
          'lng': realLocation.longitude,

        },
        'invitedUids': invitedUids,
        'guesses': guesses.map((g) => g.toMap()).toList(),
        'status': status.name,
        'createdAt': createdAt,
        'expiresAt': expiresAt,
        'authorAvatarUrl': authorAvatarUrl,
        'avatarUrl': avatarUrl,
      };

  bool hasGuessedBy(String uid) => guesses.any((g) => g.uid == uid);

  List<Guess> get sortedGuesses {
    final sorted = [...guesses];
    sorted.sort((a, b) => b.score.compareTo(a.score));
    return sorted;
  }
}

class Guess {
  final String uid;
  final String displayName;
  final LatLng guessedLocation;
  final double distanceMeters;
  final int score;
  final DateTime submittedAt;
  final String? avatarUrl;

  Guess({
    required this.uid,
    required this.displayName,
    required this.guessedLocation,
    required this.distanceMeters,
    required this.score,
    required this.submittedAt,
    this.avatarUrl,
  });

  factory Guess.fromMap(Map<String, dynamic> map) {
    final geo = map['guessedLocation'] as Map<String, dynamic>;
    return Guess(
      uid: map['uid'],
      displayName: map['displayName'],
      guessedLocation: LatLng(
        (geo['lat'] as num).toDouble(),
        (geo['lng'] as num).toDouble(),
      ),
      distanceMeters: (map['distanceMeters'] as num).toDouble(),
      score: map['score'] ?? 0,
      submittedAt: (map['submittedAt'] as dynamic).toDate(),
      avatarUrl: map['avatarUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'uid': uid,
      'displayName': displayName,
      'guessedLocation': {
        'lat': guessedLocation.latitude,
        'lng': guessedLocation.longitude,
      },
      'distanceMeters': distanceMeters,
      'score': score,
      'submittedAt': submittedAt,
    };
    if (avatarUrl != null) map['avatarUrl'] = avatarUrl;
    return map;
  }

  String get formattedDistance {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} м';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} км';
  }
}
