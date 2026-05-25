class FriendRequest {
  final String fromUid;
  final String fromName;
  final String? fromAvatarUrl;
  final DateTime createdAt;

  const FriendRequest({
    required this.fromUid,
    required this.fromName,
    this.fromAvatarUrl,
    required this.createdAt,
  });

  factory FriendRequest.fromMap(Map<String, dynamic> map, String fromUid) {
    return FriendRequest(
      fromUid: fromUid,
      fromName: map['fromName'] as String? ?? 'Игрок',
      fromAvatarUrl: map['fromAvatarUrl'] as String?,
      createdAt: (map['createdAt'] as dynamic).toDate(),
    );
  }
}
