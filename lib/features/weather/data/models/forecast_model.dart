import '../../domain/entities/forecast_entity.dart';
import 'weather_model.dart';

class ForecastModel {
  final String cityName;
  final List<WeatherModel> forecasts;

  const ForecastModel({
    required this.cityName,
    required this.forecasts,
  });

  factory ForecastModel.fromJson(Map<String, dynamic> json) {
    final cityObj = json['city'] as Map<String, dynamic>? ?? {};
    final cityName = (cityObj['name'] as String?) ?? (json['cityName'] as String?) ?? 'Unknown';
    final list = (json['list'] as List<dynamic>?) ?? [];

    final forecastModels = list.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return WeatherModel.fromJson(map, defaultCity: cityName);
    }).toList();

    return ForecastModel(
      cityName: cityName,
      forecasts: forecastModels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'city': {'name': cityName},
      'list': forecasts.map((e) => e.toJson()).toList(),
    };
  }

  ForecastEntity toEntity({bool isCached = false}) {
    return ForecastEntity(
      cityName: cityName,
      forecasts: forecasts.map((e) => e.toEntity(isCached: isCached)).toList(),
      isCached: isCached,
    );
  }
}
