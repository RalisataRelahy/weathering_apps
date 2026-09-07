import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/offline_indicator.dart';

class CurrentWeatherPage extends ConsumerStatefulWidget {
  const CurrentWeatherPage({super.key});

  @override
  ConsumerState<CurrentWeatherPage> createState() => _CurrentWeatherPageState();
}

class _CurrentWeatherPageState extends ConsumerState<CurrentWeatherPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final city = ref.read(selectedCityProvider);
      ref.read(weatherNotifierProvider.notifier).fetchWeather(city);
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final selectedCity = ref.watch(selectedCityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Weather'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
            tooltip: 'Search City',
          ),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => context.push('/forecast'),
            tooltip: 'Forecast',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          if (weatherState.currentWeather?.isCached == true)
            const OfflineIndicator(),
          Expanded(
            child: _buildBody(context, weatherState, selectedCity),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherState state, String city) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.currentWeather == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                state.error!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(weatherNotifierProvider.notifier).fetchWeather(city);
                },
                child: const Text('Please try again'),
              ),
            ],
          ),
        ),
      );
    }

    final weather = state.currentWeather;

    if (weather == null) {
      return const Center(child: Text('No weather data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            weather.city,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            weather.description.toUpperCase(),
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          Text(
            '${weather.temperature.toStringAsFixed(1)}°C',
            style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 32),
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailTile(
                    icon: Icons.water_drop,
                    title: 'Humidity',
                    value: '${weather.humidity}%',
                  ),
                  _buildDetailTile(
                    icon: Icons.air,
                    title: 'Wind Speed',
                    value: '${weather.windSpeed} m/s',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('Search City'),
                onPressed: () => context.push('/search'),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_month),
                label: const Text('View Forecast'),
                onPressed: () => context.push('/forecast'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueGrey),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
