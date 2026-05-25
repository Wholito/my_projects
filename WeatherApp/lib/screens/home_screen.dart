import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_state.dart';
import '../models/forecast_model.dart';
import '../services/weather_service.dart';
import '../themes/app_theme.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<CitySuggestion> _suggestions = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchController.text.length >= 2) {
        _searchCities(_searchController.text);
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    });
  }

  Future<void> _searchCities(String query) async {
    setState(() {
      _isSearching = true;
    });
    final appState = Provider.of<AppState>(context, listen: false);
    final results = await appState.searchCities(query);
    if (!mounted) return;
    setState(() {
      _suggestions = results;
      _isSearching = false;
    });
  }

  void _selectCity(CitySuggestion city) {
    _searchController.text = city.displayName;
    setState(() {
      _suggestions = [];
    });
    _searchFocusNode.unfocus();
    Provider.of<AppState>(context, listen: false).changeCity(city.name);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesScreen()),
              );
            },
            tooltip: l10n.favorites,
          ),
          IconButton(
            icon: Icon(
              appState.isLoadingLocation
                  ? Icons.hourglass_empty
                  : Icons.my_location,
            ),
            onPressed: appState.isLoadingLocation
                ? null
                : () async {
                    await appState.getWeatherByCurrentLocation();
                    if (appState.weather != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${l10n.weatherLoaded} ${appState.weather!.location.name}',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
            tooltip: l10n.myLocation,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(l10n),
            Expanded(
              child: _buildContent(appState, l10n, screenWidth),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.clearSearch,
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _suggestions = [];
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          if (_suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  final city = _suggestions[index];
                  return ListTile(
                    title: Text(city.name),
                    subtitle: Text(city.country),
                    onTap: () => _selectCity(city),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
    AppState appState,
    AppLocalizations l10n,
    double screenWidth,
  ) {
    if (appState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingWeather),
          ],
        ),
      );
    }

    if (appState.isLoadingLocation) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.loadingLocation),
          ],
        ),
      );
    }

    if (appState.errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _localizedError(appState.errorMessage, l10n),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => appState.loadWeather(),
              child: Text(l10n.retry),
            ),
          ],
        ),
      );
    }

    if (appState.weather == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_queue, size: 80, color: Colors.grey.shade500),
            const SizedBox(height: 16),
            Text(l10n.enterCity),
          ],
        ),
      );
    }

    final weather = appState.weather!;

    return RefreshIndicator(
      onRefresh: () => appState.loadWeather(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildWeatherCard(weather, appState, l10n, screenWidth),
              const SizedBox(height: 12),
              _buildDetailsRow(weather, l10n),
              const SizedBox(height: 12),
              _buildExtraDetailsRow(weather, l10n),
              if (appState.forecastDays.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.forecastTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _buildForecastRow(appState.forecastDays, l10n),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
    dynamic weather,
    AppState appState,
    AppLocalizations l10n,
    double screenWidth,
  ) {
    final isSmallScreen = screenWidth < 450;
    final isFav = appState.isCurrentCityFavorite();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${weather.location.name}, ${weather.location.country}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => appState.toggleCurrentCityFavorite(),
                icon: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: Colors.white,
                ),
                tooltip: isFav ? l10n.removeFavorite : l10n.addFavorite,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            weather.location.localTime,
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  '${weather.current.tempC.round()}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 48 : 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  l10n.celsius,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${l10n.feelsLike} ${weather.current.feelsLikeC.round()}${l10n.celsius}',
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 15,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https:${weather.current.condition.icon}',
                width: isSmallScreen ? 40 : 45,
                height: isSmallScreen ? 40 : 45,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.cloud,
                    size: isSmallScreen ? 40 : 45,
                    color: Colors.white,
                  );
                },
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  weather.current.condition.text,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 16,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsRow(dynamic weather, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            icon: Icons.air,
            value: '${weather.current.windKph.round()}',
            unit: l10n.kmh,
            label: l10n.wind,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDetailCard(
            icon: Icons.water_drop,
            value: '${weather.current.humidity}',
            unit: '%',
            label: l10n.humidity,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDetailCard(
            icon: Icons.cloud,
            value: '${weather.current.cloud}',
            unit: '%',
            label: l10n.cloudiness,
          ),
        ),
      ],
    );
  }

  Widget _buildExtraDetailsRow(dynamic weather, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildDetailCard(
            icon: Icons.speed,
            value: weather.current.pressureMb.round().toString(),
            unit: l10n.hPa,
            label: l10n.pressure,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDetailCard(
            icon: Icons.visibility,
            value: weather.current.visKm.round().toString(),
            unit: l10n.km,
            label: l10n.visibility,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildDetailCard(
            icon: Icons.wb_sunny_outlined,
            value: weather.current.uv.round().toString(),
            unit: '',
            label: l10n.uvIndex,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastRow(List<ForecastDay> days, AppLocalizations l10n) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = days[index];
          return Container(
            width: 110,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day.date.length >= 10 ? day.date.substring(5) : day.date,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Image.network(
                  'https:${day.conditionIcon}',
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => const Icon(Icons.cloud, size: 32),
                ),
                const SizedBox(height: 4),
                Text(
                  '${day.minTempC.round()}° / ${day.maxTempC.round()}°',
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: AppTheme.primaryColor),
          const SizedBox(height: 6),
          Text(
            '$value$unit',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _localizedError(String code, AppLocalizations l10n) {
    if (code == 'offline' || _looksLikeNetworkError(code)) {
      return l10n.noInternet;
    }
    if (code == 'location_denied_forever') {
      return l10n.locationPermissionPermanentlyDenied;
    }
    if (code.contains('location_denied')) {
      return l10n.locationPermissionDenied;
    }
    return l10n.errorLoading;
  }

  bool _looksLikeNetworkError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('socket') ||
        lower.contains('clientexception') ||
        lower.contains('host lookup') ||
        lower.contains('weatherapi');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
