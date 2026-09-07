import 'dart:convert';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/hive_service.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

abstract class LocalWeatherDataSource {
  Future<void> cacheCurrentWeather(String city, WeatherModel weather);
  Future<WeatherModel?> getLastCurrentWeather(String city);
  Future<void> cacheForecast(String city, ForecastModel forecast);
  Future<ForecastModel?> getLastForecast(String city);
}

class LocalWeatherDataSourceImpl implements LocalWeatherDataSource {
  final HiveService hiveService;
  static const String boxName = HiveServiceImpl.weatherBoxName;

  LocalWeatherDataSourceImpl({required this.hiveService});

  String _currentWeatherKey(String city) => 'current_${city.trim().toLowerCase()}';
  String _forecastKey(String city) => 'forecast_${city.trim().toLowerCase()}';

  @override
  Future<void> cacheCurrentWeather(String city, WeatherModel weather) async {
    try {
      final jsonString = jsonEncode(weather.toJson());
      await hiveService.putData(boxName, _currentWeatherKey(city), jsonString);
    } catch (e) {
      throw CacheException('Failed to save weather data to cache');
    }
  }

  @override
  Future<WeatherModel?> getLastCurrentWeather(String city) async {
    try {
      final rawData = hiveService.getData(boxName, _currentWeatherKey(city));
      if (rawData == null) return null;

      final Map<String, dynamic> jsonMap = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : Map<String, dynamic>.from(rawData as Map);

      return WeatherModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException('Failed to read weather data from cache');
    }
  }

  @override
  Future<void> cacheForecast(String city, ForecastModel forecast) async {
    try {
      final jsonString = jsonEncode(forecast.toJson());
      await hiveService.putData(boxName, _forecastKey(city), jsonString);
    } catch (e) {
      throw CacheException('Failed to save forecast data to cache');
    }
  }

  @override
  Future<ForecastModel?> getLastForecast(String city) async {
    try {
      final rawData = hiveService.getData(boxName, _forecastKey(city));
      if (rawData == null) return null;

      final Map<String, dynamic> jsonMap = rawData is String
          ? jsonDecode(rawData) as Map<String, dynamic>
          : Map<String, dynamic>.from(rawData as Map);

      return ForecastModel.fromJson(jsonMap);
    } catch (e) {
      throw CacheException('Failed to read forecast data from cache');
    }
  }
}
