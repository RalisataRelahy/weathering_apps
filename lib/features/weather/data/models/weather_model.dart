import '../../domain/entities/weather_entity.dart';

class WeatherModel {
  final String city;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime date;

  const WeatherModel({
    required this.city,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.date,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json, {String? defaultCity}) {
    final main = json['main'] as Map<String, dynamic>? ?? {};
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final weatherFirst = weatherList.isNotEmpty
        ? weatherList.first as Map<String, dynamic>
        : <String, dynamic>{};
    final wind = json['wind'] as Map<String, dynamic>? ?? {};

    final dt = json['dt'] as int?;
    final dateTime = dt != null
        ? DateTime.fromMillisecondsSinceEpoch(dt * 1000, isUtc: true)
        : (json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : DateTime.now());

    return WeatherModel(
      city: (json['name'] as String?) ?? defaultCity ?? 'Unknown',
      temperature: (main['temp'] as num?)?.toDouble() ?? 0.0,
      tempMin: (main['temp_min'] as num?)?.toDouble() ?? 0.0,
      tempMax: (main['temp_max'] as num?)?.toDouble() ?? 0.0,
      humidity: (main['humidity'] as num?)?.toInt() ?? 0,
      windSpeed: (wind['speed'] as num?)?.toDouble() ?? 0.0,
      description: (weatherFirst['description'] as String?) ?? '',
      icon: (weatherFirst['icon'] as String?) ?? '01d',
      date: dateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': city,
      'main': {
        'temp': temperature,
        'temp_min': tempMin,
        'temp_max': tempMax,
        'humidity': humidity,
      },
      'wind': {
        'speed': windSpeed,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
        }
      ],
      'dt': date.millisecondsSinceEpoch ~/ 1000,
      'date': date.toIso8601String(),
    };
  }

  WeatherEntity toEntity({bool isCached = false}) {
    return WeatherEntity(
      city: city,
      temperature: temperature,
      tempMin: tempMin,
      tempMax: tempMax,
      humidity: humidity,
      windSpeed: windSpeed,
      description: description,
      icon: icon,
      date: date,
      isCached: isCached,
    );
  }

  factory WeatherModel.fromEntity(WeatherEntity entity) {
    return WeatherModel(
      city: entity.city,
      temperature: entity.temperature,
      tempMin: entity.tempMin,
      tempMax: entity.tempMax,
      humidity: entity.humidity,
      windSpeed: entity.windSpeed,
      description: entity.description,
      icon: entity.icon,
      date: entity.date,
    );
  }
}
