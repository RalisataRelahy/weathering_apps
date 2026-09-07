import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/weather_provider.dart';
import '../widgets/offline_indicator.dart';

class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final forecast = weatherState.forecast;

    return Scaffold(
      appBar: AppBar(
        title: Text(forecast != null ? '${forecast.cityName} Forecast' : 'Forecast'),
      ),
      body: Column(
        children: [
          if (forecast?.isCached == true) const OfflineIndicator(),
          Expanded(
            child: _buildBody(context, ref, weatherState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, WeatherState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.forecast == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            state.error!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final forecastList = state.forecast?.forecasts ?? [];

    if (forecastList.isEmpty) {
      return const Center(child: Text('No forecast data available'));
    }

    return ListView.builder(
      itemCount: forecastList.length,
      padding: const EdgeInsets.all(16.0),
      itemBuilder: (context, index) {
        final item = forecastList[index];
        final dateStr =
            '${item.date.year}-${item.date.month.toString().padLeft(2, '0')}-${item.date.day.toString().padLeft(2, '0')} ${item.date.hour.toString().padLeft(2, '0')}:00';

        return Card(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: ListTile(
            title: Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.description.toUpperCase()),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.temperature.toStringAsFixed(1)}°C',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              ref.read(weatherNotifierProvider.notifier).selectWeatherDetails(item);
              context.push('/weather-details');
            },
          ),
        );
      },
    );
  }
}
