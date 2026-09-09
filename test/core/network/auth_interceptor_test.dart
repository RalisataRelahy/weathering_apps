import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_offline/core/network/auth_interceptor.dart';
import 'package:weather_offline/core/storage/secure_storage_service.dart';

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  late AuthInterceptor interceptor;
  late MockSecureStorageService mockSecureStorageService;
  late MockRequestInterceptorHandler mockHandler;

  setUp(() {
    mockSecureStorageService = MockSecureStorageService();
    mockHandler = MockRequestInterceptorHandler();
    interceptor = AuthInterceptor(
      secureStorageService: mockSecureStorageService,
    );
  });

  group('AuthInterceptor', () {
    test('should add Authorization Bearer header when token exists', () async {
      // arrange
      const tToken = 'valid_access_token_123';
      when(() => mockSecureStorageService.getToken()).thenAnswer((_) async => tToken);
      final options = RequestOptions(path: '/weather');

      // act
      interceptor.onRequest(options, mockHandler);
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      expect(options.headers['Authorization'], equals('Bearer $tToken'));
      verify(() => mockHandler.next(options)).called(1);
    });

    test('should not add Authorization header when token is null', () async {
      // arrange
      when(() => mockSecureStorageService.getToken()).thenAnswer((_) async => null);
      final options = RequestOptions(path: '/weather');

      // act
      interceptor.onRequest(options, mockHandler);
      await Future.delayed(const Duration(milliseconds: 10));

      // assert
      expect(options.headers['Authorization'], isNull);
      verify(() => mockHandler.next(options)).called(1);
    });
  });
}
