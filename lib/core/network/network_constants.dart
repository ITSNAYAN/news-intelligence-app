class NetworkConstants {
  NetworkConstants._();

  static const String baseUrl = 'https://newsdata.io/api/1';

  static const String apiKey = String.fromEnvironment(
    'NEWS_API_KEY',
    defaultValue: 'pub_3161f41f956241d1a40a0cd7183d4b30',
  );

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}