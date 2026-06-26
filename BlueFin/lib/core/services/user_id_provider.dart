import 'package:shared_preferences/shared_preferences.dart';

class UserIdProvider {
  final SharedPreferences prefs;
  UserIdProvider(this.prefs);

  String get userId => prefs.getString('user_id') ?? '';
}