import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_provider.dart';
import '../widgets/offline_indicator.dart';

class WeatherDetailsPage extends ConsumerWidget {
  const WeatherDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final weather = weatherState.selectedWeatherDetails ?? weatherState.currentWeather;

    return Scaffold(
      appBar: AppBar(
        title: Text(weather != null ? '${weather.city} Details' : 'Weather Details'),
      ),
      body: Column(
        children: [
          if (weather?.isCached == true) const OfflineIndicator(),
          Expanded(
            child: weather == null
                ? const Center(child: Text('No details available'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Text(
                                  weather.city,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  weather.date.toIso8601String().substring(0, 16).replaceAll('T', ' '),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '${weather.temperature.toStringAsFixed(1)}°C',
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  weather.description.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildDetailRow('Min Temperature', '${weather.tempMin.toStringAsFixed(1)}°C'),
                                const Divider(),
                                _buildDetailRow('Max Temperature', '${weather.tempMax.toStringAsFixed(1)}°C'),
                                const Divider(),
                                _buildDetailRow('Humidity', '${weather.humidity}%'),
                                const Divider(),
                                _buildDetailRow('Wind Speed', '${weather.windSpeed} m/s'),
                                const Divider(),
                                _buildDetailRow('Status', weather.isCached ? 'Cached (Offline)' : 'Live API'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}
