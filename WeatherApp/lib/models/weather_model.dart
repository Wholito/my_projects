import 'package:json_annotation/json_annotation.dart';

part 'weather_model.g.dart';

@JsonSerializable()
class WeatherModel {
  final Location location;
  final Current current;

  WeatherModel({
    required this.location,
    required this.current,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) =>
      _$WeatherModelFromJson(json);

  Map<String, dynamic> toJson() => _$WeatherModelToJson(this);
}

@JsonSerializable()
class Location {
  final String name;
  final String region;
  final String country;
  @JsonKey(name: 'localtime')
  final String localTime;

  Location({
    required this.name,
    required this.region,
    required this.country,
    required this.localTime,
  });

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);
}

@JsonSerializable()
class Current {
  @JsonKey(name: 'temp_c')
  final double tempC;
  @JsonKey(name: 'condition')
  final Condition condition;
  @JsonKey(name: 'wind_kph')
  final double windKph;
  @JsonKey(name: 'humidity')
  final int humidity;
  @JsonKey(name: 'cloud')
  final int cloud;
  @JsonKey(name: 'feelslike_c')
  final double feelsLikeC;
  @JsonKey(name: 'pressure_mb')
  final double pressureMb;
  @JsonKey(name: 'vis_km')
  final double visKm;
  @JsonKey(name: 'uv')
  final double uv;

  Current({
    required this.tempC,
    required this.condition,
    required this.windKph,
    required this.humidity,
    required this.cloud,
    required this.feelsLikeC,
    this.pressureMb = 0,
    this.visKm = 0,
    this.uv = 0,
  });

  factory Current.fromJson(Map<String, dynamic> json) =>
      _$CurrentFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentToJson(this);
}

@JsonSerializable()
class Condition {
  final String text;
  final String icon;

  Condition({
    required this.text,
    required this.icon,
  });

  factory Condition.fromJson(Map<String, dynamic> json) =>
      _$ConditionFromJson(json);

  Map<String, dynamic> toJson() => _$ConditionToJson(this);
}