import 'package:flutter_test/flutter_test.dart';
import 'package:weather_offline/features/weather/data/models/weather_model.dart';

void main() {
  final tDate = DateTime.fromMillisecondsSinceEpoch(1725894000 * 1000);
  final tWeatherModel = WeatherModel(
    city: 'Berlin',
    temperature: 19.5,
    tempMin: 17.0,
    tempMax: 21.0,
    humidity: 55,
    windSpeed: 4.8,
    description: 'scattered clouds',
    icon: '03d',
    date: tDate,
  );

  final tJson = {
    'name': 'Berlin',
    'main': {
      'temp': 19.5,
      'temp_min': 17.0,
      'temp_max': 21.0,
      'humidity': 55,
    },
    'wind': {
      'speed': 4.8,
    },
    'weather': [
      {
        'description': 'scattered clouds',
        'icon': '03d',
      }
    ],
    'dt': 1725894000,
  };

  group('WeatherModel', () {
    test('fromJson should parse OpenWeatherMap API JSON format correctly', () {
      final result = WeatherModel.fromJson(tJson);
      expect(result.city, equals('Berlin'));
      expect(result.temperature, equals(19.5));
      expect(result.humidity, equals(55));
      expect(result.description, equals('scattered clouds'));
    });

    test('toJson and fromJson should serialize and deserialize correctly', () {
      final json = tWeatherModel.toJson();
      final fromJsonResult = WeatherModel.fromJson(json);

      expect(fromJsonResult.city, equals(tWeatherModel.city));
      expect(fromJsonResult.temperature, equals(tWeatherModel.temperature));
      expect(fromJsonResult.humidity, equals(tWeatherModel.humidity));
      expect(fromJsonResult.description, equals(tWeatherModel.description));
    });

    test('toEntity should return a valid WeatherEntity with isCached flag', () {
      final entity = tWeatherModel.toEntity(isCached: true);
      expect(entity.city, equals('Berlin'));
      expect(entity.isCached, isTrue);
    });
  });
}
