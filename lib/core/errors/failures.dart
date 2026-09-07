import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Unable to load weather data']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Unable to load weather data']);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = 'No internet connection']);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Please try again']);
}
