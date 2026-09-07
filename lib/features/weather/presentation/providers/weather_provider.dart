import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/storage/hive_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/local_weather_data_source.dart';
import '../../data/datasources/remote_weather_data_source.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../domain/entities/forecast_entity.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/usecases/get_current_weather_usecase.dart';
import '../../domain/usecases/get_forecast_usecase.dart';

final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.watch(connectivityProvider));
});

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(
    secureStorageService: ref.watch(secureStorageServiceProvider),
  );
});

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveServiceImpl();
});

final remoteWeatherDataSourceProvider = Provider<RemoteWeatherDataSource>((ref) {
  return RemoteWeatherDataSourceImpl(
    dio: ref.watch(dioClientProvider).dio,
  );
});

final localWeatherDataSourceProvider = Provider<LocalWeatherDataSource>((ref) {
  return LocalWeatherDataSourceImpl(
    hiveService: ref.watch(hiveServiceProvider),
  );
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remoteDataSource: ref.watch(remoteWeatherDataSourceProvider),
    localDataSource: ref.watch(localWeatherDataSourceProvider),
    networkInfo: ref.watch(networkInfoProvider),
  );
});

final getCurrentWeatherUseCaseProvider = Provider<GetCurrentWeatherUseCase>((ref) {
  return GetCurrentWeatherUseCase(ref.watch(weatherRepositoryProvider));
});

final getForecastUseCaseProvider = Provider<GetForecastUseCase>((ref) {
  return GetForecastUseCase(ref.watch(weatherRepositoryProvider));
});

final selectedCityProvider = StateProvider<String>((ref) => 'Paris');

class WeatherState {
  final bool isLoading;
  final String? error;
  final WeatherEntity? currentWeather;
  final ForecastEntity? forecast;
  final WeatherEntity? selectedWeatherDetails;

  const WeatherState({
    this.isLoading = false,
    this.error,
    this.currentWeather,
    this.forecast,
    this.selectedWeatherDetails,
  });

  WeatherState copyWith({
    bool? isLoading,
    String? error,
    WeatherEntity? currentWeather,
    ForecastEntity? forecast,
    WeatherEntity? selectedWeatherDetails,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentWeather: currentWeather ?? this.currentWeather,
      forecast: forecast ?? this.forecast,
      selectedWeatherDetails: selectedWeatherDetails ?? this.selectedWeatherDetails,
    );
  }
}

class WeatherNotifier extends StateNotifier<WeatherState> {
  final GetCurrentWeatherUseCase _getCurrentWeatherUseCase;
  final GetForecastUseCase _getForecastUseCase;

  WeatherNotifier({
    required GetCurrentWeatherUseCase getCurrentWeatherUseCase,
    required GetForecastUseCase getForecastUseCase,
  })  : _getCurrentWeatherUseCase = getCurrentWeatherUseCase,
        _getForecastUseCase = getForecastUseCase,
        super(const WeatherState());

  Future<void> fetchWeather(String city) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentWeather = await _getCurrentWeatherUseCase(city);
      final forecast = await _getForecastUseCase(city);
      state = state.copyWith(
        isLoading: false,
        currentWeather: currentWeather,
        forecast: forecast,
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      state = state.copyWith(
        isLoading: false,
        error: errorMessage,
      );
    }
  }

  void selectWeatherDetails(WeatherEntity weather) {
    state = state.copyWith(selectedWeatherDetails: weather);
  }
}

final weatherNotifierProvider =
    StateNotifierProvider<WeatherNotifier, WeatherState>((ref) {
  return WeatherNotifier(
    getCurrentWeatherUseCase: ref.watch(getCurrentWeatherUseCaseProvider),
    getForecastUseCase: ref.watch(getForecastUseCaseProvider),
  );
});
