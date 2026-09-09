import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../errors/exceptions.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService secureStorageService;
  final Dio? dio;

  AuthInterceptor({
    required this.secureStorageService,
    this.dio,
  });

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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await secureStorageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty && dio != null) {
        try {
          // Attempt to refresh the access token using the stored refresh token
          final refreshResponse = await dio!.post(
            '/auth/v1/token?grant_type=refresh_token',
            data: {'refresh_token': refreshToken},
          );

          if (refreshResponse.statusCode == 200 && refreshResponse.data != null) {
            final newAccessToken = refreshResponse.data['access_token'] as String?;
            final newRefreshToken = refreshResponse.data['refresh_token'] as String?;

            if (newAccessToken != null) {
              await secureStorageService.saveToken(newAccessToken);
              if (newRefreshToken != null) {
                await secureStorageService.saveRefreshToken(newRefreshToken);
              }

              // Retry original request with new token
              final retryOptions = err.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
              final response = await dio!.fetch(retryOptions);
              return handler.resolve(response);
            }
          }
        } catch (_) {
          // Token refresh failed, continue to reject
        }
      }

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

