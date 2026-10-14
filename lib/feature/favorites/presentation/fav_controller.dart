import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/favorites/data/fav_data_source.dart';
import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';

// 1. Data Source Provider
final favoritesLocalDataSourceProvider =
    Provider<FavoritesLocalDataSource>((ref) {
  return FavoritesLocalDataSource();
});

// 2. Controller Provider
final favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<ArticleEntity>>(
  FavoritesController.new,
);

// 3. Controller Implementation
class FavoritesController extends Notifier<List<ArticleEntity>> {
  FavoritesLocalDataSource get _dataSource =>
      ref.read(favoritesLocalDataSourceProvider);

  @override
  List<ArticleEntity> build() {
    // read from hive 
    return _dataSource.getFavorites();
  }

  bool isFavorite(String id) {
    return state.any((article) => article.id == id);
  }

  Future<void> toggleFavorite(ArticleEntity article) async {
    if (isFavorite(article.id)) {
      await _dataSource.removeFavorite(article.id);
      state = state.where((item) => item.id != article.id).toList();
    } else {
      await _dataSource.saveFavorite(article);
      state = [...state, article];
    }
  }
}