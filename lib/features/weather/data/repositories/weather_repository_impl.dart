import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/local_weather_data_source.dart';
import '../datasources/remote_weather_data_source.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  final RemoteWeatherDataSource remoteDataSource;
  final LocalWeatherDataSource localDataSource;
  final NetworkInfo networkInfo;

  WeatherRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<WeatherEntity> getCurrentWeather(String city) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteModel = await remoteDataSource.getCurrentWeather(city);
        await localDataSource.cacheCurrentWeather(city, remoteModel);
        return remoteModel.toEntity(isCached: false);
      } catch (remoteError) {
        final cachedModel = await localDataSource.getLastCurrentWeather(city);
        if (cachedModel != null) {
          return cachedModel.toEntity(isCached: true);
        }
        if (remoteError is ServerException) {
          rethrow;
        }
        throw ServerException('Unable to load weather data');
      }
    } else {
      final cachedModel = await localDataSource.getLastCurrentWeather(city);
      if (cachedModel != null) {
        return cachedModel.toEntity(isCached: true);
      }
      throw NoInternetException('No internet connection');
    }
  }

  @override
  Future<ForecastEntity> getForecast(String city) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteModel = await remoteDataSource.getForecast(city);
        await localDataSource.cacheForecast(city, remoteModel);
        return remoteModel.toEntity(isCached: false);
      } catch (remoteError) {
        final cachedModel = await localDataSource.getLastForecast(city);
        if (cachedModel != null) {
          return cachedModel.toEntity(isCached: true);
        }
        if (remoteError is ServerException) {
          rethrow;
        }
        throw ServerException('Unable to load weather data');
      }
    } else {
      final cachedModel = await localDataSource.getLastForecast(city);
      if (cachedModel != null) {
        return cachedModel.toEntity(isCached: true);
      }
      throw NoInternetException('No internet connection');
    }
  }
}
