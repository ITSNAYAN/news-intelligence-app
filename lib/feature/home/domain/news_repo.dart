import 'package:news_api_app/feature/home/domain/new_page_entity.dart';

abstract class NewsRepo {
  Future<NewPageEntity> getNewsData ({
     required String category ,
     String ? nextPage,
  });
  Future<NewPageEntity> searchNewsData({
    required String query,
    String? nextPage,
  });
}