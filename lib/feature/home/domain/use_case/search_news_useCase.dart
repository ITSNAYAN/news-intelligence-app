import 'package:news_api_app/feature/home/domain/new_page_entity.dart';
import 'package:news_api_app/feature/home/domain/news_repo.dart';

class SearchNewsUseCase {
  SearchNewsUseCase(this._newsRepo);

  final NewsRepo _newsRepo;

  Future<NewPageEntity> call({
    required String query,
    String? nextPage,
  }) {
    return _newsRepo.searchNewsData(
      query: query,
      nextPage: nextPage,
    );
  }
}