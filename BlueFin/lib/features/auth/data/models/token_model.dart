class TokenModel {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  TokenModel({required this.accessToken, this.refreshToken, required this.expiresAt});

  factory TokenModel.fromJson(Map<String, dynamic> json) => TokenModel(
    accessToken: json['accessToken'] as String,
    refreshToken: json['refreshToken'] as String?,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toIso8601String(),
  };
}