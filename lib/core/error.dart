abstract class Failure implements Exception {
  const Failure(this.message);
  final String message;

  @override
  String toString() => message;
}
class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Daily API limit reached. Try again later.']);
}
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not access local storage.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Something went wrong on the server.']);
}
class ApiKeyFailure extends Failure {
  const ApiKeyFailure([
    super.message = 'Invalid or missing API key. Please check your NEWS_API_KEY configuration.',
  ]);
}