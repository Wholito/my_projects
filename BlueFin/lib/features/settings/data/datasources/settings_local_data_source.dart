import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_settings.dart';

abstract class ISettingsLocalDataSource {
  Future<UserSettings?> getSettings();
  Future<void> saveSettings(UserSettings settings);
}

class SettingsLocalDataSource implements ISettingsLocalDataSource {
  final SharedPreferences prefs;

  SettingsLocalDataSource(this.prefs);

  @override
  Future<UserSettings?> getSettings() async {
    try {
      final currency = prefs.getString('settings_currency') ?? 'BYN';
      final darkMode = prefs.getBool('settings_darkMode') ?? false;
      final notifications = prefs.getBool('settings_notifications') ?? true;
      final language = prefs.getString('settings_language');
      return UserSettings(
        currency: currency,
        darkMode: darkMode,
        notificationsEnabled: notifications,
        language: language,
      );
    } catch (e) {
      throw CacheException('Failed to load settings: $e');
    }
  }

  @override
  Future<void> saveSettings(UserSettings settings) async {
    try {
      await prefs.setString('settings_currency', settings.currency);
      await prefs.setBool('settings_darkMode', settings.darkMode);
      await prefs.setBool('settings_notifications', settings.notificationsEnabled);
      if (settings.language != null) {
        await prefs.setString('settings_language', settings.language!);
      } else {
        await prefs.remove('settings_language');
      }
    } catch (e) {
      throw CacheException('Failed to save settings: $e');
    }
  }
}