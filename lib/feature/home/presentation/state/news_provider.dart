import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/core/network/network.dart';
import 'package:news_api_app/feature/home/data/article_news_repo_impl.dart';
import 'package:news_api_app/feature/home/data/article_remote_data_source.dart';
import 'package:news_api_app/feature/home/data/article_remote_data_source_impl.dart';
import 'package:news_api_app/feature/home/domain/news_repo.dart';
import 'package:news_api_app/feature/home/domain/use_case/news_article_useCase.dart';
import 'package:news_api_app/feature/home/presentation/state/news_controller.dart';
import 'package:news_api_app/feature/home/presentation/state/new_state.dart';

// 1. Data Source Provider
final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio);
});

// 2. Repository Provider
final newsRepoProvider = Provider<NewsRepo>((ref) {
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  return NewsRepoImpl(remoteDataSource);
});

// 3. Use Case Provider
final getNewsArticlesUseCaseProvider = Provider<GetNewsArticlesUseCase>((ref) {
  final repo = ref.watch(newsRepoProvider);
  return GetNewsArticlesUseCase(repo);
});


final newsControllerProvider =
    NotifierProvider<NewsController, NewsState>(NewsController.new);