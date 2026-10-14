import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/favorites/presentation/fav_controller.dart';
import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';

class ArticleDetailScreen extends ConsumerWidget {
  final ArticleEntity article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch favorites state to dynamically update heart icon
    final favorites = ref.watch(favoritesControllerProvider);
    final isFav = favorites.any((item) => item.id == article.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(article.sourceName ?? 'Article Details'),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : null,
            ),
            onPressed: () {
              ref
                  .read(favoritesControllerProvider.notifier)
                  .toggleFavorite(article);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isFav ? 'Removed from favorites' : 'Saved to favorites',
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Article Thumbnail Image
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            const SizedBox(height: 16),

            // Published Date
            if (article.pubDate != null)
              Text(
                'Published: ${article.pubDate}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            const SizedBox(height: 8),

            // Article Title
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Description / Snippet
            Text(
              article.description ?? 'No detailed description available.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}