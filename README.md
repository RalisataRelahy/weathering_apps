# Weather Offline

A clean, production-grade Flutter weather application with authentication, real OpenWeatherMap API integration, local Hive caching, and strict offline-first support.

## Project Description

Weather Offline provides real-time weather information and multi-day forecasts for any city. The application seamlessly transitions between online API data fetching and local offline caching so users can view weather data even when internet connectivity is lost or network requests fail.

## Architecture

The project follows **Feature-First + Clean Architecture**:

```text
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   ├── network/
│   │   ├── auth_interceptor.dart
│   │   ├── dio_client.dart
│   │   └── network_info.dart
│   ├── router/
│   │   └── app_router.dart
│   └── storage/
│       ├── hive_service.dart
│       └── secure_storage_service.dart
│
└── features/
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/auth_remote_data_source.dart
    │   │   └── repositories/auth_repository_impl.dart
    │   ├── domain/
    │   │   ├── entities/user_entity.dart
    │   │   ├── repositories/auth_repository.dart
    │   │   └── usecases/
    │   └── presentation/
    │       ├── pages/ (SplashPage, LoginPage, RegisterPage)
    │       └── providers/auth_provider.dart
    │
    └── weather/
        ├── data/
        │   ├── datasources/
        │   │   ├── local_weather_data_source.dart
        │   │   └── remote_weather_data_source.dart
        │   ├── models/ (weather_model.dart, forecast_model.dart)
        │   └── repositories/weather_repository_impl.dart
        ├── domain/
        │   ├── entities/ (weather_entity.dart, forecast_entity.dart)
        │   ├── repositories/weather_repository.dart
        │   └── usecases/ (get_current_weather_usecase.dart, get_forecast_usecase.dart)
        └── presentation/
            ├── pages/ (CurrentWeatherPage, ForecastPage, SearchCityPage, WeatherDetailsPage)
            ├── providers/weather_provider.dart
            └── widgets/offline_indicator.dart
```

### Data Flow
`UI -> Provider -> UseCase -> Repository -> DataSource -> API / Cache`

## Mandatory APIs & Libraries

- **Flutter / Dart**
- **Riverpod**: State management & dependency injection
- **Dio**: HTTP requests with custom `AuthInterceptor`
- **Supabase Auth**: Authentication & session management
- **OpenWeatherMap API**: Weather and forecast data
- **Hive**: Offline local caching
- **flutter_secure_storage**: Encrypted storage for access/refresh tokens
- **connectivity_plus**: Network availability checking
- **go_router**: Navigation & route redirection
- **mocktail**: Unit test mocks

## Offline First & Caching Strategy

The app enforces the following execution flow:

1. **Internet Available**:
   - Calls the OpenWeatherMap API via `RemoteWeatherDataSource`.
   - Saves the fresh API response into local Hive box via `LocalWeatherDataSource`.
   - Displays live data (`isCached: false`).

2. **No Internet**:
   - Retrieves the most recent weather/forecast entry for the city from Hive cache.
   - Displays the cached data and shows the banner: `"Offline - Cached data"`.

3. **API Failure**:
   - Automatically falls back to Hive cache if available.
   - Displays clear error message only if no cached data exists for that city.

## Installation & Setup

1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd weathering_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Setup environment variables:
   Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

   Configure `.env` with valid keys:
   ```env
   OPENWEATHER_API_KEY=your_openweather_api_key_here
   SUPABASE_URL=https://your-supabase-project.supabase.co
   SUPABASE_ANON_KEY=your_supabase_anon_key_here
   ```

4. Run the application:
   ```bash
   flutter run
   ```

## Running Unit Tests

To run the unit tests verifying `WeatherRepositoryImpl` logic across all 3 mandatory test scenarios (Online success/caching, Offline fallback, API failure fallback):

```bash
flutter test
```
