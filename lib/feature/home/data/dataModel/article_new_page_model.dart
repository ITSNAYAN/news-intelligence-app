import 'package:news_api_app/feature/home/data/dataModel/article_data_model.dart';
import 'package:news_api_app/feature/home/domain/new_page_entity.dart';

class ArticleNewPageModel {
  const ArticleNewPageModel({required this.articles, this.nextPage});

  final List<ArticleDataModel> articles;
  final String? nextPage;

  factory ArticleNewPageModel.fromJson(Map<String, dynamic> json) {
    final rawList = (json['results'] as List<dynamic>?) ?? [];

    final articles = <ArticleDataModel>[];
    for (final item in rawList) {
      try {
        articles.add(ArticleDataModel.fromJson(item as Map<String, dynamic>));
      } catch (_) {
        
      }
    }

    return ArticleNewPageModel(
      articles: articles,
      nextPage: json['nextPage'] as String?,
    );
  }

  NewPageEntity toEntity() => NewPageEntity(
        articles: articles.map((a) => a.toEntity()).toList(),
        nextPage: nextPage,
      );
}