import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/home/domain/use_case/news_article_useCase.dart';
import 'package:news_api_app/feature/home/presentation/state/news_provider.dart';

import 'package:news_api_app/feature/home/presentation/state/new_state.dart';

class NewsController extends Notifier<NewsState> {
  @override
  NewsState build() {

    Future.microtask(() => fetchInitialNews());
    return const NewsState();
  }

  GetNewsArticlesUseCase get _getNewsArticlesUseCase =>
      ref.read(getNewsArticlesUseCaseProvider);

  // 1. Initial Load / Category Change
  Future<void> fetchInitialNews([String? category]) async {
    final targetCategory = category ?? state.selectedCategory;

    state = state.copyWith(
      status: NewsStatus.loading,
      selectedCategory: targetCategory,
      articles: [],
      nextPage: null,
      errorMessage: null,
    );

    try {
      final result = await _getNewsArticlesUseCase(category: targetCategory);
      state = state.copyWith(
        status: NewsStatus.loaded,
        articles: result.articles,
        nextPage: result.nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        status: NewsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // 2. Pagination
  Future<void> fetchNextPage() async {
    if (state.isLoadingMore || state.nextPage == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _getNewsArticlesUseCase(
        category: state.selectedCategory,
        nextPage: state.nextPage,
      );

      state = state.copyWith(
        isLoadingMore: false,
        articles: [...state.articles, ...result.articles],
        nextPage: result.nextPage,
      );
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  // 3. Pull-to-refresh 
  Future<void> refresh() async {
    await fetchInitialNews(state.selectedCategory);
  }
}