import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../errors/exceptions.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;

  AuthInterceptor({required this.secureStorageService});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await secureStorageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: err.response,
          error: UnauthorizedException('Session expired. Please log in again.'),
          type: err.type,
        ),
      );
    } else {
      handler.next(err);
    }
  }
}
