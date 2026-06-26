class User {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email &&
              name == other.name &&
              photoUrl == other.photoUrl;

  @override
  int get hashCode => Object.hash(id, email, name, photoUrl);
}