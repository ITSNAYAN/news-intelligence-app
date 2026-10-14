import 'package:news_api_app/feature/home/data/dataModel/article_new_page_model.dart';

abstract class ArticleRemoteDataSource {
  Future<ArticleNewPageModel> fetchNews({
    required String category,
    String? nextPage,
  });

  Future<ArticleNewPageModel> searchNews({
    required String query,
    String? nextPage,
  });
  
}