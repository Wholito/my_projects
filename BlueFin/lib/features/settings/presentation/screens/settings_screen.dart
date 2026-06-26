import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import '../../domain/entities/user_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _currencyController;
  late TextEditingController _languageController;
  bool _darkMode = false;
  bool _notifications = true;

  @override
  void initState() {
    super.initState();
    _currencyController = TextEditingController();
    _languageController = TextEditingController();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  void dispose() {
    _currencyController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  void _saveSettings(UserSettings currentSettings) {
    final newSettings = currentSettings.copyWith(
      currency: _currencyController.text.isNotEmpty ? _currencyController.text : currentSettings.currency,
      darkMode: _darkMode,
      notificationsEnabled: _notifications,
      language: _languageController.text.isNotEmpty ? _languageController.text : currentSettings.language,
    );
    context.read<SettingsCubit>().saveSettings(newSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state is SettingsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is SettingsSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Настройки сохранены')),
            );
          }
        },
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SettingsLoaded) {
            final settings = state.settings;
            _currencyController.text = settings.currency;
            _languageController.text = settings.language ?? '';
            _darkMode = settings.darkMode;
            _notifications = settings.notificationsEnabled;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Основная валюта (например, RUB)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _languageController,
                    decoration: const InputDecoration(
                      labelText: 'Язык (например, ru, en)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Тёмная тема'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Уведомления'),
                    value: _notifications,
                    onChanged: (value) {
                      setState(() {
                        _notifications = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _saveSettings(settings),
                    child: const Text('Сохранить'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthSignOutRequested());
                    },
                    child: const Text('Выйти'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Ошибка загрузки настроек'));
          }
        },
      ),
    );
  }
}