import 'package:hive_flutter/hive_flutter.dart';
import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';

class FavoritesLocalDataSource {
  static const String boxName = 'favorites_box';

  Box get _box => Hive.box(boxName);

  List<ArticleEntity> getFavorites() {
    return _box.values.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return ArticleEntity(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String?,
        imageUrl: map['imageUrl'] as String?,
        sourceName: map['sourceName'] as String?,
        publishedAt: map['publishedAt'] as String?,
        url: map['url'] as String?, 
      );
    }).toList();
  }

  bool isFavorite(String id) {
    return _box.containsKey(id);
  }

  Future<void> saveFavorite(ArticleEntity article) async {
    await _box.put(article.id, {
      'id': article.id,
      'title': article.title,
      'description': article.description,
      'imageUrl': article.imageUrl,
      'sourceName': article.sourceName,
      'publishedAt': article.publishedAt,
      'url': article.url,
    });
  }

  Future<void> removeFavorite(String id) async {
    await _box.delete(id);
  }
}