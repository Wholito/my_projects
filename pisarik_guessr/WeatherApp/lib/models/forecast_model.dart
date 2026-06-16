class ForecastBundle {
  final List<ForecastDay> days;

  ForecastBundle({required this.days});

  factory ForecastBundle.fromJson(Map<String, dynamic> json) {
    final forecast = json['forecast'] as Map<String, dynamic>?;
    if (forecast == null) {
      return ForecastBundle(days: []);
    }
    final list = forecast['forecastday'] as List<dynamic>? ?? [];
    return ForecastBundle(
      days: list
          .map((e) => ForecastDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ForecastDay {
  final String date;
  final double maxTempC;
  final double minTempC;
  final String conditionText;
  final String conditionIcon;

  ForecastDay({
    required this.date,
    required this.maxTempC,
    required this.minTempC,
    required this.conditionText,
    required this.conditionIcon,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    final day = json['day'] as Map<String, dynamic>;
    final condition = day['condition'] as Map<String, dynamic>;
    return ForecastDay(
      date: json['date'] as String? ?? '',
      maxTempC: (day['maxtemp_c'] as num).toDouble(),
      minTempC: (day['mintemp_c'] as num).toDouble(),
      conditionText: condition['text'] as String? ?? '',
      conditionIcon: condition['icon'] as String? ?? '',
    );
  }
}

class SavedCity {
  final String name;
  final String country;
  final String region;

  SavedCity({
    required this.name,
    required this.country,
    this.region = '',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'region': region,
      };

  factory SavedCity.fromJson(Map<String, dynamic> json) => SavedCity(
        name: json['name'] as String? ?? '',
        country: json['country'] as String? ?? '',
        region: json['region'] as String? ?? '',
      );

  String get label {
    if (region.isNotEmpty && region != name) {
      return '$name, $region';
    }
    return '$name, $country';
  }

  @override
  bool operator ==(Object other) =>
      other is SavedCity &&
      name == other.name &&
      country == other.country &&
      region == other.region;

  @override
  int get hashCode => Object.hash(name, country, region);
}
