import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';

enum NewsStatus { initial, loading, loaded, error }

class NewsState {
  final NewsStatus status;
  final List<ArticleEntity> articles;
  final String? nextPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final String selectedCategory;

  const NewsState({
    this.status = NewsStatus.initial,
    this.articles = const [],
    this.nextPage,
    this.isLoadingMore = false,
    this.errorMessage,
    this.selectedCategory = 'technology',
  });

  NewsState copyWith({
    NewsStatus? status,
    List<ArticleEntity>? articles,
    String? nextPage,
    bool? isLoadingMore,
    String? errorMessage,
    String? selectedCategory,
  }) {
    return NewsState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      nextPage: nextPage ?? this.nextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}