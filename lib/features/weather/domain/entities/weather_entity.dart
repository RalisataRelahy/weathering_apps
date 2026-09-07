import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  final String city;
  final double temperature;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime date;
  final bool isCached;

  const WeatherEntity({
    required this.city,
    required this.temperature,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.date,
    this.isCached = false,
  });

  WeatherEntity copyWith({bool? isCached}) {
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
      isCached: isCached ?? this.isCached,
    );
  }

  @override
  List<Object?> get props => [
        city,
        temperature,
        tempMin,
        tempMax,
        humidity,
        windSpeed,
        description,
        icon,
        date,
        isCached,
      ];
}
