import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_offline/core/errors/exceptions.dart';
import 'package:weather_offline/core/network/network_info.dart';
import 'package:weather_offline/features/weather/data/datasources/local_weather_data_source.dart';
import 'package:weather_offline/features/weather/data/datasources/remote_weather_data_source.dart';
import 'package:weather_offline/features/weather/data/models/weather_model.dart';
import 'package:weather_offline/features/weather/data/repositories/weather_repository_impl.dart';

class MockRemoteWeatherDataSource extends Mock
    implements RemoteWeatherDataSource {}

class MockLocalWeatherDataSource extends Mock implements LocalWeatherDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late WeatherRepositoryImpl repository;
  late MockRemoteWeatherDataSource mockRemoteDataSource;
  late MockLocalWeatherDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  const tCity = 'Paris';
  final tDate = DateTime(2026, 9, 7);
  final tWeatherModel = WeatherModel(
    city: tCity,
    temperature: 20.0,
    tempMin: 18.0,
    tempMax: 22.0,
    humidity: 50,
    windSpeed: 5.0,
    description: 'clear sky',
    icon: '01d',
    date: tDate,
  );

  setUp(() {
    mockRemoteDataSource = MockRemoteWeatherDataSource();
    mockLocalDataSource = MockLocalWeatherDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = WeatherRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getCurrentWeather', () {
    test(
        '1. Internet available -> returns API data and saves response to Hive cache',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getCurrentWeather(tCity))
          .thenAnswer((_) async => tWeatherModel);
      when(() => mockLocalDataSource.cacheCurrentWeather(tCity, tWeatherModel))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.getCurrentWeather(tCity);

      // assert
      expect(result.city, equals(tCity));
      expect(result.isCached, isFalse);
      verify(() => mockRemoteDataSource.getCurrentWeather(tCity)).called(1);
      verify(() => mockLocalDataSource.cacheCurrentWeather(tCity, tWeatherModel))
          .called(1);
    });

    test('2. No Internet -> returns cached data from Hive', () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getLastCurrentWeather(tCity))
          .thenAnswer((_) async => tWeatherModel);

      // act
      final result = await repository.getCurrentWeather(tCity);

      // assert
      expect(result.city, equals(tCity));
      expect(result.isCached, isTrue);
      verify(() => mockLocalDataSource.getLastCurrentWeather(tCity)).called(1);
      verifyZeroInteractions(mockRemoteDataSource);
    });

    test(
        '3. API fails -> automatically returns cache if available',
        () async {
      // arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getCurrentWeather(tCity))
          .thenThrow(ServerException('Unable to load weather data'));
      when(() => mockLocalDataSource.getLastCurrentWeather(tCity))
          .thenAnswer((_) async => tWeatherModel);

      // act
      final result = await repository.getCurrentWeather(tCity);

      // assert
      expect(result.city, equals(tCity));
      expect(result.isCached, isTrue);
      verify(() => mockRemoteDataSource.getCurrentWeather(tCity)).called(1);
      verify(() => mockLocalDataSource.getLastCurrentWeather(tCity)).called(1);
    });
  });
}
