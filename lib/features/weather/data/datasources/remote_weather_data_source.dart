import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/forecast_model.dart';
import '../models/weather_model.dart';

abstract class RemoteWeatherDataSource {
  Future<WeatherModel> getCurrentWeather(String city);
  Future<ForecastModel> getForecast(String city);
}

class RemoteWeatherDataSourceImpl implements RemoteWeatherDataSource {
  final Dio dio;
  final String? apiKey;

  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  RemoteWeatherDataSourceImpl({
    required this.dio,
    this.apiKey,
  });

  String get _apiKey => apiKey ?? dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  @override
  Future<WeatherModel> getCurrentWeather(String city) async {
    try {
      final response = await dio.get(
        '$baseUrl/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map);
        return WeatherModel.fromJson(data);
      } else {
        throw ServerException('Unable to load weather data');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('City not found');
      }
      throw ServerException(e.message ?? 'Unable to load weather data');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<ForecastModel> getForecast(String city) async {
    try {
      final response = await dio.get(
        '$baseUrl/forecast',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map);
        return ForecastModel.fromJson(data);
      } else {
        throw ServerException('Unable to load weather data');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException('City not found');
      }
      throw ServerException(e.message ?? 'Unable to load weather data');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
