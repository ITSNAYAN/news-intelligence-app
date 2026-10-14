import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/article_details/presentation/article_detail_screen.dart';
import 'package:news_api_app/feature/auth/presentation/auth_controller.dart';
import 'package:news_api_app/feature/favorites/presentation/favorite_screen.dart';
import 'package:news_api_app/feature/home/presentation/state/new_state.dart';
import 'package:news_api_app/feature/home/presentation/state/news_provider.dart';
import 'package:news_api_app/feature/home/presentation/view/widget/article_card.dart';
import 'package:news_api_app/feature/home/presentation/view/widget/category_filter.dart';
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
    // Attach scroll listener for infinite scroll / pagination
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

  // Asks for confirmation, then logs out. AuthGate watches the auth state
  // and swaps this screen for the login page automatically.
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(authControllerProvider.notifier).logout();
    }
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
          // Logout (top right)
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _confirmLogout,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Category selector
          CategoryFilter(
            categories: _categories,
            selectedCategory: state.selectedCategory,
            onCategorySelected: (category) => ref
                .read(newsControllerProvider.notifier)
                .fetchInitialNews(category),
          ),

          // 2. Feed body (Loading, Error, Empty, or List)
          Expanded(
            child: _buildBody(state),
          ),
        ],
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
          return ArticleCard(
            article: article,
            // Navigates to Screen 4: Article Details
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ArticleDetailScreen(article: article),
              ),
            ),
          );
        },
      ),
    );
  }
}