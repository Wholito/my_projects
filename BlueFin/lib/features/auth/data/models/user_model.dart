import '../../domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;

  UserModel({required this.id, required this.email, this.name, this.photoUrl});

  factory UserModel.fromDomain(User user) => UserModel(
    id: user.id,
    email: user.email,
    name: user.name,
    photoUrl: user.photoUrl,
  );

  User toDomain() => User(
    id: id,
    email: email,
    name: name,
    photoUrl: photoUrl,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
  };
}