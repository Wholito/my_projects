# Weather App

<p align="center">
  <img src="assets/icon/icon.png" alt="Weather App icon" width="96">
</p>

Flutter-приложение погоды: текущая погода, прогноз на 3 дня, избранные города, геолокация, RU/EN, светлая и тёмная тема.

## Стек

- Flutter, Provider
- WeatherAPI.com (REST)
- geolocator, shared_preferences, flutter_dotenv

## Запуск

1. Скопируйте `.env.example` в `.env` и укажите ключ [WeatherAPI](https://www.weatherapi.com/).
2. `flutter pub get`
3. `dart run flutter_launcher_icons` (иконки уже сгенерированы)
4. `flutter run`

## Возможности

- Поиск города с подсказками
- Погода по GPS
- Прогноз на 3 дня
- Избранные города
- Давление, видимость, УФ-индекс
- Pull-to-refresh
