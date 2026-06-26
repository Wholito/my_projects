class UserSettings {
  final String currency;
  final bool darkMode;
  final bool notificationsEnabled;
  final String? language;

  const UserSettings({
    this.currency = 'BYN',
    this.darkMode = false,
    this.notificationsEnabled = true,
    this.language,
  });

  UserSettings copyWith({
    String? currency,
    bool? darkMode,
    bool? notificationsEnabled,
    String? language,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is UserSettings &&
              runtimeType == other.runtimeType &&
              currency == other.currency &&
              darkMode == other.darkMode &&
              notificationsEnabled == other.notificationsEnabled &&
              language == other.language;

  @override
  int get hashCode => Object.hash(currency, darkMode, notificationsEnabled, language);
}