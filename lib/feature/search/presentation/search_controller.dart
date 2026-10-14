import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';
import 'package:news_api_app/feature/home/domain/use_case/search_news_useCase.dart';
import 'package:news_api_app/feature/home/presentation/state/news_provider.dart';

// 1. Search UseCase Provider
final searchNewsUseCaseProvider = Provider<SearchNewsUseCase>((ref) {
  final repo = ref.watch(newsRepoProvider);
  return SearchNewsUseCase(repo);
});

// 2. Search UI State
enum SearchStatus { initial, loading, success, error }

class SearchState {
  final SearchStatus status;
  final List<ArticleEntity> articles;
  final String? nextPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final String currentQuery;

  const SearchState({
    this.status = SearchStatus.initial,
    this.articles = const [],
    this.nextPage,
    this.isLoadingMore = false,
    this.errorMessage,
    this.currentQuery = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    List<ArticleEntity>? articles,
    String? nextPage,
    bool? isLoadingMore,
    String? errorMessage,
    String? currentQuery,
  }) {
    return SearchState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      nextPage: nextPage ?? this.nextPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage ?? this.errorMessage,
      currentQuery: currentQuery ?? this.currentQuery,
    );
  }
}

// 3. Search Controller
final searchControllerProvider =
    NotifierProvider<SearchController, SearchState>(SearchController.new);

class SearchController extends Notifier<SearchState> {
  SearchNewsUseCase get _useCase => ref.read(searchNewsUseCaseProvider);

  @override
  SearchState build() {
    return const SearchState();
  }

  Future<void> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      status: SearchStatus.loading,
      currentQuery: trimmed,
      errorMessage: null,
    );

    try {
      final result = await _useCase(query: trimmed);
      state = state.copyWith(
        status: SearchStatus.success,
        articles: result.articles,
        nextPage: result.nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        status: SearchStatus.error,
        errorMessage: 'Failed to find articles for "$trimmed". Please try again.',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        state.nextPage == null ||
        state.status != SearchStatus.success) {
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    try {
      final result = await _useCase(
        query: state.currentQuery,
        nextPage: state.nextPage,
      );

      state = state.copyWith(
        isLoadingMore: false,
        articles: [...state.articles, ...result.articles],
        nextPage: result.nextPage,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  void clearSearch() {
    state = const SearchState();
  }
}