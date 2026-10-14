import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:news_api_app/feature/article_details/presentation/article_detail_screen.dart';
import 'package:news_api_app/feature/search/presentation/search_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSubmitted(String value) {
    ref.read(searchControllerProvider.notifier).search(value);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _textController,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onSubmitted: _onSubmitted,
          decoration: InputDecoration(
            hintText: 'Search news by keyword...',
            border: InputBorder.none,
            suffixIcon: _textController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _textController.clear();
                      ref.read(searchControllerProvider.notifier).clearSearch();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SearchState state) {
    switch (state.status) {
      case SearchStatus.initial:
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search, size: 64, color: Colors.grey),
              SizedBox(height: 12),
              Text(
                'Type a topic and press Search',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );

      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case SearchStatus.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  state.errorMessage ?? 'An error occurred during search.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _onSubmitted(_textController.text),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );

      case SearchStatus.success:
        if (state.articles.isEmpty) {
          return Center(
            child: Text(
              'No articles found for "${state.currentQuery}".',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: state.articles.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == state.articles.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final article = state.articles[index];
            return Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: article.imageUrl != null && article.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          article.imageUrl!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.newspaper, size: 40),
                        ),
                      )
                    : const Icon(Icons.newspaper, size: 40),
                title: Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: article.sourceName != null
                    ? Text(
                        article.sourceName!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 12,
                        ),
                      )
                    : null,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ArticleDetailScreen(article: article),
                    ),
                  );
                },
              ),
            );
          },
        );
    }
  }
}