import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_offline/main.dart';

void main() {
  testWidgets('App initializes correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeatherOfflineApp(),
      ),
    );
    expect(find.byType(WeatherOfflineApp), findsOneWidget);
  });
}

