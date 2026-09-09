import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:weather_offline/core/errors/exceptions.dart';
import 'package:weather_offline/core/storage/secure_storage_service.dart';
import 'package:weather_offline/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:weather_offline/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:weather_offline/features/auth/domain/entities/user_entity.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

class MockAuthResponse extends Mock implements supabase.AuthResponse {}

class MockSession extends Mock implements supabase.Session {}

class MockUser extends Mock implements supabase.User {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockSecureStorageService mockSecureStorageService;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockSecureStorageService = MockSecureStorageService();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      secureStorageService: mockSecureStorageService,
    );
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tToken = 'jwt_access_token_xyz';
  const tRefreshToken = 'jwt_refresh_token_xyz';
  const tUserId = 'user-uuid-123';

  group('login', () {
    test('should save tokens and return UserEntity on successful authentication', () async {
      // arrange
      final mockResponse = MockAuthResponse();
      final mockSession = MockSession();
      final mockUser = MockUser();

      when(() => mockUser.id).thenReturn(tUserId);
      when(() => mockUser.email).thenReturn(tEmail);
      when(() => mockSession.accessToken).thenReturn(tToken);
      when(() => mockSession.refreshToken).thenReturn(tRefreshToken);
      when(() => mockResponse.user).thenReturn(mockUser);
      when(() => mockResponse.session).thenReturn(mockSession);

      when(() => mockRemoteDataSource.login(email: tEmail, password: tPassword))
          .thenAnswer((_) async => mockResponse);
      when(() => mockSecureStorageService.saveToken(tToken))
          .thenAnswer((_) async => {});
      when(() => mockSecureStorageService.saveRefreshToken(tRefreshToken))
          .thenAnswer((_) async => {});

      // act
      final result = await repository.login(email: tEmail, password: tPassword);

      // assert
      expect(result, isA<UserEntity>());
      expect(result.id, equals(tUserId));
      expect(result.email, equals(tEmail));
      verify(() => mockSecureStorageService.saveToken(tToken)).called(1);
      verify(() => mockSecureStorageService.saveRefreshToken(tRefreshToken)).called(1);
    });

    test('should throw AuthException when remote datasource fails', () async {
      // arrange
      when(() => mockRemoteDataSource.login(email: tEmail, password: tPassword))
          .thenThrow(AuthException('Invalid credentials'));

      // act & assert
      expect(
        () => repository.login(email: tEmail, password: tPassword),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('logout', () {
    test('should clear stored tokens and call remote logout', () async {
      // arrange
      when(() => mockRemoteDataSource.logout()).thenAnswer((_) async => {});
      when(() => mockSecureStorageService.clearAll()).thenAnswer((_) async => {});

      // act
      await repository.logout();

      // assert
      verify(() => mockRemoteDataSource.logout()).called(1);
      verify(() => mockSecureStorageService.clearAll()).called(1);
    });
  });
}
