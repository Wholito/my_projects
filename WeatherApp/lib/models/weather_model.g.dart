// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WeatherModel _$WeatherModelFromJson(Map<String, dynamic> json) => WeatherModel(
  location: Location.fromJson(json['location'] as Map<String, dynamic>),
  current: Current.fromJson(json['current'] as Map<String, dynamic>),
);

Map<String, dynamic> _$WeatherModelToJson(WeatherModel instance) =>
    <String, dynamic>{
      'location': instance.location,
      'current': instance.current,
    };

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  name: json['name'] as String,
  region: json['region'] as String,
  country: json['country'] as String,
  localTime: json['localtime'] as String,
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'name': instance.name,
  'region': instance.region,
  'country': instance.country,
  'localtime': instance.localTime,
};

Current _$CurrentFromJson(Map<String, dynamic> json) => Current(
  tempC: (json['temp_c'] as num).toDouble(),
  condition: Condition.fromJson(json['condition'] as Map<String, dynamic>),
  windKph: (json['wind_kph'] as num).toDouble(),
  humidity: (json['humidity'] as num).toInt(),
  cloud: (json['cloud'] as num).toInt(),
  feelsLikeC: (json['feelslike_c'] as num).toDouble(),
  pressureMb: (json['pressure_mb'] as num?)?.toDouble() ?? 0,
  visKm: (json['vis_km'] as num?)?.toDouble() ?? 0,
  uv: (json['uv'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$CurrentToJson(Current instance) => <String, dynamic>{
  'temp_c': instance.tempC,
  'condition': instance.condition,
  'wind_kph': instance.windKph,
  'humidity': instance.humidity,
  'cloud': instance.cloud,
  'feelslike_c': instance.feelsLikeC,
  'pressure_mb': instance.pressureMb,
  'vis_km': instance.visKm,
  'uv': instance.uv,
};

Condition _$ConditionFromJson(Map<String, dynamic> json) =>
    Condition(text: json['text'] as String, icon: json['icon'] as String);

Map<String, dynamic> _$ConditionToJson(Condition instance) => <String, dynamic>{
  'text': instance.text,
  'icon': instance.icon,
};
