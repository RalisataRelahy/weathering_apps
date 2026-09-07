import 'package:dio/dio.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  final Dio _dio;

  DioClient({
    required SecureStorageService secureStorageService,
    Dio? dio,
  }) : _dio = dio ?? Dio() {
    _dio.options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );
    _dio.interceptors.add(AuthInterceptor(secureStorageService: secureStorageService));
  }

  Dio get dio => _dio;
}
