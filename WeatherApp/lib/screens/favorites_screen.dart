import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_state.dart';
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoritesTitle),
      ),
      body: appState.favoriteCities.isEmpty
          ? Center(child: Text(l10n.noFavorites))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: appState.favoriteCities.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final city = appState.favoriteCities[index];
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(city.label),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => appState.removeFavorite(city),
                    ),
                    onTap: () async {
                      await appState.openFavoriteCity(city);
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
