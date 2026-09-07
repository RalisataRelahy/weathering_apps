import 'package:equatable/equatable.dart';
import 'weather_entity.dart';

class ForecastEntity extends Equatable {
  final String cityName;
  final List<WeatherEntity> forecasts;
  final bool isCached;

  const ForecastEntity({
    required this.cityName,
    required this.forecasts,
    this.isCached = false,
  });

  ForecastEntity copyWith({bool? isCached}) {
    return ForecastEntity(
      cityName: cityName,
      forecasts: forecasts,
      isCached: isCached ?? this.isCached,
    );
  }

  @override
  List<Object?> get props => [cityName, forecasts, isCached];
}
