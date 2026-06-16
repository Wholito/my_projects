import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settingsTitle),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(localizations.appearance, context),

          RadioListTile<String>(
            title: Text(localizations.lightTheme),
            value: 'light',
            groupValue: appState.themeMode,
            onChanged: (value) => appState.setThemeMode(value!),
          ),

          RadioListTile<String>(
            title: Text(localizations.darkTheme),
            value: 'dark',
            groupValue: appState.themeMode,
            onChanged: (value) => appState.setThemeMode(value!),
          ),

          RadioListTile<String>(
            title: Text(localizations.systemTheme),
            value: 'system',
            groupValue: appState.themeMode,
            onChanged: (value) => appState.setThemeMode(value!),
          ),

          const Divider(height: 32),

          _buildSectionHeader(localizations.languageTitle, context),

          RadioListTile<String>(
            title: Text(localizations.russian),
            value: 'ru',
            groupValue: appState.locale.languageCode,
            onChanged: (value) => appState.setLanguage(value!),
          ),

          RadioListTile<String>(
            title: Text(localizations.english),
            value: 'en',
            groupValue: appState.locale.languageCode,
            onChanged: (value) => appState.setLanguage(value!),
          ),

          const Divider(height: 32),

          _buildSectionHeader(localizations.about, context),

          ListTile(
            title: Text(localizations.version),
            trailing: const Text('1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}