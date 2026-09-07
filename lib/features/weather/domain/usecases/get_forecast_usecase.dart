import '../entities/forecast_entity.dart';
import '../repositories/weather_repository.dart';

class GetForecastUseCase {
  final WeatherRepository repository;

  GetForecastUseCase(this.repository);

  Future<ForecastEntity> call(String city) {
    return repository.getForecast(city);
  }
}
