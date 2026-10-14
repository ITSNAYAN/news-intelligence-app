import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:news_api_app/core/error.dart';
import 'package:news_api_app/core/network/network_constants.dart';
import 'package:news_api_app/feature/home/data/article_remote_data_source.dart';
import 'package:news_api_app/feature/home/data/dataModel/article_new_page_model.dart';

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  ArticleRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  String get _apiKey {
    final key = NetworkConstants.apiKey;
    if (key.trim().isEmpty) {
      throw const ApiKeyFailure(
        'NEWS_API_KEY is missing. Pass it via --dart-define=NEWS_API_KEY=your_key',
      );
    }
    return key;
  }

  Map<String, dynamic> _safeParseResponse(dynamic rawData) {
    if (rawData == null) {
      throw const ServerFailure('Received empty response from news server.');
    }
    if (rawData is Map<String, dynamic>) {
      return rawData;
    }
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }
    if (rawData is String) {
      final decoded = jsonDecode(rawData);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw const ServerFailure('Unexpected response format.');
  }

  @override
  Future<ArticleNewPageModel> fetchNews({
    required String category,
    String? nextPage,
  }) async {
    try {
      final response = await _dio.get(
        '/latest',
        options: Options(
          headers: {'X-ACCESS-KEY': _apiKey},
        ),
        queryParameters: {
          'apikey': _apiKey,
          'category': category,
          if (nextPage != null) 'page': nextPage,
        },
      );

      final dataMap = _safeParseResponse(response.data);
      return ArticleNewPageModel.fromJson(dataMap);
    } on DioException catch (e) {
      throw _onDioError(e);
    } catch (e, stackTrace) {
      debugPrint('Parsing error in fetchNews: $e\n$stackTrace');
      if (e is Failure) rethrow;
      throw ServerFailure('Data parsing failed: $e');
    }
  }

  @override
  Future<ArticleNewPageModel> searchNews({
    required String query,
    String? nextPage,
  }) async {
    try {
      final response = await _dio.get(
        '/latest',
        options: Options(
          headers: {'X-ACCESS-KEY': _apiKey},
        ),
        queryParameters: {
          'apikey': _apiKey,
          'q': query,
          if (nextPage != null) 'page': nextPage,
        },
      );

      final dataMap = _safeParseResponse(response.data);
      return ArticleNewPageModel.fromJson(dataMap);
    } on DioException catch (e) {
      throw _onDioError(e);
    } catch (e, stackTrace) {
      debugPrint('Parsing error in searchNews: $e\n$stackTrace');
      if (e is Failure) rethrow;
      throw ServerFailure('Data parsing failed: $e');
    }
  }

 Failure _onDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        
        // 1. Safely extract message without syntax-breaking inline ternaries
        String? serverMessage;
        final responseData = e.response?.data;
        if (responseData is Map) {
          final results = responseData['results'];
          if (results is Map && results['message'] != null) {
            serverMessage = results['message'].toString();
          } else if (responseData['message'] != null) {
            serverMessage = responseData['message'].toString();
          }
        }

        // 2. Map to your custom Failure types
        if (statusCode == 401) {
          return ApiKeyFailure(
            serverMessage ?? 'Invalid or unauthorized API key.',
          );
        }

        if (statusCode == 429) {
          return const RateLimitFailure();
        }

        return ServerFailure(
          serverMessage ?? 'Server returned error status code: $statusCode',
        );

      default:
        return const ServerFailure();
    }
  }
}