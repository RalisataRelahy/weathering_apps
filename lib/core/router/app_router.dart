import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/weather/presentation/pages/current_weather_page.dart';
import '../../features/weather/presentation/pages/forecast_page.dart';
import '../../features/weather/presentation/pages/search_city_page.dart';
import '../../features/weather/presentation/pages/weather_details_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/current-weather',
      builder: (context, state) => const CurrentWeatherPage(),
    ),
    GoRoute(
      path: '/forecast',
      builder: (context, state) => const ForecastPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (context, state) => const SearchCityPage(),
    ),
    GoRoute(
      path: '/weather-details',
      builder: (context, state) => const WeatherDetailsPage(),
    ),
  ],
);
