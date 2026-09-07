import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase(this.repository);

  Future<WeatherEntity> call(String city) {
    return repository.getCurrentWeather(city);
  }
}
