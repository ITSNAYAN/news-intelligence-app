
import 'package:news_api_app/feature/home/domain/news_repo.dart';
import 'package:news_api_app/feature/home/domain/new_page_entity.dart';

class GetNewsArticlesUseCase {
  final NewsRepo _newsRepo; 

  const GetNewsArticlesUseCase(this._newsRepo);

  Future<NewPageEntity> call({
    required String category,
    String? nextPage,
  }) async {
    return await _newsRepo.getNewsData(
      category: category,
      nextPage: nextPage,
    );
  }
}