import '../entities/weather_entity.dart';
import '../entities/forecast_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getCurrentWeather(String city);
  Future<ForecastEntity> getForecast(String city);
}
