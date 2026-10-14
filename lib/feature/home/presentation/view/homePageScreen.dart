import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/article_details/presentation/article_detail_screen.dart';
import 'package:news_api_app/feature/favorites/presentation/favorite_screen.dart';
import 'package:news_api_app/feature/home/domain/entity/article_entity.dart';
import 'package:news_api_app/feature/home/presentation/state/new_state.dart';
import 'package:news_api_app/feature/home/presentation/state/news_provider.dart';
import 'package:news_api_app/feature/search/presentation/search_screen.dart';

class Homepagescreen extends ConsumerStatefulWidget {
  const Homepagescreen({super.key});

  @override
  ConsumerState<Homepagescreen> createState() => _HomepagescreenState();
}

class _HomepagescreenState extends ConsumerState<Homepagescreen> {
  final ScrollController _scrollController = ScrollController();

  final List<String> _categories = [
    'business',
    'technology',
    'entertainment',
    'sports',
    'science',
    'health',
  ];

  @override
  void initState() {
    super.initState();
    // 1. Attach scroll listener for infinite scroll / pagination
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Triggers pagination 200px before reaching the end of the scrollview
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(newsControllerProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    // Prevent memory leaks by cleaning up the controller
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Business Intelligence',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          // Navigates to Screen 3: Search
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search News',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchScreen(),
                ),
              );
            },
          ),
          // Navigates to Screen 5: Saved Favorites
          IconButton(
            icon: const Icon(Icons.bookmarks_outlined),
            tooltip: 'Saved Articles',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FavoritesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Category selector (Business, Tech, etc.)
          _buildCategoryFilter(state.selectedCategory),

          // 2. Feed body (Loading, Error, Empty, or List)
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(String selectedCategory) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == selectedCategory;

          return ChoiceChip(
            label: Text(
              category[0].toUpperCase() + category.substring(1),
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              if (selected && category != selectedCategory) {
                ref
                    .read(newsControllerProvider.notifier)
                    .fetchInitialNews(category);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(NewsState state) {
    // Initial Load Spinner
    if (state.status == NewsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error State with Retry Button
    if (state.status == NewsStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'Failed to load news articles',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.read(newsControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty State
    if (state.articles.isEmpty) {
      return const Center(
        child: Text('No articles available in this category.'),
      );
    }

    // Data Loaded: Pull-to-refresh & Infinite Scroll List
    return RefreshIndicator(
      onRefresh: () => ref.read(newsControllerProvider.notifier).refresh(),
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          // Bottom loading spinner during pagination
          if (index == state.articles.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final article = state.articles[index];
          return _buildArticleCard(article);
        },
      ),
    );
  }

  Widget _buildArticleCard(ArticleEntity article) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          // Navigates to Screen 4: Article Details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ArticleDetailScreen(article: article),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail image with network fallback
            if (article.imageUrl != null && article.imageUrl!.isNotEmpty)
              Image.network(
                article.imageUrl!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source Name
                  if (article.sourceName != null &&
                      article.sourceName!.isNotEmpty)
                    Text(
                      article.sourceName!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  const SizedBox(height: 6),

                  // Title
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Description snippet
                  if (article.description != null &&
                      article.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      article.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      color: Colors.grey.shade200,
      child: Icon(Icons.newspaper, size: 48, color: Colors.grey.shade400),
    );
  }
}