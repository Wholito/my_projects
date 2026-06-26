import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();

  factory SupabaseService() => _instance;

  SupabaseService._internal();

  late final SupabaseClient client;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Supabase.initialize(
      url: 'https://xzrqwxflkvnvnbzcfgov.supabase.co',
      anonKey: 'sb_publishable_F3Ml4XXG7inqaWHLl2Q-eA_f9lS33EB',
    );
    client = Supabase.instance.client;
    _initialized = true;
  }

  SupabaseClient get getClient {
    if (!_initialized) {
      throw StateError('Supabase не инициализирован. Сначала вызовите init()');
    }
    return client;
  }
}
