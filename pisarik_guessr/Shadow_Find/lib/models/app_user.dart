
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String friendCode;
  final int totalScore;
  final int roundsPlayed;
  final String? avatarUrl;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.friendCode,
    this.totalScore = 0,
    this.roundsPlayed = 0,
    this.avatarUrl,
    required this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      displayName: map['displayName'] ?? 'Игрок',
      email: map['email'] ?? '',
      friendCode: map['friendCode'] ?? '',
      totalScore: map['totalScore'] ?? 0,
      roundsPlayed: map['roundsPlayed'] ?? 0,
      avatarUrl: map['avatarUrl'],
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'email': email,
        'friendCode': friendCode,
        'totalScore': totalScore,
        'roundsPlayed': roundsPlayed,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt,
      };

  double get averageScore =>
      roundsPlayed > 0 ? totalScore / roundsPlayed : 0.0;
}
