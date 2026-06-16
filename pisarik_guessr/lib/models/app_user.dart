class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.friendCode,
    this.photoUrl,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? friendCode,
    String? photoUrl,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      friendCode: friendCode ?? this.friendCode,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
  final String id;
  final String email;
  final String displayName;
  final String friendCode;
  final String? photoUrl;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      id: id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Игрок',
      friendCode: data['friendCode'] as String? ?? '',
      photoUrl: data['photoURL'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'email': email,
    'displayName': displayName,
    'friendCode': friendCode,
    if (photoUrl != null) 'photoURL': photoUrl,
  };
}
