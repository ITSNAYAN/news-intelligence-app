import 'package:news_api_app/feature/home/data/article_remote_data_source.dart';
import 'package:news_api_app/feature/home/domain/new_page_entity.dart';
import 'package:news_api_app/feature/home/domain/news_repo.dart';

class NewsRepoImpl implements NewsRepo {
  final ArticleRemoteDataSource _remoteDataSource;

  NewsRepoImpl(this._remoteDataSource);

  @override
  Future<NewPageEntity> getNewsData({
    required String category,
    String? nextPage,
  }) async {
    final model = await _remoteDataSource.fetchNews(
      category: category,
      nextPage: nextPage,
    );
    return model.toEntity();
  }

  @override
  Future<NewPageEntity> searchNewsData({
    required String query,
    String? nextPage,
  }) async {
    final model = await _remoteDataSource.searchNews(
      query: query,
      nextPage: nextPage,
    );
    return model.toEntity();
  }
}