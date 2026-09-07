import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/storage/secure_storage_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorageService secureStorageService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorageService,
  });

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(email: email, password: password);
    final user = response.user!;
    final session = response.session;

    if (session != null) {
      await secureStorageService.saveToken(session.accessToken);
      if (session.refreshToken != null) {
        await secureStorageService.saveRefreshToken(session.refreshToken!);
      }
    }

    return UserEntity(
      id: user.id,
      email: user.email ?? email,
    );
  }

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.register(email: email, password: password);
    final user = response.user!;
    final session = response.session;

    if (session != null) {
      await secureStorageService.saveToken(session.accessToken);
      if (session.refreshToken != null) {
        await secureStorageService.saveRefreshToken(session.refreshToken!);
      }
    }

    return UserEntity(
      id: user.id,
      email: user.email ?? email,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
    await secureStorageService.clearAll();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = remoteDataSource.getCurrentUser();
    if (user == null) return null;
    return UserEntity(
      id: user.id,
      email: user.email ?? '',
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return UserEntity(
        id: user.id,
        email: user.email ?? '',
      );
    });
  }
}
