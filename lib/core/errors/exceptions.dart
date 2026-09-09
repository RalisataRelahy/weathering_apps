class ServerException implements Exception {
  final String? message;
  ServerException([this.message]);

  @override
  String toString() => message ?? 'ServerException';
}

class CacheException implements Exception {
  final String? message;
  CacheException([this.message]);

  @override
  String toString() => message ?? 'CacheException';
}

class NoInternetException implements Exception {
  final String? message;
  NoInternetException([this.message]);

  @override
  String toString() => message ?? 'NoInternetException';
}

class UnauthorizedException implements Exception {
  final String? message;
  UnauthorizedException([this.message]);

  @override
  String toString() => message ?? 'UnauthorizedException';
}

class AuthException implements Exception {
  final String? message;
  AuthException([this.message]);

  @override
  String toString() => message ?? 'AuthException';
}

