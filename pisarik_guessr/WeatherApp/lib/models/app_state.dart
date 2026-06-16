import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../themes/app_theme.dart';
import '../services/weather_service.dart';
import 'forecast_model.dart';
import 'weather_model.dart';

class AppState extends ChangeNotifier with WidgetsBindingObserver {
  String _themeMode = 'system';
  String get themeMode => _themeMode;

  Locale _locale = const Locale('ru');
  Locale get locale => _locale;

  WeatherModel? _weather;
  WeatherModel? get weather => _weather;

  List<ForecastDay> _forecastDays = [];
  List<ForecastDay> get forecastDays => _forecastDays;

  List<SavedCity> _favoriteCities = [];
  List<SavedCity> get favoriteCities => List.unmodifiable(_favoriteCities);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentCity = 'London';
  String get currentCity => _currentCity;

  bool _isLoadingLocation = false;
  bool get isLoadingLocation => _isLoadingLocation;

  final WeatherService _weatherService = WeatherService();

  AppState() {
    _loadSettings();
    WidgetsBinding.instance.addObserver(this);
    _loadWeatherWithLocation();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  String _getApiLanguage() {
    return _locale.languageCode == 'ru' ? 'ru' : 'en';
  }

  bool get isDarkMode {
    if (_themeMode == 'dark') return true;
    if (_themeMode == 'light') return false;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == 'system') {
      notifyListeners();
    }
  }

  bool isCurrentCityFavorite() {
    if (_weather == null) return false;
    return _favoriteCities.any(
      (c) =>
          c.name == _weather!.location.name &&
          c.country == _weather!.location.country,
    );
  }

  Future<void> toggleCurrentCityFavorite() async {
    if (_weather == null) return;
    final loc = _weather!.location;
    final city = SavedCity(
      name: loc.name,
      country: loc.country,
      region: loc.region,
    );
    if (isCurrentCityFavorite()) {
      _favoriteCities.removeWhere(
        (c) => c.name == city.name && c.country == city.country,
      );
    } else {
      _favoriteCities.add(city);
    }
    await _persistFavorites();
    notifyListeners();
  }

  Future<void> removeFavorite(SavedCity city) async {
    _favoriteCities.removeWhere(
      (c) => c.name == city.name && c.country == city.country,
    );
    await _persistFavorites();
    notifyListeners();
  }

  Future<void> _persistFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _favoriteCities.map((c) => c.toJson()).toList();
    await prefs.setString('favoriteCities', json.encode(encoded));
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = prefs.getString('themeMode') ?? 'system';
    final savedLanguage = prefs.getString('language');
    if (savedLanguage != null) {
      _locale = Locale(savedLanguage);
    }
    final favRaw = prefs.getString('favoriteCities');
    if (favRaw != null) {
      final list = json.decode(favRaw) as List<dynamic>;
      _favoriteCities = list
          .map((e) => SavedCity.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    notifyListeners();
  }

  Future<void> setThemeMode(String mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode);
    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    _locale = Locale(languageCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    notifyListeners();
    await loadWeather(city: _currentCity);
  }

  ThemeData get currentTheme {
    return isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  Future<void> _loadWeatherWithLocation() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          await _loadDefaultWeather();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _loadDefaultWeather();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentCity = placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            placemarks.first.country ??
            'Unknown';
        await _saveLastCity(_currentCity);
      }

      _weather = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
        lang: _getApiLanguage(),
      );
      await _loadForecastForCurrent();
      _errorMessage = '';
    } catch (e) {
      await _loadDefaultWeather();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDefaultWeather() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCity = prefs.getString('lastCity');
      if (lastCity != null && lastCity.isNotEmpty) {
        _currentCity = lastCity;
        _weather = await _weatherService.getWeatherByCity(
          lastCity,
          lang: _getApiLanguage(),
        );
      } else {
        _currentCity = 'London';
        _weather = await _weatherService.getWeatherByCity(
          'London',
          lang: _getApiLanguage(),
        );
      }
      await _loadForecastForCurrent();
    } catch (e) {
      _setErrorFrom(e);
      _weather = null;
      _forecastDays = [];
    }
  }

  Future<void> loadWeather({String? city}) async {
    if (city != null) {
      _currentCity = city;
      await _saveLastCity(city);
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _weather = await _weatherService.getWeatherByCity(
        _currentCity,
        lang: _getApiLanguage(),
      );
      await _loadForecastForCurrent();
    } catch (e) {
      _setErrorFrom(e);
      _weather = null;
      _forecastDays = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadForecastForCurrent() async {
    if (_weather == null) {
      _forecastDays = [];
      return;
    }
    final loc = _weather!.location;
    final query = loc.region.isNotEmpty ? '${loc.name},${loc.region}' : loc.name;
    final bundle = await _weatherService.getForecast(
      query,
      lang: _getApiLanguage(),
      days: 3,
    );
    _forecastDays = bundle.days;
  }

  Future<void> changeCity(String newCity) async {
    await loadWeather(city: newCity);
  }

  Future<void> openFavoriteCity(SavedCity city) async {
    final q = city.region.isNotEmpty ? '${city.name},${city.region}' : city.name;
    await loadWeather(city: q);
  }

  Future<List<CitySuggestion>> searchCities(String query) async {
    return _weatherService.searchCities(query);
  }

  Future<void> _saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lastCity', city);
  }

  Future<void> getWeatherByCurrentLocation() async {
    _isLoadingLocation = true;
    _errorMessage = '';
    notifyListeners();

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('location_denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('location_denied_forever');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        _currentCity = placemarks.first.locality ??
            placemarks.first.administrativeArea ??
            placemarks.first.country ??
            'Unknown';
        await _saveLastCity(_currentCity);
      }

      _weather = await _weatherService.getWeatherByLocation(
        position.latitude,
        position.longitude,
        lang: _getApiLanguage(),
      );
      await _loadForecastForCurrent();
      _errorMessage = '';
    } catch (e) {
      _setErrorFrom(e);
      _weather = null;
      _forecastDays = [];
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void _setErrorFrom(Object error) {
    final raw = error.toString();
    if (raw.contains('location_denied_forever')) {
      _errorMessage = 'location_denied_forever';
    } else if (raw.contains('location_denied')) {
      _errorMessage = 'location_denied';
    } else if (_looksLikeNetworkError(raw)) {
      _errorMessage = 'offline';
    } else {
      _errorMessage = 'error';
    }
  }

  bool _looksLikeNetworkError(String message) {
    final lower = message.toLowerCase();
    return lower.contains('socket') ||
        lower.contains('clientexception') ||
        lower.contains('host lookup') ||
        lower.contains('weatherapi') ||
        lower.contains('connection timed out') ||
        lower.contains('network is unreachable');
  }
}
