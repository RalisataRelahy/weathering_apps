import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_offline/features/weather/domain/entities/weather_entity.dart';
import 'package:weather_offline/features/weather/domain/repositories/weather_repository.dart';
import 'package:weather_offline/features/weather/domain/usecases/get_current_weather_usecase.dart';

class MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late GetCurrentWeatherUseCase useCase;
  late MockWeatherRepository mockRepository;

  setUp(() {
    mockRepository = MockWeatherRepository();
    useCase = GetCurrentWeatherUseCase(mockRepository);
  });

  const tCity = 'London';
  final tWeather = WeatherEntity(
    city: tCity,
    temperature: 15.5,
    tempMin: 12.0,
    tempMax: 18.0,
    humidity: 75,
    windSpeed: 4.2,
    description: 'scattered clouds',
    icon: '03d',
    date: DateTime(2026, 9, 9),
    isCached: false,
  );

  test('should fetch current weather for the given city from repository', () async {
    // arrange
    when(() => mockRepository.getCurrentWeather(tCity))
        .thenAnswer((_) async => tWeather);

    // act
    final result = await useCase(tCity);

    // assert
    expect(result, equals(tWeather));
    verify(() => mockRepository.getCurrentWeather(tCity)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
